
# Stealthy AES-Encrypted Shellcode Loader in C#

This repository contains a C# implementation of a stealthy shellcode loader using **AES encryption**, **indirect syscalls**, and **process spoofing** techniques. It is designed for red teaming and advanced post-exploitation scenarios where stealth and AV/EDR evasion are crucial.

---

## 🔐 AES Encryption and Decryption

The shellcode is encrypted using **AES-256-CBC** with a randomly generated key and IV. This encrypted shellcode is decrypted in-memory by the C# loader using the .NET `System.Security.Cryptography.Aes` API.

Encryption is handled by a companion **Python script** (`Aes_encryption.py`), which:

- Loads a raw binary shellcode (`shellcode.bin`)
- Applies PKCS7 padding
- Encrypts it using AES-256-CBC
- Outputs 3 byte arrays in C# format:
  - `encryptedShellcode`
  - `aesKey`
  - `aesIV`

These arrays are then used in the C# loader.

---

## 🧠 How the C# Loader Works

1. **Parent Process Spoofing**:  
   A suspended instance of `svchost.exe` is created with `explorer.exe` as its parent process using the `STARTUPINFOEX` and `UpdateProcThreadAttribute` technique.

2. **AES Decryption**:  
   The script decrypts the AES-encrypted shellcode using the provided key and IV at runtime, fully in-memory.

3. **Indirect Syscall Stub**:  
   Instead of calling Windows APIs directly, the loader extracts raw syscall stubs from `ntdll.dll` and invokes them dynamically to evade userland hooks.

4. **Memory Allocation via Syscalls**:  
   - `NtAllocateVirtualMemory`: Allocates memory in the target process.
   - `NtWriteVirtualMemory`: Writes the decrypted shellcode.
   - `NtProtectVirtualMemory`: Sets memory region to executable.
   - `NtCreateThreadEx`: Creates a remote thread to execute the shellcode.

5. **Execution**:  
   The shellcode is executed inside the spoofed process, effectively launching your payload under the disguise of a legitimate system process.

---

## 📦 Usage

### 1. Generate AES-Encrypted Shellcode

Use the Python script:

```bash
python3 encrypt_shellcode.py
```

This script reads `shellcode.bin`, encrypts it, and copies the C#-formatted byte arrays to your clipboard.

Paste the output into your C# loader:

```csharp
byte[] encryptedShellcode = new byte[] { ... };
byte[] aesKey = new byte[] { ... };
byte[] aesIV = new byte[] { ... };
```
---

## ⚠️ Warning

This project is intended for **educational** and **authorized security research** purposes only. Running this code on systems you do not own or have explicit permission to test may be illegal and unethical.


---

## 🛡️ Evasion Techniques Implemented

- ✅ AES-256 in-memory decryption
- ✅ Process Hollowing with parent spoofing
- ✅ Indirect syscalls via ntdll stub copying
- ✅ No calls to AmsiScanBuffer or GetProcAddress
- ✅ Zero file system or registry footprint during execution

---
