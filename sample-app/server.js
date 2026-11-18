// Minimal sample "main app" served at the root path, next to the IDE at /ide/.
const http = require("http");

const port = Number(process.env.SAMPLE_APP_PORT) || 3000;
const idePath = (process.env.C9_SUB_PATH || "/ide").replace(/\/*$/, "/");

const html = `<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sample app</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 640px; margin: 64px auto; padding: 0 16px; line-height: 1.5; }
    code { background: #f2f2f2; padding: 2px 6px; border-radius: 4px; }
  </style>
</head>
<body>
  <h1>Sample app is running</h1>
  <p>This page is the main application served at the root path <code>/</code> by nginx.</p>
  <p>The Cloud9 IDE is available at <a href="${idePath}"><code>${idePath}</code></a>.</p>
  <p>Node.js ${process.version}</p>
</body>
</html>`;

http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    return res.end(JSON.stringify({ ok: true, node: process.version }));
  }
  res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
  res.end(html);
}).listen(port, "127.0.0.1", () => {
  console.log(`Sample app listening on http://127.0.0.1:${port}`);
});
