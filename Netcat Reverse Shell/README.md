# Reverse Shell Loader

This project provides a loader to execute a reverse shell using a Base64-encoded `nc64.exe` (Netcat for Windows). The loader decodes the Base64, writes it to a temporary file, and executes it in the background to establish a reverse shell connection to a specified IP address and port.

## Features

- **Base64 decoding**: The loader decodes the Base64-encoded `nc64.exe` and saves it as an executable file in the temporary directory.
- **Hidden execution**: The `nc64.exe` is executed with the specified arguments, and the terminal remains hidden (no new terminal window is opened).
- **No blocking**: The loader does not wait for the `nc64.exe` process to finish, allowing the reverse shell to run in the background.
- **Temporary file cleanup**: The temporary file created for the shellcode is deleted after the reverse shell is executed.

## Usage

1. **Replace the Base64 string**: Replace the `<YOUR_BASE64_OF_NC64.EXE>` in the code with the actual Base64-encoded string of the `nc64.exe` file.

   You can generate the Base64 string of `nc64.exe` using the following command:
   ```bash
   cat nc64.exe | base64 -w 0

