#!/bin/bash
# VNC + noVNC + Google Chrome (FULL AUTO, NON-INTERACTIVE)
# Ubuntu / Debian 24.04+

set -e

# ========= COLORS =========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ========= CONFIG =========
VNC_DISPLAY=":1"
VNC_GEOMETRY="1920x1080"
VNC_DEPTH="24"
VNC_PASSWORD="${VNC_PASSWORD:-vnc123456}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
# ==========================

print_info()    { echo -e "${YELLOW}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }

print_header() {
    echo -e "${BLUE}"
    echo "==================================="
    echo "  VNC + noVNC + Chrome Auto Install"
    echo "==================================="
    echo -e "${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do NOT run as root"
        exit 1
    fi
}

detect_distro() {
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
}

install_packages() {
    print_info "Installing system packages..."
    sudo apt update -y
    sudo apt install -y \
        tigervnc-standalone-server \
        xfce4 xfce4-goodies \
        xterm dbus-x11 \
        novnc websockify \
        wget
    print_success "System packages installed"
}

install_google_chrome() {
    print_info "Installing Google Chrome..."

    if command -v google-chrome >/dev/null; then
        print_info "Google Chrome already installed"
        return
    fi

    wget -q -O /tmp/chrome.deb \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

    sudo apt install -y /tmp/chrome.deb
    rm -f /tmp/chrome.deb

    print_success "Google Chrome installed"
}

setup_vnc_password() {
    print_info "Configuring VNC password..."
    mkdir -p ~/.vnc
    echo "$VNC_PASSWORD" | tigervncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    print_success "VNC password ready"
}

create_startup_scripts() {
    print_info "Creating VNC startup scripts..."

    # ===== xstartup =====
    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

startxfce4 &
sleep 5

google-chrome \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --start-maximized &
EOF
    chmod +x ~/.vnc/xstartup

    # ===== start script =====
    cat > ~/start-vnc-novnc.sh << EOF
#!/bin/bash

VNC_DISPLAY=":1"
NOVNC_PORT="$NOVNC_PORT"

# Start VNC (NO INTERACTIVE PASSWORD)
pgrep -f "Xtigervnc \$VNC_DISPLAY" >/dev/null || \
tigervncserver \$VNC_DISPLAY \
  -geometry $VNC_GEOMETRY \
  -depth $VNC_DEPTH \
  -xstartup ~/.vnc/xstartup \
  -Passwd ~/.vnc/passwd

# Start noVNC
pgrep -f "websockify.*\$NOVNC_PORT" >/dev/null || \
websockify --web /usr/share/novnc/ \$NOVNC_PORT localhost:5901 &
EOF
    chmod +x ~/start-vnc-novnc.sh

    # ===== stop script =====
    cat > ~/stop-vnc-novnc.sh << EOF
#!/bin/bash
tigervncserver -kill :1 2>/dev/null || true
pkill -f "websockify.*$NOVNC_PORT" || true
EOF
    chmod +x ~/stop-vnc-novnc.sh

    print_success "Startup scripts created"
}

start_services() {
    print_info "Starting VNC & noVNC..."
    ~/start-vnc-novnc.sh
}

show_info() {
    IP=$(hostname -I | awk '{print $1}')
    echo ""
    echo -e "${GREEN}=== INSTALLATION COMPLETE ===${NC}"
    echo "Web  : http://$IP:$NOVNC_PORT/vnc.html"
    echo "VNC  : $IP:5901"
    echo "Pass : $VNC_PASSWORD"
    echo "Res  : $VNC_GEOMETRY"
}

main() {
    print_header
    check_root
    detect_distro

    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
        print_error "Only Ubuntu/Debian supported"
        exit 1
    fi

    print_info "Detected $DISTRO $VERSION"

    if ! command -v tigervncserver >/dev/null; then
        install_packages
        install_google_chrome
        setup_vnc_password
        create_startup_scripts
    else
        print_info "VNC already installed, skipping package install"
    fi

    start_services
    show_info
}

main "$@"
