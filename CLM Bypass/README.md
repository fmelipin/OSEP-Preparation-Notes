
# 🛡️ CLM_Bypass

Bypass PowerShell **Constrained Language Mode (CLM)** using a custom C# Installer class and `InstallUtil.exe`. This technique enables **in-memory execution** of remote PowerShell payloads — including **AMSI bypass** and **reverse shells** — in Full Language Mode on restricted systems.

---

## ✨ Overview

This project takes advantage of how the .NET `System.Configuration.Install.Installer` class interacts with `InstallUtil.exe`. Instead of executing the program’s `Main()` method, we embed our logic in the `Uninstall()` method of an installer class, which is automatically triggered by the `/U` (uninstall) flag.

**Key benefits:**
- Executes PowerShell in **Full Language Mode**, even under CLM
- AMSI is bypassed before loading payload
- Scripts are loaded **remotely** via HTTP and executed in memory
- No need to spawn `powershell.exe`

---

## 📦 Setup

### 1. Clone the repository and open the project in Visual Studio

Include the provided C# source file in a Console App project.

### 2. Add References

Manually add references to the following assemblies:

- `System.Management.Automation.dll`  
  Path:  
  `C:\Program Files (x86)\Reference Assemblies\Microsoft\WindowsPowerShell\3.0\System.Management.Automation.dll`
  
- `System.Configuration.Install.dll`  
  (Usually available by default in .NET Framework projects)

In **Visual Studio**:  
Right-click project → Add Reference → Browse → Select both DLLs.

---

## 🚀 Execution

Trigger the payload using `InstallUtil.exe` with the uninstall flag:

```powershell
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=true /U .\CLM_Bypass.exe
```

Expected output:
```
Microsoft (R) .NET Framework Installation utility Version 4.8.x.x

The uninstall is beginning.
Uninstalling assembly 'CLM_Bypass.exe'.
Affected parameters:
   logtoconsole = true
   assemblypath = CLM_Bypass.exe
   logfile =
```

At this point:

✅ AMSI bypass (`amsi.txt`) is loaded  
✅ Reverse shell or payload (`shell.ps1`) is executed  
✅ You should receive a callback on your listener

---

## 🌐 Hosting Payloads

Make sure you have a local web server hosting the following:

- `amsi.txt` → AMSI bypass payload
- `shell.ps1` → Reverse shell or in-memory loader

Example using Python:

```bash
python3 -m http.server 80
```

---

## 🧪 Testing

To confirm the payload executed correctly:

1. Listen for the reverse shell:
   ```bash
   rlwrap -cAr nc -lvnp 443
   ```

2. Confirm incoming HTTP requests to:
   - `/amsi.txt`
   - `/shell.ps1`

3. Observe PowerShell command execution or interactive shell.

---

## 🧠 How It Works

- The `[RunInstaller(true)]` attribute marks the class as executable via `InstallUtil.exe`.
- The `Uninstall()` method is automatically invoked.
- A PowerShell **runspace** is created from C# in memory.
- AMSI is bypassed before invoking any downloaded PowerShell script.

This allows full script execution, even when the system enforces CLM and disables traditional PowerShell operations.

---
