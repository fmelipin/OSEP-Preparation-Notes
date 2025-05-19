# 🛠️ etchost-builder

`etchost-builder` is a Bash script that generates properly formatted entries for your `/etc/hosts` file by parsing the output of SMB network enumeration tools such as `netexec`.

## 📋 Description

This tool is designed to process the output of:

```
netexec smb 192.168.56.0/24
```

You must save that output into a file named `hosts.txt`.

The script will:

- Extract IP addresses, hostnames, and domain names.
- Normalize all names to lowercase.
- Construct valid FQDNs (`hostname.domain`).
- Identify Domain Controllers by name (`dc01`, `dc02`, etc.) and append the domain as an alias.
- Deduplicate and group hostnames per IP.
- Output a clean, ready-to-use `hosts_results.txt` file for `/etc/hosts`.

## 📂 Input Format (`hosts.txt`)

This file must contain the raw output of a command like:

```
netexec smb 192.168.56.0/24
```

Example:
```
SMB     192.168.56.10   445  DC01       [*] Windows Server 2019 Build 17763 x64 (name:DC01) (domain:acme.local)
SMB     192.168.56.20   445  FILE01     [*] Windows 10 Build 19041 x64 (name:FILE01) (domain:acme.local)
SMB     192.168.56.21   445  CLIENT01   [*] Windows 10 Build 19041 x64 (name:CLIENT01) (domain:acme.local)
SMB     192.168.56.30   445  DC02       [*] Windows Server 2019 Build 17763 x64 (name:DC02) (domain:corpnet.local)
SMB     192.168.56.31   445  DEV01      [*] Windows 10 Build 19044 x64 (name:DEV01) (domain:corpnet.local)
```

## ✅ Output Format (`hosts_results.txt`)

The script produces:
```
192.168.56.10 dc01 dc01.acme.local acme.local
192.168.56.20 file01 file01.acme.local
192.168.56.21 client01 client01.acme.local
192.168.56.30 dc02 dc02.corpnet.local corpnet.local
192.168.56.31 dev01 dev01.corpnet.local
```

## 🚀 Usage

```bash
chmod +x etchost-builder.sh
./etchost-builder.sh
```

This will generate `hosts_results.txt`.

### Optional: Append to `/etc/hosts`

```bash
sudo cat hosts_results.txt >> /etc/hosts
```

> ⚠️ Always back up `/etc/hosts` before modifying it.

## 🛠 Requirements

- Bash
- `awk`
- A `hosts.txt` file generated from `netexec smb` or similar tools
