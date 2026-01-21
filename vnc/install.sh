#!/bin/bash

# VNC and noVNC One-Click Installer (NON-INTERACTIVE)
# Supports Ubuntu/Debian systems

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
#echo -e "${BLUE}📺 Select VNC Resolution:${NC}"
#echo "1) 2560x1440  (2K/QHD - Recommended)"
#echo "2) 1920x1080  (Full HD)"
#echo "3) 3840x2160  (4K/UHD)"
#echo "4) 1366x768   (HD)"
#echo "5) 1280x720   (HD Ready)"
#echo "6) 1600x900   (HD+)"
#echo "7) 1024x768   (XGA)"
# ================= CONFIG =================
VNC_DISPLAY=":1"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"   # ✅ 默认 1080p
VNC_DEPTH="24"
VNC_PASSWORD="${VNC_PASSWORD:-vnc123456}"
NOVNC_PORT="${NOVNC_PORT:-6080}"
# ==========================================

print_header() {
    echo -e "${BLUE}"
    echo "==================================="
    echo "  VNC & noVNC Auto Installer"
    echo "==================================="
    echo -e "${NC}"
}

print_info()    { echo -e "${YELLOW}ℹ $1${NC}"; }
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Do NOT run as root"
        exit 1
    fi
}

detect_distro() {
    . /etc/os-release
    DISTRO=$ID
    DISTRO_VERSION=$VERSION_ID
}

install_packages() {
    print_info "Installing packages..."
    sudo apt update -y
    sudo apt install -y \
        tigervnc-standalone-server \
        xfce4 xfce4-goodies \
        xterm dbus-x11 \
        novnc websockify
    print_success "Packages installed"
}

setup_vnc_password() {
    print_info "Setting VNC password..."
    mkdir -p ~/.vnc
    echo "$VNC_PASSWORD" | tigervncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    print_success "VNC password configured"
}

create_startup_scripts() {
    print_info "Creating startup scripts..."

    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4 &
EOF
    chmod +x ~/.vnc/xstartup

    cat > ~/start-vnc-novnc.sh << EOF
#!/bin/bash
VNC_DISPLAY="$VNC_DISPLAY"
NOVNC_PORT="$NOVNC_PORT"

pgrep -f "Xtigervnc $VNC_DISPLAY" >/dev/null || \
    tigervncserver $VNC_DISPLAY -geometry $VNC_GEOMETRY -depth $VNC_DEPTH -xstartup ~/.vnc/xstartup

pgrep -f "websockify.*$NOVNC_PORT" >/dev/null || \
    websockify --web /usr/share/novnc/ $NOVNC_PORT localhost:5901 &
EOF
    chmod +x ~/start-vnc-novnc.sh

    cat > ~/stop-vnc-novnc.sh << EOF
#!/bin/bash
tigervncserver -kill $VNC_DISPLAY 2>/dev/null || true
pkill -f "websockify.*$NOVNC_PORT" || true
EOF
    chmod +x ~/stop-vnc-novnc.sh

    print_success "Scripts created"
}

start_services() {
    print_info "Starting services..."
    ~/start-vnc-novnc.sh
}

show_info() {
    IP=$(hostname -I | awk '{print $1}')
    echo ""
    echo -e "${GREEN}=== DONE ===${NC}"
    echo "Web:  http://$IP:$NOVNC_PORT/vnc.html"
    echo "VNC:  $IP:5901"
    echo "Pass: $VNC_PASSWORD"
    echo "Res:  $VNC_GEOMETRY"
}

main() {
    print_header
    check_root
    detect_distro

    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
        print_error "Only Ubuntu/Debian supported"
        exit 1
    fi

    print_info "Detected $DISTRO $DISTRO_VERSION"
    print_info "Using resolution $VNC_GEOMETRY"

    if ! command -v tigervncserver >/dev/null; then
        install_packages
        setup_vnc_password
        create_startup_scripts
    else
        print_info "VNC already installed, skipping install"
    fi

    start_services
    show_info
}

main "$@"
