#!/usr/bin/env bash

set -e

echo "Restoring GNOME keyboard shortcuts..."

# Restore Window Manager shortcuts
if [[ -f wm-shortcuts.dconf ]]; then
  dconf load /org/gnome/desktop/wm/keybindings/ < wm-shortcuts.dconf
  echo "✔ Window Manager shortcuts restored"
else
  echo "✖ wm-shortcuts.dconf not found"
fi

# Restore Media & Custom shortcuts
if [[ -f media-shortcuts.dconf ]]; then
  dconf load /org/gnome/settings-daemon/plugins/media-keys/ < media-shortcuts.dconf
  echo "✔ Media & custom shortcuts restored"
else
  echo "✖ media-shortcuts.dconf not found"
fi

# Restore Shell shortcuts
if [[ -f shell-shortcuts.dconf ]]; then
  dconf load /org/gnome/shell/keybindings/ < shell-shortcuts.dconf
  echo "✔ Shell shortcuts restored"
else
  echo "✖ shell-shortcuts.dconf not found"
fi

echo "Done."
