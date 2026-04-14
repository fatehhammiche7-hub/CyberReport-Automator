RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
MAGENTA="\e[35m"
NC="\e[0m"

# line separator
line() {
    echo "----------------------------------------"
}

# get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}
# GPU Information
get_gpu_info() {
    lspci | grep -E "VGA|3D|Display" || echo "  No GPU detected"
    line
}

# Motherboard Information
get_motherboard_info() {
    if [ -r /sys/class/dmi/id/board_vendor ]; then
        echo "  Vendor: $(cat /sys/class/dmi/id/board_vendor 2>/dev/null || echo "N/A")"
        echo "  Model: $(cat /sys/class/dmi/id/board_name 2>/dev/null || echo "N/A")"
        echo "  Version: $(cat /sys/class/dmi/id/board_version 2>/dev/null || echo "N/A")"
        echo "  Serial: $(cat /sys/class/dmi/id/board_serial 2>/dev/null || echo "N/A")"
    else
        echo "  Motherboard info: Not available (run with sudo for details)"
    fi
    line
}

# USB Devices
get_usb_info() {
    lsusb | head -10 || echo "  No USB devices detected"
    local usb_count=$(lsusb | wc -l)
    echo "  Total USB devices: $usb_count"
    line
}

# MAC Address
get_mac_info() {
    ip link show | grep -E "link/ether" | awk '{print "  " $2 " - " $NF}' || echo "  No MAC addresses found"
    line
}

# check alert
check_cpu_alert() {
    CPU=$(get_cpu_usage) # | cut -d'.' -f1)

    if [ "$CPU" -gt 80 ]; then
        echo -e "${RED}⚠️ ALERT${NC}:${YELLOW} CPU usage is high!${NC} ($CPU%)"
    else
        echo -e "${GREEN}✅ CPU usage is normal${NC} ($CPU%)"
    fi
}

# main hardware function
collect_hardware() {
    echo -e "=====${MAGENTA} HARDWARE INFO${NC} ====="
    line        #this make a line after each information

    echo "🔹 CPU"
    lscpu | head -5
    line

    echo "🔹 CPU USAGE"
    check_cpu_alert
    line

    echo "🔹 RAM"
    free -h
    line

    echo "🔹 DISK"
    df -h | head -5
    line

    echo "🔹 NETWORK"
    ip a | grep inet
    line

    echo "🔹 GPU"
    get_gpu_info
    
    echo "🔹 MOTHERBOARD"
    get_motherboard_info
    
    echo "🔹 USB DEVICES"
    get_usb_info
    
    echo "🔹 MAC ADDRESSES"
    get_mac_info
}