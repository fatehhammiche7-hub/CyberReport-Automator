#!/bin/bash

# ============================================
# Remote Audit Automation Script
# ============================================

# Configuration
REMOTE_USER="fateh_hammiche"
REMOTE_HOST="10.0.2.15"
REMOTE_SCRIPT="/home/fateh_hammiche/project/sendreportauto.sh"

# Local directories
REPORT_DIR="$HOME/project/remote_reports"
LOG_DIR="$HOME/project/logs"

mkdir -p "$REPORT_DIR" "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Log start
echo "$(date): Remote audit started" >> "$LOG_DIR/cron_debug.log"

# Step 1: Check if script exists
echo "[1] Checking if script exists on Ubuntu..."
if ssh $REMOTE_USER@$REMOTE_HOST "[ -f $REMOTE_SCRIPT ]"; then
    echo "[✓] Script found on Ubuntu"
else
    echo "[!] Script not found. Copying to Ubuntu..."
    scp "$HOME/project/sendreportauto.sh" $REMOTE_USER@$REMOTE_HOST:$REMOTE_SCRIPT
    ssh $REMOTE_USER@$REMOTE_HOST "chmod +x $REMOTE_SCRIPT"
    echo "[✓] Script installed on Ubuntu"
fi
# [1.1] Dependency Check: Ensure WeasyPrint is installed on the remote Ubuntu machine
# This ensures PDF conversion works before the script runs
echo "[1.1] Checking for WeasyPrint dependency on Ubuntu..."
ssh $REMOTE_USER@$REMOTE_HOST "command -v weasyprint >/dev/null 2>&1 || (echo 'Installing WeasyPrint...' && sudo apt update && sudo apt install -y weasyprint)"

if [ $? -eq 0 ]; then
    echo "[✓] WeasyPrint is installed and ready"
else
    echo "[!] Warning: Failed to install WeasyPrint. PDF conversion might fail."
fi

# Step 2: Run the script on Ubuntu
echo "[2] Running audit script on Ubuntu..."
ssh $REMOTE_USER@$REMOTE_HOST "$REMOTE_SCRIPT"

if [ $? -eq 0 ]; then
    echo "[✓] Audit script executed successfully"
    echo "$(date): Audit executed successfully" >> "$LOG_DIR/cron_debug.log"
else
    echo "[✗] Audit script failed to execute"
    echo "$(date): Audit failed" >> "$LOG_DIR/cron_debug.log"
    exit 1
fi


# Step 3: Copy reports from Ubuntu to Kali
# [3] Data Retrieval: Copy generated reports (HTML & PDF) from Ubuntu to Kali
echo "[3] Transferring reports from Ubuntu to Kali..."
scp $REMOTE_USER@$REMOTE_HOST:~/project/reports/*.{html,pdf} "$REPORT_DIR/" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[✓] Reports successfully transferred to: $REPORT_DIR"
    # Optional: List files that match the current timestamp
    ls -lh "$REPORT_DIR" | grep "$(date +%Y%m%d)"
else
    echo "[✗] Error: No reports found on the remote machine"
fi

# Step 4: Done
echo "[✓] Remote audit completed at $(date)"
echo "$(date): Remote audit completed" >> "$LOG_DIR/cron_debug.log"