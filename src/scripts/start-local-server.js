/* eslint-disable @typescript-eslint/no-require-imports */

const { createServer } = require("https");
const { parse } = require("url");
const next = require("next");
const fs = require("fs");

require("dotenv").config();

const port = process.env.PORT;
const hostname = process.env.LOCAL_HOST;

const dev = process.env.NODE_ENV !== "production";

if (!port) throw new Error(" 🚨 PORT 환경변수가 설정되지 않았습니다!!");
if (!hostname) throw new Error(" 🚨 LOCAL_HOST 환경변수가 설정되지 않았습니다!!");

const app = next({ port, dev, hostname });
const handle = app.getRequestHandler();

console.log(" 🚀 로컬 서버 시작중...");

app.prepare().then(() => {
  const localServer = createServer(
    {
      key: fs.readFileSync("localhost-key.pem"),
      cert: fs.readFileSync("localhost-cert.pem"),
    },
    (req, res) => {
      const parsedUrl = parse(req.url, true);
      handle(req, res, parsedUrl);
    }
  );

  localServer.listen(port);

  console.log(` ✅ Ready: \t https://${hostname}:${port} \n`);
});
