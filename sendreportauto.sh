#!/bin/bash

# Source the hardware and software files
#source ./hardware.sh
#source ./software.sh
#echo "$(date): Script started" >> /home/fateh/project/cron_debug.log
#cd /home/fateh/project || echo "cd failed" >> /home/fateh/project/cron_debug.log
#!/bin/bash

# Use project folder for logs
LOG_DIR="$HOME/project/logs"
mkdir -p "$LOG_DIR"

# Log script start time
echo "$(date): Script started" >> "$LOG_DIR/cron_debug.log"

# Navigate to project folder (stop if fails)
cd "$HOME/project" || { echo "cd failed" >> "$LOG_DIR/cron_debug.log"; exit 1; }

# Rest of your code continues here...
# ============================================
# ERROR HANDLING & LOGGING
# ============================================

# Colors for terminal only
BOLD_CYAN="\e[1;36m"
BG_WHITE="\e[47m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

# Variables for report files
REPORTS_DIR="reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SHORT_REPORT="$REPORTS_DIR/short_report_$TIMESTAMP.html"
FULL_REPORT="$REPORTS_DIR/full_report_$TIMESTAMP.html"

# PDF versions paths
SHORT_PDF="$REPORTS_DIR/short_report_$TIMESTAMP.pdf"
FULL_PDF="$REPORTS_DIR/full_report_$TIMESTAMP.pdf"

# Email recipients
RECIPIENTS=(
    #"hamichfateh04@gmail.com"
    "fatehhammiche7@gmail.com"
    #"belarmas.abdelouahab@gmail.com"
)

# Log file
LOG_FILE="$REPORTS_DIR/audit_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p "$REPORTS_DIR"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Function to handle errors
error_exit() {
    log_message "ERROR" "$1"
    exit 1
}

# Check if required files exist
check_requirements() {
    log_message "INFO" "Checking requirements..."
    
    if [ ! -f "hardware.sh" ]; then
        error_exit "hardware.sh not found!"
    fi
    
    if [ ! -f "software.sh" ]; then
        error_exit "software.sh not found!"
    fi
    
    if ! command -v msmtp &> /dev/null; then
        error_exit "msmtp not installed!"
    fi
    
    log_message "INFO" "All requirements satisfied"
}

# Function to cleanup old reports (older than 30 days)
cleanup_old_reports() {
    log_message "INFO" "Cleaning up old reports (older than 30 days)..."
    find "$REPORTS_DIR" -name "*.html" -type f -mtime +30 -delete 2>/dev/null
    find "$REPORTS_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null
    log_message "INFO" "Cleanup completed"
}

# ============================================
# HTML TEMPLATE
# ============================================

