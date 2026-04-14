BOLD_CYAN="\e[1;36m"
BG_WHITE="\e[47m"
BG_RED="\e[41m"
NC="\e[0m"

generate_short_report() {
    echo -e "=====${BG_WHITE}${BOLD_CYAN}SHORT REPORT${NC} =====" > $SHORT_REPORT
    echo "Date: $(date)" >> $SHORT_REPORT

    echo "--- CPU ---" >> $SHORT_REPORT
    lscpu | head -5 >> $SHORT_REPORT

    echo "--- RAM ---" >> $SHORT_REPORT
    free -h | head -2 >> $SHORT_REPORT

    echo "--- DISK ---" >> $SHORT_REPORT
    df -h | head -5 >> $SHORT_REPORT
}

generate_report() {
    mkdir -p reports

    echo -e "=====${BG_WHITE}${BOLD_CYAN}SYSTEM REPORT${NC} =====" > $FULL_REPORT
    echo "Date: $(date)" >> $FULL_REPORT
    echo "Hostname: $(hostname)" >> $FULL_REPORT

    echo "" >> $FULL_REPORT
    collect_hardware >> $FULL_REPORT

    echo "" >> $FULL_REPORT
    collect_software >> $FULL_REPORT

    generate_short_report
    #mail -s "System Report" fatehhammiche7@gmail.com < $FULL_REPORT
}