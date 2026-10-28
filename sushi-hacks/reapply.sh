#!/usr/bin/env bash
#
# Rebuild the user-level Sushi override.
#
# Sushi 46 has a header bar whose "Open With <app>" button uses
# GFile.query_default_handler().  In this session that resolves to the
# file:// URI-scheme handler (Dolphin) instead of the application set as the
# default for the file's content type.
#
# This script extracts the JavaScript sources shipped in
# org.gnome.NautilusPreviewer.src.gresource, removes the header bar, switches
# the open action to the per-content-type default application, and installs
# the patched modules as a user-level override (plus a matching D-Bus service
# so Nautilus activates the patched previewer).
#
# Run it again after a gnome-sushi package upgrade.

set -euo pipefail

DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
DEST="$DATA_HOME/sushi-override"
SYSTEM_RESOURCE="/usr/share/sushi/org.gnome.NautilusPreviewer.src.gresource"
LAUNCHER="$HOME/.local/libexec/org.gnome.NautilusPreviewer"
SERVICE="$DATA_HOME/dbus-1/services/org.gnome.NautilusPreviewer.service"

if [[ ! -r "$SYSTEM_RESOURCE" ]]; then
    echo "error: $SYSTEM_RESOURCE not found (is gnome-sushi installed?)" >&2
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Mirror the contents of .../js/ from the gresource into $TMP/js/
while IFS= read -r path; do
    rel="${path#/org/gnome/NautilusPreviewer/js/}"
    mkdir -p "$TMP/js/$(dirname "$rel")"
    gresource extract "$SYSTEM_RESOURCE" "$path" > "$TMP/js/$rel"
done < <(gresource list "$SYSTEM_RESOURCE")

python3 - "$TMP/js/ui/mainWindow.js" <<'PY'
import sys

path = sys.argv[1]
with open(path, encoding='utf-8') as f:
    src = f.read()


def replace(old, new):
    global src
    count = src.count(old)
    if count != 1:
        raise SystemExit(f'patch failed: expected 1 match, found {count}:\n{old[:120]}')
    src = src.replace(old, new)


replace(
    """        this._titlebar = new Gtk.HeaderBar({ show_close_button: true,
                                             decoration_layout: _getDecorationLayout() });
        this.set_titlebar(this._titlebar);

        this._openButton = new Gtk.Button();
        this._openButton.connect('clicked', this._onFileOpenClicked.bind(this));
        this._titlebar.pack_end(this._openButton);
""",
    """        // Local patch: use an undecorated preview window instead of Sushi's
        // header bar. Escape/space/q still close it; Return opens the file
        // with the default application for its content type.
        this.set_decorated(false);
""",
)

replace(
    """        this.file = null;
""",
    """        this.file = null;
        this._contentType = null;
""",
)

replace(
    """        let fullscreen = new Gio.SimpleAction({ name: 'fullscreen' });
""",
    """        let open = new Gio.SimpleAction({ name: 'open' });
        open.connect('activate', this._onFileOpenClicked.bind(this));
        this.application.set_accels_for_action('win.open', ['Return', 'KP_Enter']);
        this.add_action(open);

        let fullscreen = new Gio.SimpleAction({ name: 'fullscreen' });
""",
)

replace(
    """        this.set_resizable(this._renderer.resizable);
        this.set_title(fileInfo.get_display_name());
""",
    """        this.set_resizable(this._renderer.resizable);
        this._contentType = fileInfo.get_content_type();
        this.set_title(fileInfo.get_display_name());
""",
)

