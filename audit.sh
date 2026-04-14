#!/bin/bash

source config.sh
source report.sh
source hardware.sh
source software.sh

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NC="\e[0m"

send_email_full() {
    mail -s "System Full Report" fatehhammiche7@gmail.com < $FULL_REPORT
}
send_email_short() {
    mail -s "System Short Report" fatehhammiche7@gmail.com < $SHORT_REPORT
}

echo -e "${GREEN}=== SYSTEM AUDIT TOOL ===${NC}"

select option in "Full Report" "Short Report" "Exit"
do
    case $option in
        "Full Report")
            generate_report
            echo -e "${GREEN}✅ Full report generated${NC}"
            echo "do you want to open the full report?"
        while true ;
        do
            read -p "$(echo -e "${GREEN}[yes/y]${NC} or ${RED}[no]${NC}:")" choice
            choice=$(echo "$choice" | tr 'A-Z' 'a-z')
            case "$choice" in
                yes|y)
                #if [[ "$choice" == "yes" || "$choice" == "y" ]];then
                cat ./reports/full_report.txt
                send_email_full
                break
                ;;
                no)
                break
                ;;
                *)
                echo -e "${YELLOW}Invalid option , Try again${NC}"
                ;;
            esac
        done
            ;;
        "Short Report")
            generate_short_report
            echo -e "${GREEN}✅ Short report generated${NC}"
            echo "do you want to open the short report?"
        while true ;
        do
            read -p "$(echo -e "${GREEN}[yes/y]${NC} or ${RED}[no]${NC}:")" choice
            choice=$(echo "$choice" | tr 'A-Z' 'a-z')
            case "$choice" in
                yes|y)
                #if [[ "$choice" == "yes" || "$choice" == "y" ]];then
                cat ./reports/short_report.txt
                send_email_short
                break
                ;;
                no)
                break
                ;;
                *)
                echo -e "${YELLOW}Invalid option , Try again${NC}"
                ;;
            esac
        done
        ;;
        "Exit")
            echo -e "${RED}Exiting...${NC}"
            break
            ;;
        *)
            echo -e "${YELLOW}Invalid option${NC}"
            ;;
    esac
done
#crontab -e : the command that is used in the automation
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
BLACK="\e[30m"
BOLD_BLACK="\e[1;30m"
BOLD_RED="\e[1;31m"
BOLD_GREEN="\e[1;32m"
BOLD_YELLOW="\e[1;33m"
BOLD_BLUE="\e[1;34m"
BOLD_MAGENTA="\e[1;35m"
BOLD_CYAN="\e[1;36m"
BOLD_WHITE="\e[1;37m"
#background colors
BG_BLACK="\e[40m"
BG_RED="\e[41m"
BG_GREEN="\e[42m"
BG_YELLOW="\e[43m"
BG_BLUE="\e[44m"
BG_MAGENTA="\e[45m"
BG_CYAN="\e[46m"
BG_WHITE="\e[47m"