#!/bin/bash

input="hosts.txt"
output="hosts_results.txt"
temp="tmp_hosts_merge.txt"

> "$temp"

# Paso 1: Extraer IP, hostname, FQDN y dominio si es DC
awk '
/^SMB/ {
    ip = $2;
    host = tolower($4);
    fqdn = "";
    domain = "";

    # Extraer dominio desde el texto (domain:xyz.local)
    if (match($0, /\(domain:([^)]+)\)/, dom)) {
        domain = tolower(dom[1]);
        fqdn = host "." domain;
    }

    # Verificar si es un DC (nombre host inicia con "dc" seguido de número)
    is_dc = match(host, /^dc[0-9]+$/);

    # Construir línea de salida
    line = ip " " host " " fqdn;
    if (is_dc && domain != "") {
        line = line " " domain;
    }

    print line;
}
' "$input" >> "$temp"

# Paso 2: Agrupar por IP y deduplicar hostnames
awk '
{
    ip = $1;
    $1 = "";
    sub(/^ +/, "");
    hosts[ip] = hosts[ip] " " $0;
}
END {
    for (ip in hosts) {
        split(hosts[ip], arr, " ");
        delete seen;
        out = "";
        for (i in arr) {
            h = arr[i];
            if (h != "" && !seen[h]++) {
                out = out " " h;
            }
        }
        print ip out;
    }
}
' "$temp" | sort -V > "$output"

rm "$temp"
echo "[+] $output generated and ready to add to /etc/hosts."
