#!/usr/bin/env bash
#
# Install the headerless Sushi override for the current user.
#
# Creates the user-level symlinks, builds the patched Sushi modules, and
# generates the D-Bus service file for this machine's $HOME.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
OVERRIDE_DIR="$DATA_HOME/sushi-override"
LAUNCHER="$HOME/.local/libexec/org.gnome.NautilusPreviewer"
SERVICE="$DATA_HOME/dbus-1/services/org.gnome.NautilusPreviewer.service"

for cmd in gjs gresource python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "error: required command not found: $cmd" >&2
        exit 1
    fi
done

mkdir -p "$OVERRIDE_DIR" "$(dirname "$LAUNCHER")" "$(dirname "$SERVICE")"

chmod 755 "$REPO_DIR/reapply.sh" "$REPO_DIR/org.gnome.NautilusPreviewer"

# Scripts stay in the repo; live paths are symlinks to them.
ln -sfn "$REPO_DIR/reapply.sh" "$OVERRIDE_DIR/reapply.sh"
ln -sfn "$REPO_DIR/org.gnome.NautilusPreviewer" "$LAUNCHER"

# Build the patched modules and generate the D-Bus service.
"$OVERRIDE_DIR/reapply.sh"

# Make sure the next preview uses the new launcher and D-Bus service.
pkill -f '^/usr/bin/gjs .*NautilusPreviewer' 2>/dev/null || true
dbus-send --session --type=method_call \
    --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig 2>/dev/null || true

echo
echo "Sushi override installed."
echo "  repo:     $REPO_DIR"
echo "  modules:  $OVERRIDE_DIR"
echo "  launcher: $LAUNCHER -> $REPO_DIR/org.gnome.NautilusPreviewer"
echo "  service:  $SERVICE (generated)"
