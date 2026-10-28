# Sushi hacks

User-level override for GNOME Sushi (the Nautilus space-bar previewer).

It does two things:

- Removes Sushi's header bar / “Open With …” button, leaving an undecorated
  preview window.
- Makes the open action use the default application for the file's **content
  type** — the same thing Nautilus uses — instead of
  `GFile.query_default_handler()`.

The latter is necessary because on this machine `query_default_handler()`
resolves the `file://` URI-scheme handler (Dolphin) instead of the application
configured for the specific file type.

## Behaviour

| Key | Action |
| --- | --- |
| `Return` / `KP_Enter` | Open the previewed file with its per-type default app |
| `Escape`, `Space`, `q` | Close the preview |
| `f` / `F11` | Fullscreen |

The window has no title bar, so there is no close button. Move it with your
window manager (for example `Super` + drag in Hyprland).

## Install

Requires `gnome-sushi` plus `gjs`, `gresource`, and `python3` (all present on a
normal Debian/GNOME install). After cloning the dotfiles repo:

```bash
~/dotfiles/sushi-hacks/install.sh
```

The installer is idempotent. It:

1. symlinks `reapply.sh` and the GJS launcher into `$HOME`,
2. builds the patched Sushi JavaScript modules,
3. generates the D-Bus service file with this machine's `$HOME`,
4. reloads the session D-Bus configuration and stops any running previewer.

## Files

- `install.sh` — sets up the symlinks and runs `reapply.sh`.
- `reapply.sh` — extracts Sushi's JavaScript from the installed
  `org.gnome.NautilusPreviewer.src.gresource`, applies the patch, and writes
  the launcher and D-Bus service.
- `org.gnome.NautilusPreviewer` — GJS launcher. Its filename must stay
  `org.gnome.NautilusPreviewer`, because GJS derives the resource paths and
  application ID from the entry point name.

Live symlinks created by `install.sh`:

```text
~/.local/share/sushi-override/reapply.sh
    -> ~/dotfiles/sushi-hacks/reapply.sh

~/.local/libexec/org.gnome.NautilusPreviewer
    -> ~/dotfiles/sushi-hacks/org.gnome.NautilusPreviewer
```

Generated at runtime, not tracked in the repo:

```text
~/.local/share/sushi-override/ui/
~/.local/share/sushi-override/util/
~/.local/share/sushi-override/viewers/
~/.local/share/dbus-1/services/org.gnome.NautilusPreviewer.service
```

The D-Bus service is generated rather than tracked because its `Exec=` line
must contain an absolute path for the current user's home directory.

## Reapply after a Sushi upgrade

```bash
~/dotfiles/sushi-hacks/reapply.sh
```

Or run `install.sh` again to recreate the symlinks as well. Then, if needed:

```bash
dbus-send --session --type=method_call \
  --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig

pkill -f '^/usr/bin/gjs .*NautilusPreviewer'
```

## Default file handler

These were set so folders and `file://`/`sftp://` links open in Nautilus:

```bash
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime default org.gnome.Nautilus.desktop x-scheme-handler/file
xdg-mime default org.gnome.Nautilus.desktop x-scheme-handler/sftp
```

To send SFTP back to Dolphin:

```bash
xdg-mime default org.kde.dolphin.desktop x-scheme-handler/sftp
```

## Revert

```bash
rm -f ~/.local/share/sushi-override/reapply.sh \
      ~/.local/libexec/org.gnome.NautilusPreviewer \
      ~/.local/share/dbus-1/services/org.gnome.NautilusPreviewer.service

rm -rf ~/.local/share/sushi-override

dbus-send --session --type=method_call \
  --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig
```

Restore the default handlers with `xdg-mime default` if desired.
