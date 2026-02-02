#!/bin/bash

APP_DIR="$HOME/Applications/Coffee.app"
LAUNCHAGENT="$HOME/Library/LaunchAgents/com.local.coffee.plist"

echo "Uninstalling Coffee..."

# Stop the app if running
pkill -f "Coffee.app/Contents/MacOS/Coffee" 2>/dev/null || true
pkill -x Coffee 2>/dev/null || true

# Kill any caffeinate processes started by Coffee
pkill caffeinate 2>/dev/null || true

# Remove launch agent if exists
if [ -f "$LAUNCHAGENT" ]; then
    launchctl unload "$LAUNCHAGENT" 2>/dev/null || true
    rm "$LAUNCHAGENT"
    echo "✓ Removed launch agent"
fi

# Remove app bundle
if [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo "✓ Removed Coffee.app from ~/Applications/"
else
    echo "○ Coffee.app not found in ~/Applications/"
fi

echo ""
echo "Uninstall complete."
echo ""
echo "Note: If installed via Homebrew, use: brew uninstall coffee"
