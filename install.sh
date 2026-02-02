#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$HOME/Applications/Coffee.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCHAGENT="$LAUNCHAGENT_DIR/com.local.coffee.plist"

show_help() {
    echo "Coffee - macOS menu bar caffeinate toggle"
    echo ""
    echo "Usage: ./install.sh [command]"
    echo ""
    echo "Commands:"
    echo "  install     Build and install Coffee.app (default)"
    echo "  service     Install and enable as login service"
    echo "  unservice   Disable and remove login service"
    echo "  start       Start the service now"
    echo "  stop        Stop the service now"
    echo "  status      Check if service is running"
    echo "  help        Show this help message"
}

build_app() {
    echo "Building Coffee..."
    cd "$SCRIPT_DIR"
    swift build -c release
}

install_app() {
    build_app
    
    echo "Installing to ~/Applications/..."
    mkdir -p "$MACOS_DIR"
    mkdir -p "$RESOURCES_DIR"

    cp .build/release/Coffee "$MACOS_DIR/"

    cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Coffee</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.coffee</string>
    <key>CFBundleName</key>
    <string>Coffee</string>
    <key>CFBundleDisplayName</key>
    <string>Coffee</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

    echo "✓ Coffee.app installed to ~/Applications/"
}

install_service() {
    if [ ! -d "$APP_DIR" ]; then
        install_app
    fi
    
    echo "Installing launch agent..."
    mkdir -p "$LAUNCHAGENT_DIR"
    
    cat > "$LAUNCHAGENT" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.coffee</string>
    <key>ProgramArguments</key>
    <array>
        <string>$APP_DIR/Contents/MacOS/Coffee</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

    launchctl load "$LAUNCHAGENT"
    echo "✓ Service installed and enabled"
    echo "  Coffee will start automatically at login"
}

uninstall_service() {
    if [ -f "$LAUNCHAGENT" ]; then
        launchctl unload "$LAUNCHAGENT" 2>/dev/null || true
        rm "$LAUNCHAGENT"
        echo "✓ Service removed"
    else
        echo "Service not installed"
    fi
}

start_service() {
    if [ -f "$LAUNCHAGENT" ]; then
        launchctl load "$LAUNCHAGENT" 2>/dev/null || true
        echo "✓ Service started"
    elif [ -d "$APP_DIR" ]; then
        open "$APP_DIR"
        echo "✓ Coffee.app started"
    else
        echo "Coffee not installed. Run: ./install.sh install"
        exit 1
    fi
}

stop_service() {
    pkill -f "Coffee.app/Contents/MacOS/Coffee" 2>/dev/null || true
    pkill -x Coffee 2>/dev/null || true
    echo "✓ Service stopped"
}

check_status() {
    if pgrep -f "Coffee" > /dev/null 2>&1; then
        echo "● Coffee is running"
        if pgrep caffeinate > /dev/null 2>&1; then
            echo "  └─ Caffeinate is active"
        else
            echo "  └─ Caffeinate is inactive"
        fi
    else
        echo "○ Coffee is not running"
    fi
    
    if [ -f "$LAUNCHAGENT" ]; then
        echo "✓ Service is installed (starts at login)"
    else
        echo "○ Service not installed"
    fi
}

# Main
case "${1:-install}" in
    install)
        install_app
        echo ""
        echo "To run now:        open ~/Applications/Coffee.app"
        echo "To add as service: ./install.sh service"
        ;;
    service)
        install_service
        ;;
    unservice)
        uninstall_service
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    status)
        check_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
