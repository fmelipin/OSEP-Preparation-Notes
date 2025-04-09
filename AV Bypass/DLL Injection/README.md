# 🛡️ DLL Loader for Windows Defender Bypass

This repository provides a **custom DLL Loader** built for **OSEP-level training and testing scenarios**. It executes DLLs directly in memory, avoiding disk writes and using stealth techniques to **bypass Microsoft Defender** and evade common AV/EDR solutions.

---

## 📌 Based on

This project is a **fork of [ShellcodeEncrypt2DLL](https://github.com/restkhz/ShellcodeEncrypt2DLL)** by [restkhz](https://github.com/restkhz), originally designed to execute AES-encrypted shellcode from DLLs.  
The current version has been modified, cleaned, and adapted to load DLLs directly into memory for improved **evasion and compatibility** in modern red team environments.

---

## 🎯 Purpose

This tool was created specifically as part of preparation for the **Offensive Security Experienced Penetration Tester (OSEP)** certification.

It has been **tested extensively in controlled environments**, and has proven to work effectively against **Windows Defender** in real-world lab conditions.

---

## 🧪 Use Cases

- OSEP lab exercises and red team simulations  
- Post-exploitation payload delivery  
- Execution of Mimikatz or custom tools as DLLs in memory  
- Bypassing AV/EDR during lateral movement

> ✅ Fully tested in Windows 10 and 11 environments with real-time protection enabled.

---

## ⚠️ Legal Disclaimer

This project is intended for **educational and authorized penetration testing** only.  
**Do not use** this tool on systems you do not own or have explicit permission to test.  
The authors are not responsible for any misuse or illegal activity.

---

## 📂 Repository

[https://github.com/fmelipin/DLL-Loader](https://github.com/fmelipin/DLL-Loader)

