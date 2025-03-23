
# MSSQL Linked Server Exploitation

This repository provides a guide and reference for leveraging the excellent [MSSqlPwner](https://github.com/ScorpionesLabs/MSSqlPwner) tool to assess and exploit Microsoft SQL Server linked servers during internal penetration tests.

## 🔧 What is MSSqlPwner?

[MSSqlPwner](https://github.com/ScorpionesLabs/MSSqlPwner) is an advanced and versatile offensive security tool that simplifies the process of interacting with and exploiting Microsoft SQL Server instances. Built on top of Impacket, it supports multiple authentication methods (cleartext passwords, NTLM hashes, and Kerberos tickets) and allows attackers to:

- Perform recursive enumeration of linked servers and impersonation chains
- Execute OS commands via methods like `xp_cmdshell`, `sp_oacreate`, and custom .NET assemblies
- Exploit linked servers to escalate privileges and pivot laterally
- Trigger NTLM authentication via procedures like `xp_dirtree`, `xp_fileexist`, and `xp_subdirs`
- Retrieve stored passwords from ADSI providers
- Perform brute-force attacks using password, hash, or Kerberos ticket wordlists

## ✨ Why use this?

MSSqlPwner automates much of the complexity behind linked server exploitation. It:

- Finds and builds the right execution chain across multiple linked servers
- Executes commands even when your current user has limited privileges
- Enables stealthy lateral movement and post-exploitation in complex MSSQL environments
