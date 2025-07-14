###BURN IT ALL LGHUB REMOVAL SCRIPT###
###YOUR SCREEN MIGHT GO BLACK, ITLL BE OKAY###



#!/bin/bash

echo "🔍 Stopping and removing Logitech G HUB components..."

# Kill running processes
echo "🛑 Killing running Logitech processes..."
pgrep -i logi | while read pid; do
    echo "Killing PID $pid"
    kill -9 "$pid"
done

# Remove main app
echo "🗑️ Removing /Applications/lghub.app..."
sudo rm -rf "/Applications/lghub.app"

# Remove supporting apps
echo "🗑️ Removing /Library/Application Support/Logitech and /Users/* equivalents..."
sudo rm -rf "/Library/Application Support/Logitech"
rm -rf "$HOME/Library/Application Support/Logitech"
rm -rf "$HOME/Library/Application Support/lghub"

# Remove launch agents/daemons
echo "🧹 Checking for launch agents/daemons..."
PLISTS=(
    "/Library/LaunchDaemons/com.logi.ghub.agent.plist"
    "/Library/LaunchAgents/com.logi.ghub.agent.plist"
    "$HOME/Library/LaunchAgents/com.logi.ghub.agent.plist"
    "$HOME/Library/LaunchAgents/com.logitech.gaming.plist"
)
for PLIST in "${PLISTS[@]}"; do
    if [ -f "$PLIST" ]; then
        echo "Unloading and removing: $PLIST"
        sudo launchctl bootout system "$PLIST" 2>/dev/null || launchctl bootout gui/$(id -u) "$PLIST" 2>/dev/null
        sudo rm -f "$PLIST"
    fi
done

# Remove binary traces
echo "🧽 Removing stray binaries..."
sudo rm -f "/usr/local/bin/lghub_agent"
sudo rm -f "/usr/local/bin/lghub_updater"
sudo rm -f "/usr/local/bin/lghub"

# Remove login items
echo "🔌 Removing login items..."
osascript -e 'tell application "System Events" to delete every login item whose name is "lghub_agent"'

# Remove launchctl leftovers
echo "🚿 Removing residual launchctl services..."
launchctl list | grep -i logi | while read line; do
    service=$(echo "$line" | awk '{print $3}')
    echo "Trying to remove service: $service"
    launchctl bootout gui/$(id -u) "$service" 2>/dev/null || sudo launchctl bootout system "$service" 2>/dev/null
done

# Remove remaining preferences and receipts
echo "🧼 Wiping preferences and receipts..."
rm -f "$HOME/Library/Preferences/com.logitech.*"
sudo rm -rf "/Library/Preferences/com.logitech.*"
sudo rm -rf "/private/var/db/receipts/com.logitech.*"

echo "✅ All known Logitech G HUB files have been removed."
echo "🔁 You may want to restart your Mac to ensure all services are gone."