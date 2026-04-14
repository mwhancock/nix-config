#!/usr/bin/env fish

echo "🚀 Starting Minisforum V3 Keybind & Session Rescue..."

set -l USER_ID (id -u)
set -gx DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/$USER_ID/bus"

echo "🛑 Killing system-level agents..."
sudo pkill -9 polkit; or true

echo "🛑 Killing user agents..."
pkill -9 mako; or true
pkill -9 dunst; or true
pkill -9 waybar; or true
pkill -f dms; or true
pkill -f matugen; or true

echo "🧹 Purging session locks..."
if test -d /run/user/$USER_ID/dconf
    sudo rm -rf /run/user/$USER_ID/dconf/*; or true
end
rm -f /run/user/$USER_ID/bus

# 💡 Give the system a second to breathe
echo "⏳ Waiting for cleanup..."
sleep 1

echo "🔄 Re-initializing systemd user manager..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user reset-failed

echo "✨ Starting dms.service (with 10s timeout)..."
# Using --no-block prevents the script from hanging if the daemon is slow to init
systemctl --user enable --now dms.service --wait --timeout=10s; or true

echo "🔍 Final check..."
if systemctl --user is-active --quiet dms.service
    echo "✅ Success! dms.service is running."
else
    echo "⚠️ Service is taking a while to start. Check it manually with:"
    echo "   systemctl --user status dms.service"
end
