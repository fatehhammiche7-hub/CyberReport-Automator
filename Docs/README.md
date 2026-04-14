# 🖥️ Linux System Audit & Monitoring Tool

> **"Design and Implementation of an Automated Hardware & Software Audit System with Reporting and Remote Monitoring Capabilities"**

---

| Field | Details |
|---|---|
| **Institution** | National School of Cyber Security (NSCS) |
| **Academic Year** | 2025 / 2026 |
| **Course** | Operating Systems |
| **Teacher** | Dr. BENTRAD Sassi |
| **Project** | Mini-Project – Part N°1 |
| **Students** | Hammiche Fateh · Belarmas Abdelouahab |

---

## 📑 Table of Contents

1. [Project Structure](#1-project-structure)
2. [Installation & Requirements](#2-installation--requirements)
3. [Email Configuration (msmtp)](#3-email-configuration-msmtp)
4. [How to Run](#4-how-to-run)
5. [Automation with Cron](#5-automation-with-cron)
6. [Report Types](#6-report-types)
7. [Remote Monitoring via SSH](#7-remote-monitoring-via-ssh)
8. [Security Considerations](#8-security-considerations)
9. [Logging](#9-logging)
10. [Features Implemented](#10-features-implemented)
11. [Authors](#11-authors)

---

## 1. Project Structure

```
project/
├── hardware.sh            # Hardware audit module
├── software.sh            # Software audit module
├── report3.sh             # Interactive report generator (menu-driven)
├── sendreportauto.sh      # Automated report generation + email sending (for cron)
├── reports/               # Auto-generated reports directory
│   ├── short_report_YYYYMMDD_HHMMSS.html
│   ├── full_report_YYYYMMDD_HHMMSS.html
│   └── audit_YYYYMMDD.log
└── README.md              # This file
```

The project follows a **modular architecture**: each script is responsible for a specific function, making the system easier to maintain, debug, and extend.

---

## 2. Installation & Requirements

### 2.1 Install Dependencies

Run the following command to install all required tools:

```bash
sudo apt update
sudo apt install -y msmtp msmtp-mta lsb-release lsscsi usbutils pciutils sysstat
```

### 2.2 Tool Reference

| Tool | Purpose |
|---|---|
| `msmtp` | Sending emails via SMTP |
| `lscpu` | CPU information |
| `lspci` | GPU / PCI devices |
| `lsusb` | USB devices |
| `free` | RAM usage |
| `df` | Disk usage |
| `ip` | Network interfaces |
| `ss` | Open ports & active connections |
| `ps` | Running processes |
| `systemctl` | Running services |
| `iostat` | I/O statistics *(from sysstat package)* |
| `dmidecode` | Motherboard, BIOS & hardware details *(requires `sudo`)* |

> ⚠️ **Note on `sudo`:** Commands such as `dmidecode` require elevated privileges to access low-level hardware information (BIOS version, motherboard serial, memory slots). If the scripts are not run as root, these sections will display `"N/A"` or `"Permission denied"`. It is recommended to run the audit scripts with `sudo` or schedule them via root's crontab for complete hardware data collection.

### 2.3 Set Script Permissions

```bash
chmod +x hardware.sh software.sh report3.sh sendreportauto.sh
```

---

## 3. Email Configuration (msmtp)

The email functionality relies on **msmtp**, a lightweight SMTP client compatible with Gmail and other providers.

### Step 1 — Create the configuration file

```bash
nano ~/.msmtprc
```

### Step 2 — Add the following configuration (Gmail example)

```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           your_email@gmail.com
user           your_email@gmail.com
password       your_app_password

account default : gmail
```

> ⚠️ **Important:** Use a Gmail **App Password**, not your regular account password.  
> To generate one: `Google Account` → `Security` → `2-Step Verification` → `App Passwords`

### Step 3 — Secure the configuration file

```bash
chmod 600 ~/.msmtprc
```

This prevents other system users from reading your SMTP credentials.

### Step 4 — Test the configuration

```bash
echo "Test email from audit system" | msmtp your_email@gmail.com
```

### Step 5 — Configure recipients

To change or add recipient addresses, edit **`sendreportauto.sh`**:

```bash
RECIPIENTS=(
    "your_email@example.com"
    "second_recipient@example.com"
)
```

---

## 4. How to Run

### Option 1 — Interactive Menu (`report3.sh`)

```bash
bash report3.sh
```

This launches a user-friendly, **menu-driven interface**:

```
=========================================
       SYSTEM REPORT TOOL (HTML)
=========================================
1) Generate short HTML report
2) Generate full HTML report
3) Generate both reports
4) Send short report via email
5) Send full report via email
6) Send both reports via email
7) View last short report in browser
8) View last full report in browser
9) Exit
=========================================
Choose an option (1-9):
```

### Option 2 — Automated Execution (`sendreportauto.sh`)

```bash
bash sendreportauto.sh
```

This script performs the full pipeline without user interaction:
1. Validates all dependencies
2. Generates both Short and Full HTML reports
3. Sends them to all configured recipients
4. Cleans up reports older than 30 days
5. Logs all actions to the audit log file

> This is the script intended for **unattended cron-based execution**.

---

## 5. Automation with Cron

Cron is used to schedule the audit tool to run automatically at a fixed interval, fulfilling the automation requirement of this project.

### Step 1 — Open the crontab editor

```bash
crontab -e
```

### Step 2 — Add the scheduling rule

The following entry runs the audit **every day at 04:00 AM**:

```cron
0 4 * * * /bin/bash /home/fateh/project/sendreportauto.sh >> /home/fateh/project/reports/cron_debug.log 2>&1
```

| Field | Value | Meaning |
|---|---|---|
| `0` | Minute | At minute 0 |
| `4` | Hour | At 04:00 AM |
| `*` | Day of month | Every day |
| `*` | Month | Every month |
| `*` | Day of week | Every day of the week |

### Step 3 — Verify the cron job

```bash
crontab -l
```

> 📌 Execution output and errors are captured in `reports/cron_debug.log` for debugging purposes.

---

## 6. Report Types

### 6.1 Short Report *(Summary View)*

A concise HTML snapshot of the system's current state. Intended for quick daily review.

**Includes:**
- OS name, Kernel version, Hostname, Uptime
- CPU basic information
- RAM usage (total / used / free)
- Disk usage (top partitions)
- Network IP & MAC address
- GPU model
- Top 5 processes by CPU usage

### 6.2 Full Report *(Detailed Audit)*

A comprehensive HTML document covering all hardware and software components. Intended for in-depth security audits and asset inventories.

**Includes everything in the Short Report, plus:**
- Full CPU specification (`lscpu` output)
- Motherboard & BIOS information *(requires `sudo dmidecode`)*
- USB devices list
- Open ports (LISTEN state via `ss`)
- Active network connections count
- Installed packages (total count + last installed)
- Running services (`systemctl`)
- Security section: logged-in users, last logins, active SSH connections
- I/O statistics (`iostat`)
- **CPU alert banner** if usage exceeds 80%

**Report naming convention:**

```
reports/short_report_20260412_040000.html
reports/full_report_20260412_040000.html
```

---

## 7. Remote Monitoring via SSH

Remote monitoring is a critical cybersecurity capability that allows administrators to **audit systems without physical access**. This section describes how to configure and use SSH-based remote monitoring securely.

---

### 7.1 SSH Key-Based Authentication Setup *(Required for Unattended Access)*

Password-based SSH is unsuitable for automated scripts. **Key-based authentication** must be used instead, as it is both more secure and supports unattended execution by cron.

#### Step 1 — Generate an RSA key pair on the local machine

```bash
ssh-keygen -t rsa -b 4096 -C "audit-system-key"
```

| Flag | Meaning |
|---|---|
| `-t rsa` | Specifies the RSA algorithm |
| `-b 4096` | Sets key length to 4096 bits for stronger security |
| `-C` | Adds an identifying comment to the key |

When prompted, save the key to the default path (`~/.ssh/id_rsa`) or specify a custom path.

#### Step 2 — Copy the public key to the remote machine

```bash
ssh-copy-id user@remote_ip
```

This appends your public key to `~/.ssh/authorized_keys` on the remote machine, enabling **passwordless, secure login**.

#### Step 3 — Test the passwordless connection

```bash
ssh user@remote_ip "hostname && uptime"
```

A successful response confirms that key-based authentication is working correctly.

---

### 7.2 Remote Audit Execution via SSH

Run the audit script on a remote machine directly from the local terminal:

```bash
ssh user@remote_ip "bash /home/user/project/sendreportauto.sh"
```

> All commands and their output are transmitted **encrypted over port 22** using the SSH protocol, ensuring both **confidentiality** and **integrity** of audit data in transit.

---

### 7.3 Retrieving Reports from a Remote Machine (SCP)

After the remote audit completes, securely copy the generated reports to the local machine:

```bash
scp user@remote_ip:/home/user/project/reports/*.html /local/path/reports/
```

**SCP (Secure Copy Protocol)** operates over SSH on **port 22** and guarantees that report files are transferred with the same encryption and authentication as a regular SSH session — no plaintext exposure.

---

### 7.4 Centralizing Reports from Multiple Machines

To push reports from a remote machine to a **central log server**, add the following block to `sendreportauto.sh` after the report generation step:

```bash
REMOTE_SERVER="admin@192.168.1.100"
REMOTE_PATH="/var/log/audit_reports/$(hostname)/"

ssh "$REMOTE_SERVER" "mkdir -p $REMOTE_PATH"
scp "$SHORT_REPORT" "$FULL_REPORT" "$REMOTE_SERVER:$REMOTE_PATH"
```

This approach supports **centralized monitoring** of multiple Linux machines from a single administration server — a standard practice in enterprise Security Operations Centers (SOC).

---

## 8. Security Considerations

| Area | Measure Applied |
|---|---|
| **SMTP Credentials** | `~/.msmtprc` protected with `chmod 600` |
| **Remote Access** | SSH key-based authentication — no passwords transmitted over the network |
| **Data in Transit** | All transfers use SSH / SCP (AES-encrypted, port 22) |
| **Report Storage** | Timestamped files; reports older than 30 days are auto-deleted |
| **Privilege Awareness** | `dmidecode` and similar commands require `sudo` for full hardware data |
| **Session Audit** | Full report captures active SSH connections and login history |
| **CPU Alerting** | Visual red alert banner triggered in report if CPU usage exceeds 80% |

---

## 9. Logging

All executions are logged automatically in:

```
reports/audit_YYYYMMDD.log
```

**Log format example:**

```
[2026-04-12 04:00:01] [INFO]    Checking requirements...
[2026-04-12 04:00:02] [INFO]    All requirements satisfied
[2026-04-12 04:00:04] [INFO]    Short report saved to: reports/short_report_20260412_040004.html
[2026-04-12 04:00:05] [INFO]    Full report saved to: reports/full_report_20260412_040005.html
[2026-04-12 04:00:08] [SUCCESS] Short report sent to fatehhammiche7@gmail.com
[2026-04-12 04:00:09] [SUCCESS] Full report sent to fatehhammiche7@gmail.com
[2026-04-12 04:00:10] [INFO]    Cleanup completed
[2026-04-12 04:00:10] [INFO]    ========== SYSTEM AUDIT COMPLETED ==========
```

**Log levels:** `[INFO]` · `[SUCCESS]` · `[ERROR]`

---

## 10. Features Implemented

| Feature | Category | Status |
|---|---|---|
| Hardware audit (CPU, RAM, Disk, GPU, USB, Motherboard) | Core | ✅ Implemented |
| Software audit (OS, packages, services, processes) | Core | ✅ Implemented |
| Short HTML report generation | Core | ✅ Implemented |
| Full HTML report generation | Core | ✅ Implemented |
| Email sending via msmtp | Core | ✅ Implemented |
| Cron automation (daily at 04:00 AM) | Core | ✅ Implemented |
| Remote monitoring via SSH / SCP | Core | ✅ Implemented |
| Error handling & execution logging | Core | ✅ Implemented |
| Colorized terminal output | Bonus | ✅ Implemented |
| Interactive menu-driven interface | Bonus | ✅ Implemented |
| CPU alert system (threshold > 80%) | Bonus | ✅ Implemented |
| Automatic log & report cleanup (> 30 days) | Bonus | ✅ Implemented |
| Modular script architecture | Quality | ✅ Implemented |

---

## 11. Authors

| Name | Contribution |
|---|---|
| **Hammiche Fateh** | Script development & system testing |
| **Belarmas Abdelouahab** | Script development & technical documentation |

---

<div align="center">

*NSCS — National School of Cyber Security | Academic Year 2025/2026*

</div>