replace(
    """    _updateTitlebar() {
        try {
            let appInfo = this.file.query_default_handler(null);
            // TRANSLATORS: This is the display name of an application, e.g. "Open With Image Viewer"
            this._openButton.set_label(_("Open With %s").format(appInfo.get_display_name()));
        } catch (e) {
            // This happens when running under flatpak, since we don't have direct access
            // to the other applications
            if (!e.matches(Gio.IOErrorEnum, Gio.IOErrorEnum.NOT_SUPPORTED))
                logError(e, `Failed to query default handler for ${this.file.get_uri()}`);
            this._openButton.set_label(_("Open"));
        }
    }

    _onFileOpenClicked() {
        let ctx = this.get_display().get_app_launch_context();
        ctx.set_timestamp(Gtk.get_current_event_time());
        ctx.set_screen(this.get_screen());

        // Ideally we would use gtk_show_uri_on_window() here, since it properly
        // parents dialogs that may come from a flatpak portal over the window.
        //
        // Unfortunately we need to wait until the result of the launch before
        // destroying our window, which gtk_show_uri_on_window() doesn't allow,
        // so we use GIO directly.
        Gio.AppInfo.launch_default_for_uri_async(this.file.get_uri(), ctx, null, (obj, result) => {
            try {
                Gio.AppInfo.launch_default_for_uri_finish(result);
                this.destroy();
            } catch (e) {
                logError(e, `Failed to launch default handler for ${this.file.get_uri()}`);
            }
        });
    }
""",
    """    _getDefaultAppInfo() {
        // Local patch: GFile.query_default_handler() resolves to the handler
        // for the file:// URI scheme in this session (Dolphin) instead of the
        // application selected as the default for the file's content type.
        // Query the content type explicitly so we match Nautilus.
        let appInfo = null;

        if (this._contentType)
            appInfo = Gio.AppInfo.get_default_for_type(this._contentType, false);

        if (!appInfo && this._contentType) {
            let recommended = Gio.AppInfo.get_recommended_for_type(this._contentType);
            if (recommended.length > 0)
                appInfo = recommended[0];
        }

        return appInfo;
    }

    _onFileOpenClicked() {
        let appInfo;
        try {
            appInfo = this._getDefaultAppInfo();
        } catch (e) {
            logError(e, `Failed to query default handler for ${this.file.get_uri()}`);
            return;
        }

        if (!appInfo) {
            logError(new Error(`No default application for ${this._contentType}`),
                     `Failed to launch default handler for ${this.file.get_uri()}`);
            return;
        }

        let ctx = this.get_display().get_app_launch_context();
        ctx.set_timestamp(Gtk.get_current_event_time());
        ctx.set_screen(this.get_screen());

        try {
            appInfo.launch_uris([this.file.get_uri()], ctx);
            this.destroy();
        } catch (e) {
            logError(e, `Failed to launch default handler for ${this.file.get_uri()}`);
        }
    }
""",
)

replace(
    """        this.file = file;
        this._updateTitlebar();
        this._createRenderer();
""",
    """        this.file = file;
        this._contentType = null;
        this._createRenderer();
""",
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(src)
PY

# Install the patched JS modules. Sushi's pkg module prepends the resource
# path to imports.searchPath; the launcher below prepends this directory again
# afterwards so these files win over the packaged ones.
rm -rf "$DEST/ui" "$DEST/util" "$DEST/viewers"
cp -a "$TMP/js/." "$DEST/"

# Launcher. It must keep the entry-point name org.gnome.NautilusPreviewer:
# GJS derives the resource paths and the Gtk application ID from it.
mkdir -p "$(dirname "$LAUNCHER")"
cat > "$LAUNCHER" <<'EOF'
#!/usr/bin/gjs

const {GLib} = imports.gi;

imports.package.init({
    name: 'sushi',
    version: '46.0',
    prefix: '/usr',
    libdir: '/usr/lib/x86_64-linux-gnu',
});
imports.searchPath.unshift(GLib.build_filenamev([GLib.get_user_data_dir(), 'sushi-override']));
imports.package.run(imports.ui.main);
EOF
chmod 755 "$LAUNCHER"

# User D-Bus service overrides the system one in /usr/share/dbus-1/services.
mkdir -p "$(dirname "$SERVICE")"
cat > "$SERVICE" <<EOF
[D-BUS Service]
Name=org.gnome.NautilusPreviewer
Exec=$LAUNCHER
EOF

echo "Installed patched Sushi previewer."
echo "  modules: $DEST"
echo "  launcher: $LAUNCHER"
echo "  service:  $SERVICE"
