from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
import pyperclip

# Load binary shellcode from file
with open("shellcode.bin", "rb") as f:
    raw_shellcode = f.read()

# Generate AES-256 key and IV
key = get_random_bytes(32)
iv = get_random_bytes(16)

# Apply PKCS7 padding to the shellcode
pad_len = 16 - (len(raw_shellcode) % 16)
padded_shellcode = raw_shellcode + bytes([pad_len] * pad_len)

# Encrypt the shellcode using AES CBC mode
cipher = AES.new(key, AES.MODE_CBC, iv)
encrypted_shellcode = cipher.encrypt(padded_shellcode)

# Format byte arrays for C# output
def format_csharp_array(name, byte_data):
    return f"byte[] {name} = new byte[] {{ {', '.join(f'0x{b:02x}' for b in byte_data)} }};"

# Generate the final C#-formatted output
output = (
    format_csharp_array("encryptedShellcode", encrypted_shellcode)
    + "\n\n"
    + format_csharp_array("aesKey", key)
    + "\n\n"
    + format_csharp_array("aesIV", iv)
)

# Copy the output to the clipboard for easy pasting into C#
pyperclip.copy(output)
print("[+] C# arrays generated and copied to clipboard.")
