const express = require("express");
const app = express();
const port = 8080;

app.get("/", (req, res) => {
  res.send(`
    <html>
      <head><title>Hello World UI</title></head>
      <body>
        <h1>Hello, World!</h1>
        <p>This is a simple UI served from Express.</p>
      </body>
    </html>
  `);
});

app.listen(port, () => {
  console.log(`Hello World UI app listening at http://localhost:${port}`);
});
