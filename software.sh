MAGENTA="\e[35m"
NC="\e[0m"

line() {
    echo "----------------------------------------"
}

    # Installed Packages
get_packages_info() {
    
    # Detect package manager
    if command -v dpkg &> /dev/null; then
        echo "  Package Manager: dpkg (Debian/Ubuntu)"
        echo "  Total packages: $(dpkg -l | wc -l)"
        echo ""
        echo "  Recently installed packages (last 10):"
        dpkg -l | tail -10 | awk '{print "    " $2 " - " $3}'
    elif command -v rpm &> /dev/null; then
        echo "  Package Manager: rpm (RedHat/Fedora)"
        echo "  Total packages: $(rpm -qa | wc -l)"
        echo ""
        echo "  Recently installed packages (last 10):"
        rpm -qa --last | head -10 | awk '{print "    " $0}'
    else
        echo "  Package manager not detected"
    fi
    line
}
collect_software() {
    echo -e "=====${MAGENTA} SOFTWARE INFO${NC} ====="

    echo "🔹 SYSTEM"
    uname -a

    echo "🔹 USERS"
    w
    echo "the number of users is : $(who | wc -l)"

    echo "🔹 PROCESSES"
    ps aux | head -10

    echo "🔹 INSTALLED PACKAGES"
    get_packages_info
}