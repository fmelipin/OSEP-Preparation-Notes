#!/bin/bash
#
# etchost-builder.sh
# Description:
#   Parses the output of `netexec smb <target>` and generates properly formatted
#   entries for the /etc/hosts file.
#
# Usage:
#   1. Run netexec and save the output to a file:
#        netexec smb 192.168.56.0/24 > hosts.txt
#
#   2. Run this script:
#        ./etchost-builder.sh
#
#   3. Review the output file:
#        hosts_results.txt
#
#   4. Optionally append the results to your system's /etc/hosts file:
#        sudo cat hosts_results.txt >> /etc/hosts
#
# Notes:
#   - All hostnames are converted to lowercase.
#   - Domain Controllers (hosts named like dc01, dc02, etc.) will have the domain added as an alias.
#   - Output is deduplicated and sorted by IP.

input="hosts.txt"
output="hosts_results.txt"
temp="tmp_hosts_merge.txt"

> "$temp"

# Step 1: Extract IP, hostname, FQDN, and domain if it's a Domain Controller
awk '
/^SMB/ {
    ip = $2;
    host = tolower($4);
    fqdn = "";
    domain = "";

    # Extract the domain from the text (e.g., domain:xyz.local)
    if (match($0, /\(domain:([^)]+)\)/, dom)) {
        domain = tolower(dom[1]);
        fqdn = host "." domain;
    }

    # Check if the hostname starts with "dc" followed by a number (indicating a Domain Controller)
    is_dc = match(host, /^dc[0-9]+$/);

    # Build the output line
    line = ip " " host " " fqdn;
    if (is_dc && domain != "") {
        line = line " " domain;
    }

    print line;
}
' "$input" >> "$temp"

# Step 2: Group by IP and deduplicate hostnames
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
echo "[+] $output generated and ready to be added to /etc/hosts."
