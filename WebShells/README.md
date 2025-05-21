# 🕸️ ASPX WebShell by murd0ck

A standalone **ASPX webshell** for Windows IIS environments. It provides:

- 💻 **Command execution** via an interactive console.
- 📁 **File management**: browse directories, download, upload, and delete files.
- 🎨 **Modern dark UI**, fully responsive and no external dependencies.
- 🚫 **Offline-ready**, with zero calls to Google Fonts or CDNs.

---

## ⚙️ How to use

1. Deploy `WebShell.aspx` to an IIS-hosted ASP.NET (Web Forms) folder.
2. Access via `http://<target>/WebShell.aspx`.
3. Interact with the command shell and file manager.

---

## 🔓 Privilege escalation tip

If the webshell runs as:

```
IIS APPPOOL\\DefaultAppPool
```

...you may have **SeImpersonatePrivilege**, which can be exploited using:

- 🥔 **GodPotato**
- 🥔 **PrintSpoofer**
- 🥔 **Juicy Potato NG**
- ...or other NT AUTHORITY\SYSTEM impersonation techniques.

> ⚠️ Always verify privileges using tools like `whoami /priv`.

---

## 📌 Disclaimer

This tool is intended for **educational purposes and authorized penetration testing only**.  
The author is not responsible for misuse.
