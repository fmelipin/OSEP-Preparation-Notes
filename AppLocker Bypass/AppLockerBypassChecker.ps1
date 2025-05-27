Get-ChildItem $env:windir -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    $dir = $_;
    (Get-Acl $dir.FullName).Access | ForEach-Object {
        if ($_.AccessControlType -eq "Allow") {
            if ($_.IdentityReference.Value -eq "NT AUTHORITY\Authenticated Users" -or $_.IdentityReference.Value -eq "BUILTIN\Users") {
                if (($_.FileSystemRights -like "*Write*" -or $_.FileSystemRights -like "*Create*") -and $_.FileSystemRights -like "*Execute*") {
                    Write-Host ($dir.FullName + ": " + $_.IdentityReference.Value + " (" + $_.FileSystemRights + ")");
                }
            }
        }
    };
}
