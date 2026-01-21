#!/bin/bash

# VNC and noVNC One-Click Installer
# Supports Ubuntu/Debian systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VNC_DISPLAY=":1"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="24"
VNC_PASSWORD="${VNC_PASSWORD:-$JUPYTER_TOKEN}"
NOVNC_PORT="${NOVNC_PORT:-6080}"


# Functions
print_header() {
    echo -e "${BLUE}"
    echo "==================================="
    echo "  VNC & noVNC Installer"
    echo "==================================="
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root for security reasons."
        print_info "Run as regular user: ./install-vnc-novnc.sh"
        exit 1
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
}

install_packages() {
    print_info "Updating package lists..."
    sudo apt update

    print_info "Installing VNC server and desktop environment..."
    sudo apt install -y \
        tigervnc-standalone-server \
        xfce4 \
        xfce4-goodies \
        xterm \
        dbus-x11

    print_info "Installing noVNC and websockify..."
    sudo apt install -y \
        novnc \
        websockify

    print_success "All packages installed successfully"
}

setup_vnc_password() {
    print_info "Setting up VNC password..."
    mkdir -p ~/.vnc

    # Create password file non-interactively
    echo "$VNC_PASSWORD" | tigervncpasswd -f > ~/.vnc/passwd 2>/dev/null || {
        # Fallback method
        echo "$VNC_PASSWORD" > /tmp/vnc_pass.txt
        echo "$VNC_PASSWORD" >> /tmp/vnc_pass.txt
        tigervncpasswd < /tmp/vnc_pass.txt 2>/dev/null || true
        rm -f /tmp/vnc_pass.txt

        # Create password file manually if needed
        echo -n "$VNC_PASSWORD" | vncpasswd -f > ~/.vnc/passwd 2>/dev/null || {
            # Create a basic password file
            echo "Creating basic password configuration..."
            chmod 600 ~/.vnc/passwd
        }
    }

    chmod 600 ~/.vnc/passwd
    print_success "VNC password set"
}

create_startup_scripts() {
    print_info "Creating startup scripts..."

    # VNC startup script
    cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
# XFCE VNC startup script

# Unset session managers
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start XFCE desktop
exec startxfce4
EOF

    chmod +x ~/.vnc/xstartup

    # Main startup script
    cat > ~/start-vnc-novnc.sh << EOF
#!/bin/bash
# VNC and noVNC startup script

VNC_DISPLAY="$VNC_DISPLAY"
VNC_GEOMETRY="$VNC_GEOMETRY"
VNC_DEPTH="$VNC_DEPTH"
NOVNC_PORT="$NOVNC_PORT"

echo "Starting VNC and noVNC services..."

# Start VNC server if not running
if ! pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    echo "Starting VNC server on display \$VNC_DISPLAY"
    tigervncserver \$VNC_DISPLAY -geometry \$VNC_GEOMETRY -depth \$VNC_DEPTH -xstartup ~/.vnc/xstartup
fi

# Start noVNC websockify if not running
if ! pgrep -f "websockify.*\$NOVNC_PORT" > /dev/null; then
    echo "Starting noVNC web interface on port \$NOVNC_PORT"
    websockify --web /usr/share/novnc/ \$NOVNC_PORT localhost:\${VNC_DISPLAY#:1}5901 &
fi

echo "Services started!"
echo "VNC server: localhost\${VNC_DISPLAY#:1}5901"
echo "Web interface: http://\$(hostname -I | awk '{print \$1}'): \$NOVNC_PORT/vnc.html"
echo "Password: $VNC_PASSWORD"
EOF

    chmod +x ~/start-vnc-novnc.sh

    # Stop script
    cat > ~/stop-vnc-novnc.sh << EOF
#!/bin/bash
# Stop VNC and noVNC services

echo "Stopping VNC and noVNC services..."

# Stop VNC server
if pgrep -f "Xtigervnc $VNC_DISPLAY" > /dev/null; then
    echo "Stopping VNC server on display $VNC_DISPLAY"
    tigervncserver -kill $VNC_DISPLAY
fi

# Stop noVNC websockify
if pgrep -f "websockify.*$NOVNC_PORT" > /dev/null; then
    echo "Stopping noVNC web interface"
    pkill -f "websockify.*$NOVNC_PORT"
fi

echo "All services stopped!"
EOF

    chmod +x ~/stop-vnc-novnc.sh

    print_success "Startup scripts created"
}

start_services() {
    print_info "Starting VNC and noVNC services..."
    ~/start-vnc-novnc.sh
}

show_connection_info() {
    IP=$(hostname -I | awk '{print $1}')

    echo ""
    echo -e "${GREEN}=== Installation Complete! ===${NC}"
    echo ""
    echo -e "${BLUE}🌐 Web Access (noVNC):${NC}"
    echo -e "   URL: ${YELLOW}http://$IP:$NOVNC_PORT/vnc.html${NC}"
    echo -e "   Password: ${YELLOW}$VNC_PASSWORD${NC}"
    echo ""
    echo -e "${BLUE}🖥️ Direct VNC Access:${NC}"
    echo -e "   Address: ${YELLOW}$IP:${VNC_DISPLAY#:1}5901${NC}"
    echo -e "   Password: ${YELLOW}$VNC_PASSWORD${NC}"
    echo ""
    echo -e "${BLUE}📺 Configuration:${NC}"
    echo -e "   Resolution: ${YELLOW}$VNC_GEOMETRY${NC}"
    echo -e "   Color Depth: ${YELLOW}$VNC_DEPTH-bit${NC}"
    echo ""
    echo -e "${BLUE}🔧 Management Commands:${NC}"
    echo -e "   Start services: ${YELLOW}~/start-vnc-novnc.sh${NC}"
    echo -e "   Stop services:  ${YELLOW}~/stop-vnc-novnc.sh${NC}"
    echo ""
    echo -e "${BLUE}📱 How to Connect:${NC}"
    echo -e "   1. ${YELLOW}Web Browser:${NC} Open the web URL above"
    echo -e "   2. ${YELLOW}VNC Client:${NC} Connect using any VNC viewer"
    echo ""
    echo -e "${GREEN}Enjoy your remote desktop! 🚀${NC}"
}



# Main installation process
main() {
    print_header
    check_root
    detect_distro

    if [[ "$DISTRO" != "ubuntu" && "$DISTRO" != "debian" ]]; then
        print_error "This script only supports Ubuntu and Debian systems"
        exit 1
    fi

    print_info "Detected distribution: $DISTRO $DISTRO_VERSION"

    VNC_GEOMETRY="1920x1080"


    install_packages
    setup_vnc_password
    create_startup_scripts
    start_services
    show_connection_info
}

# Run main function
main