# Function to generate HTML header
html_header() {
    local title="$1"
    cat << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title - $(date)</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .header p {
            opacity: 0.9;
            font-size: 14px;
        }
        .designer {
        text-align : left;
        }
        
        .content {
            padding: 30px;
        }
        
        .section {
            margin-bottom: 30px;
            background: #f8f9fa;
            border-radius: 10px;
            overflow: hidden;
            border-left: 4px solid #667eea;
        }
        
        .section-title {
            background: #e9ecef;
            padding: 15px 20px;
            font-size: 20px;
            font-weight: bold;
            color: #495057;
            border-bottom: 2px solid #dee2e6;
        }
        
        .section-content {
            padding: 20px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        
        th {
            background: #667eea;
            color: white;
            font-weight: 600;
        }
        
        tr:hover {
            background: #f1f3f5;
        }
        
        .alert {
            background: #ff4757;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        
        .success {
            background: #00b894;
            color: white;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        
        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        
        .footer {
            background: #2c3e50;
            color: white;
            text-align: center;
            padding: 20px;
            font-size: 12px;
        }
        
        pre {
            background: #2d3436;
            color: #dfe6e9;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            font-size: 13px;
        }
            @media print {
        body {
            background: white;
            padding: 0;
        }
        .header {
            background: #2c3e50;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }
        .alert, .success, .info-box {
            border: 1px solid #ccc;
            background: #f9f9f9;
            color: black;
        }
        pre {
            background: #f4f4f4;
            color: black;
            border: 1px solid #ddd;
        }

    }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$title</h1>
            <p><strong>Generated on:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>
            <p><strong>Hostname:</strong> $(hostname)</p>
            <div class="designer">
                <p><strong>Designed by :</strong></p>
                <ul>
                <li><em>Hammiche Fateh</em></li>
                <li><em>Belarmas Abdelouahab</em></li>
                </ul>
            </div>
        </div>
        <div class="content">
EOF
}

# Function to generate HTML footer
html_footer() {
    cat << EOF
        </div>
        <div class="footer">
            <p>System Report | Generated by Automation Tool</p>
        </div>
    </div>
</body>
</html>
EOF
}

# ============================================
# SHORT REPORT GENERATION
# ============================================

# Function to generate short HTML report
generate_short_report() {
    mkdir -p "$REPORTS_DIR"
    
    # Get system information
    OS_NAME=$(lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
    KERNEL=$(uname -r)
    HOSTNAME=$(hostname)
    
    # Get uptime in hours and minutes
    UPTIME_SEC=$(awk '{print $1}' /proc/uptime | cut -d'.' -f1)
    UPTIME_HOURS=$((UPTIME_SEC / 3600))
    UPTIME_MINUTES=$(((UPTIME_SEC % 3600) / 60))
    UPTIME="${UPTIME_HOURS} hours, ${UPTIME_MINUTES} minutes"
    
    # Get IP and MAC
    IP_ADDR=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1)
    MAC_ADDR=$(ip link show | grep -E "link/ether" | awk '{print $2}' | head -1)
    
    # Get GPU
    GPU=$(lspci | grep -E "VGA|3D|Display" | head -1 | cut -d':' -f3 | sed 's/^ //' || echo "No GPU detected")
    
    {
        html_header "SHORT SYSTEM REPORT"
        
        cat << EOF
            <div class="section">
                <div class="section-title">📊 SYSTEM INFORMATION</div>
                <div class="section-content">
                     <table>
                         <tr><th>OS</th><td>$OS_NAME</td></tr>
                         <tr><th>Kernel</th><td>$KERNEL</td></tr>
                         <tr><th>Uptime</th><td>$UPTIME</td></tr>
                         <tr><th>Hostname</th><td>$HOSTNAME</td></tr>
                     </table>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">📊 CPU Information</div>
                <div class="section-content">
                    <pre>$(lscpu | head -5)</pre>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">💾 Memory Usage</div>
                <div class="section-content">
                    <table>
                        $(free -h | awk 'NR==1 {print "                         <tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th></tr>"} NR==2 {print "                         <tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td></tr>"}')
                    </table>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">💿 Disk Usage</div>
                <div class="section-content">
                    <table>
                        $(df -h | head -5 | awk 'NR==1 {print "                         <tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$5"</th><th>"$6"</th></tr>"} NR>1 {print "                         <tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td></tr>"}')
                    </table>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">🔹 NETWORK</div>
                <div class="section-content">
                    <table>
                        <tr><th>IP Address</th><td>$IP_ADDR</td></tr>
                        <tr><th>MAC Address</th><td>$MAC_ADDR</td></tr>
                    </table>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">🎮 GPU</div>
                <div class="section-content">
                    <table>
                        <tr><th>Graphics Card</th><td>$GPU</td></tr>
                    </table>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">📈 TOP 5 PROCESSES (by CPU)</div>
                <div class="section-content">
                    <table>
                        <tr><th>#</th><th>Process</th><th>CPU%</th></tr>
                        $(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print "                         <tr><td>"NR"</td><td>"$11"</td><td>"$3"</td></tr>"}')
                    </table>
                </div>
            </div>
EOF
        
        html_footer
    } > "$SHORT_REPORT"
    
    log_message "INFO" "Short report saved to: $SHORT_REPORT"
    echo -e "${BOLD_CYAN}✓ Short HTML report saved to: $SHORT_REPORT${NC}"
}

# ============================================
# FULL REPORT GENERATION
# ============================================

# Function to generate full HTML report
generate_full_report() {
    mkdir -p "$REPORTS_DIR"
    
    CPU_USAGE=$(mpstat 1 1 | awk '/Average/ {print  100 - $NF }') # | cut -d'.' -f1)
    
    # System Information
    OS_NAME=$(lsb_release -ds 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
    KERNEL=$(uname -r)
    HOSTNAME=$(hostname)
    ARCH=$(uname -m)
    
    # Uptime Information
    UPTIME_SEC=$(awk '{print $1}' /proc/uptime | cut -d'.' -f1)
    UPTIME_HOURS=$((UPTIME_SEC / 3600))
    UPTIME_MINUTES=$(((UPTIME_SEC % 3600) / 60))
    UPTIME_DAYS=$((UPTIME_SEC / 86400))
    UPTIME_REMAINING=$((UPTIME_SEC % 86400))
    UPTIME_HOURS_REMAINING=$((UPTIME_REMAINING / 3600))
    UPTIME_MINUTES_REMAINING=$(((UPTIME_REMAINING % 3600) / 60))
    
    if [ $UPTIME_DAYS -gt 0 ]; then
        UPTIME="${UPTIME_DAYS} days, ${UPTIME_HOURS_REMAINING} hours, ${UPTIME_MINUTES_REMAINING} minutes"
    else
        UPTIME="${UPTIME_HOURS} hours, ${UPTIME_MINUTES} minutes"
    fi
    
    LAST_BOOT=$(who -b | awk '{print $3, $4}')
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}')
    
    # Network Information
    OPEN_PORTS=$(ss -tuln | grep -E "LISTEN" | head -10)
    CONNECTIONS=$(ss -tun | wc -l)
    
    # Performance
    IO_STATS=$(iostat 2>/dev/null | head -10 || echo "iostat not available")
    
    # Detailed Hardware
    BIOS_VERSION="VirtualBox"
    MOTHERBOARD_SERIAL="VirtualBox"
    
    # Detailed USB
    USB_DETAILS=$(lsusb -t 2>/dev/null || lsusb)
    
    {
        html_header "FULL SYSTEM REPORT"
        
        if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
            echo '<div class="alert">⚠️ ALERT: CPU usage is high! ('$CPU_USAGE'%)</div>'
        else
            echo '<div class="success">✅ CPU usage is normal ('$CPU_USAGE'%)</div>'
        fi
        
        cat << EOF
            <!-- SYSTEM OVERVIEW -->
            <div class="section">
                <div class="section-title">📊 SYSTEM OVERVIEW</div>
                <div class="section-content">
                    <table>
                        <tr><th>OS</th><td>$OS_NAME</td></tr>
                        <tr><th>Kernel</th><td>$KERNEL</td></tr>
                        <tr><th>Architecture</th><td>$ARCH</td></tr>
                        <tr><th>Hostname</th><td>$HOSTNAME</td></tr>
                        <tr><th>Uptime</th><td>$UPTIME</td></tr>
                        <tr><th>Last Boot</th><td>$LAST_BOOT</td></tr>
                        <tr><th>Load Average</th><td>$LOAD_AVG</td></tr>
                    </table>
                </div>
            </div>
            
            <!-- HARDWARE INFORMATION -->
            <div class="section">
                <div class="section-title">🖥️ HARDWARE INFORMATION</div>
                <div class="section-content">
                    <h3>🔹 CPU</h3>
                    <pre>$(lscpu | head -15)</pre>
                    
                    <h3>🔹 CPU USAGE</h3>
                    <div class="info-box">
                        Current Usage: <strong>$CPU_USAGE%</strong>
                    </div>
                    
                    <h3>🔹 RAM</h3>
                    <table>
                        $(free -h | awk 'NR==1 {print "                          <tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$5"</th><th>"$6"</th></tr>"} NR==2 {print "                          <tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td></tr>"}')
                    </table>
                    
                    <h3>🔹 DISK</h3>
                    <table>
                        $(df -h | head -10 | awk 'NR==1 {print "                          <tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$5"</th><th>"$6"</th></tr>"} NR>1 {print "                          <tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$5"</td><td>"$6"</td></tr>"}')
                    </table>
                    
                    <h3>🔹 MOTHERBOARD & BIOS</h3>
                    <table>
                        <tr><th>BIOS Version</th><td>$BIOS_VERSION</td></tr>
                        <tr><th>Motherboard Serial</th><td>$MOTHERBOARD_SERIAL</td></tr>
                    </table>
                    
                    <h3>🔹 GPU</h3>
                    <pre>$(lspci | grep -E "VGA|3D|Display" || echo "No GPU detected")</pre>
                    
                    <h3>🔹 USB DEVICES</h3>
                    <pre>$USB_DETAILS</pre>
                    
                    <h3>🔹 MAC ADDRESSES</h3>
                    <pre>$(ip link show | grep -E "link/ether" | awk '{print $2 " - " $NF}' || echo "No MAC addresses found")</pre>
                </div>
            </div>
            
            <!-- NETWORK INFORMATION -->
            <div class="section">
                <div class="section-title">🌐 NETWORK INFORMATION</div>
                <div class="section-content">
                    <h3>🔹 Network Interfaces</h3>
                    <pre>$(ip a | grep -E "^[0-9]|inet ")</pre>
                    
                    <h3>🔹 Open Ports (LISTEN)</h3>
                    <pre>$OPEN_PORTS</pre>
                    
                    <h3>🔹 Active Connections</h3>
                    <div class="info-box">
                        Total active connections: <strong>$CONNECTIONS</strong>
                    </div>
                </div>
            </div>
            
            <!-- SOFTWARE INFORMATION -->
            <div class="section">
                <div class="section-title">💻 SOFTWARE INFORMATION</div>
                <div class="section-content">
                    <h3>🔹 SYSTEM</h3>
                    <pre>$(uname -a)</pre>
                    
                    <h3>🔹 USERS</h3>
                    <pre>$(w)</pre>
                    <div class="info-box">
                        Number of users: <strong>$(who | wc -l)</strong>
                    </div>
                    
                    <h3>🔹 INSTALLED PACKAGES</h3>
                    <pre>$(dpkg -l 2>/dev/null | head -15 || rpm -qa 2>/dev/null | head -15 || echo "Package list not available")</pre>
                    <div class="info-box">
                        Total packages: <strong>$(dpkg -l 2>/dev/null | wc -l || rpm -qa 2>/dev/null | wc -l)</strong>
                    </div>
                </div>
            </div>
            
            <!-- PERFORMANCE & PROCESSES -->
            <div class="section">
                <div class="section-title">⚡ PERFORMANCE & PROCESSES</div>
                <div class="section-content">
                    <h3>🔹 TOP 15 PROCESSES (by CPU)</h3>
                    <table>
                        $(ps aux --sort=-%cpu | head -10 | awk 'NR==1 {print "<tr><th>"$1"</th><th>"$2"</th><th>"$3"</th><th>"$4"</th><th>"$11"</th></tr>"} NR>1 {print "<tr><td>"$1"</td><td>"$2"</td><td>"$3"</td><td>"$4"</td><td>"$11"</td></tr>"}')
                    </table>
                    
                    <h3>🔹 I/O Statistics</h3>
                    <pre>$IO_STATS</pre>
                </div>
            </div>
            
            <!-- SECURITY INFORMATION -->
            <div class="section">
                <div class="section-title">🔒 SECURITY INFORMATION</div>
                <div class="section-content">
                    <h3>🔹 Current User</h3>
                    <pre>$(whoami)</pre>
                    
                    <h3>🔹 Logged-in Users</h3>
                    <pre>$(who)</pre>
                    
                    <h3>🔹 Last Logins (last 5)</h3>
                    <pre>$(last -n 5 2>/dev/null || echo "No login history")</pre>
                    
                    <h3>🔹 Active SSH Connections</h3>
                    <pre>$(ss -tun | grep :22 | wc -l) active SSH connections</pre>
                    
                    <h3>🔹 Running Services</h3>
                    <pre>$(systemctl list-units --type=service --state=running | head -10)</pre>
                </div>
            </div>
EOF
        
        html_footer
    } > "$FULL_REPORT"
    
    log_message "INFO" "Full report saved to: $FULL_REPORT"
    echo -e "${BOLD_CYAN}✓ Full HTML report saved to: $FULL_REPORT${NC}"
}
# ============================================
# EMAIL FUNCTION
# ============================================

# Function to send email
send_email() {
    local recipient="$1"
    local report_type="$2"
    local report_file="$3"
    
    if [ -f "$report_file" ]; then
        {
            echo "MIME-Version: 1.0"
            echo "Content-Type: text/html; charset=utf-8"
            echo "Subject: System Report - $report_type ($(date '+%Y-%m-%d %H:%M'))"
            echo "From: system@$(hostname)"
            echo "To: $recipient"
            echo
            cat "$report_file"
        } | msmtp "$recipient"
        
        log_message "SUCCESS" "$report_type report sent to $recipient"
        echo -e "${GREEN}✓ $report_type report sent to $recipient${NC}"
    else
        log_message "ERROR" "Report file not found: $report_file"
        echo -e "${RED}✗ Report file not found: $report_file${NC}"
    fi
}
# ============================================
# PDF CONVERSION MODULE (USING WEASYPRINT)
# ============================================
convert_to_pdf() {
    local input_html="$1"
    local output_pdf="$2"

    # Check if weasyprint is installed
    if command -v weasyprint &> /dev/null; then
        log_message "INFO" "Converting $(basename "$input_html") to PDF..."
        
        # Execute conversion
        weasyprint "$input_html" "$output_pdf" &> /dev/null
        
        if [ $? -eq 0 ]; then
            log_message "SUCCESS" "PDF successfully generated: $output_pdf"
            echo -e "${GREEN}✓ PDF report saved to: $output_pdf${NC}"
        else
            log_message "ERROR" "Failed to generate PDF using WeasyPrint"
        fi
    else
        log_message "WARNING" "WeasyPrint not found. Skipping PDF generation."
    fi
}

# ============================================
# MAIN EXECUTION
# ============================================

log_message "INFO" "========== SYSTEM AUDIT STARTED =========="

# Check requirements
check_requirements

# Create reports directory
mkdir -p "$REPORTS_DIR"

echo ""
echo -e "${BOLD_CYAN}=========================================${NC}"
echo -e "${BOLD_CYAN}     SYSTEM REPORT - AUTO SEND${NC}"
echo -e "${BOLD_CYAN}=========================================${NC}"
echo "Date: $(date)"
echo ""

# Generate reports
generate_short_report
convert_to_pdf "$SHORT_REPORT" "$SHORT_PDF"
generate_full_report 
convert_to_pdf "$FULL_REPORT" "$FULL_PDF" 

echo ""
echo "Sending reports via email..."
echo "-----------------------------------------"

# Send to all recipients
for recipient in "${RECIPIENTS[@]}"; do
    echo "Sending to: $recipient"
    send_email "$recipient" "Short" "$SHORT_REPORT"
    send_email "$recipient" "Full" "$FULL_REPORT"
done

# Cleanup old reports
cleanup_old_reports

log_message "INFO" "========== SYSTEM AUDIT COMPLETED =========="

echo ""
echo -e "${BOLD_CYAN}=========================================${NC}"
echo -e "${GREEN}✓ All reports sent successfully!${NC}"
echo -e "${BOLD_CYAN}=========================================${NC}"
