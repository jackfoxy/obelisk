'use strict';

// Serves %obelisk-web's page, app.js, app.css, and Ace assets for
// Playwright, compiled from the desk sources with `vere eval` and no ship.
// Every api and file route is left to each spec's page.route doubles.
//
// Run: VERE=/path/to/vere node serve-app.js

const fs = require('node:fs');
const http = require('node:http');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const {spawn} = require('node:child_process');

const root = path.resolve(__dirname, '../../..');
const port = 4174;

//  Each file's Ford imports are replaced by `=+` bindings under the same
//  faces, in dependency order.
const bindings = [
  ['ast', 'desk/sur/obelisk-ast.hoon'],
  ['urui', 'desk/sur/urui.hoon'],
  ['uhttp', 'desk/lib/urui-http.hoon'],
  ['ufiles', 'desk/lib/urui-files.hoon'],
  ['web', 'desk/sur/obelisk-web.hoon'],
  ['uace', 'desk/lib/urui-ace.hoon'],
  ['ucss', 'desk/lib/urui-css.hoon'],
  ['ucfg', 'desk/lib/urui-config.hoon'],
  ['ujs', 'desk/lib/urui-js.hoon'],
  ['shell', 'desk/lib/urui-shell.hoon'],
  ['app', 'desk/lib/obelisk-web.hoon']
];
const expression =
  '[(page:app ~zod) (javascript:app ~zod) ace-config-js:app css:app]';

function readSource(filename) {
  return fs.readFileSync(filename, 'utf8').replace(/^\/[+-].*\n/gm, '');
}

function assemble() {
  const lines = [];
  for (const [face, relative] of bindings) {
    lines.push(`=+  ^=  ${face}`);
    lines.push(readSource(path.resolve(root, relative)));
  }
  lines.push(expression);
  return lines.join('\n');
}

function findVere() {
  const candidates = [
    process.env.VERE,
    path.join(os.homedir(), 'piers/vere-v4.5-linux-x86_64'),
    path.join(os.homedir(), 'piers/urbit'),
    'vere'
  ].filter(Boolean);
  for (const candidate of candidates) {
    if (!candidate.includes('/') || fs.existsSync(candidate)) return candidate;
  }
  throw new Error('set VERE to an executable that supports `eval`');
}

function decodeCord(source) {
  const chunks = [];
  for (let index = 0; index < source.length;) {
    if (source[index] !== '\\') {
      const point = source.codePointAt(index);
      const character = String.fromCodePoint(point);
      chunks.push(Buffer.from(character));
      index += character.length;
      continue;
    }
    const hex = source.slice(index + 1, index + 3);
    if (/^[0-9a-f]{2}$/i.test(hex)) {
      chunks.push(Buffer.from([Number.parseInt(hex, 16)]));
      index += 3;
      continue;
    }
    if (index + 1 >= source.length) throw new Error('invalid cord escape');
    chunks.push(Buffer.from(source[index + 1]));
    index += 2;
  }
  return Buffer.concat(chunks).toString('utf8');
}

function parseCords(output, count) {
  const plain = output.replace(/\x1b\[[0-9;]*m/g, '');
  const start = plain.indexOf('eval (run):');
  if (start < 0) throw new Error('vere eval returned no result');
  const cords = [];
  let index = start;
  while (index < plain.length && cords.length < count) {
    if (plain[index] !== "'") {
      index += 1;
      continue;
    }
    index += 1;
    let encoded = '';
    while (index < plain.length) {
      if (plain[index] === "'") {
        index += 1;
        break;
      }
      if (plain[index] === '\\') {
        encoded += plain[index];
        index += 1;
        if (index >= plain.length) throw new Error('unterminated cord');
        encoded += plain[index];
        if (/[0-9a-f]/i.test(plain[index])
          && /[0-9a-f]/i.test(plain[index + 1] || '')) {
          index += 1;
          encoded += plain[index];
        }
        index += 1;
        continue;
      }
      encoded += plain[index];
      index += 1;
    }
    cords.push(decodeCord(encoded));
  }
  if (cords.length !== count) {
    throw new Error('vere eval returned invalid assets');
  }
  return cords;
}

function evaluate(source) {
  return new Promise((resolve, reject) => {
    const child = spawn(findVere(), ['eval']);
    const output = [];
    child.stdout.on('data', (chunk) => output.push(chunk));
    child.stderr.on('data', (chunk) => output.push(chunk));
    child.on('error', reject);
    child.on('close', (status) => {
      const result = Buffer.concat(output).toString('utf8');
      if (status === 0) resolve(result);
      else reject(new Error(result || 'vere eval failed'));
    });
    child.stdin.end(source);
  });
}

async function compileAssets() {
  let problem;
  for (let attempt = 0; attempt < 3; attempt += 1) {
    try {
      const assets = parseCords(await evaluate(assemble()), 4);
      if (!assets[0].includes('</html>')) {
        throw new Error('vere eval returned truncated page HTML');
      }
      new vm.Script(assets[1], {filename: 'obelisk-app.js'});
      new vm.Script(assets[2], {filename: 'obelisk-config.js'});
      return assets;
    } catch (cause) {
      problem = cause;
    }
  }
  throw problem;
}

async function main() {
  const [page, javascript, aceConfig, css] = await compileAssets();
  const aceRoot = path.join(root, 'desk/web/ace');
  const js = 'text/javascript; charset=utf-8';
  const text = 'text/plain; charset=utf-8';
  //  the agent's ++assets, as the routes a ship would serve
  const routes = new Map([
    ['/apps/obelisk', ['text/html; charset=utf-8', () => page]],
    ['/apps/obelisk/', ['text/html; charset=utf-8', () => page]],
    ['/apps/obelisk/app.js', [js, () => javascript]],
    ['/apps/obelisk/app.css', ['text/css; charset=utf-8', () => css]],
    ['/apps/obelisk/doc.toc', [text, () => {
      return fs.readFileSync(path.join(root, 'desk/doc.toc'));
    }]],
    ['/apps/obelisk/ace/obelisk-config.js', [js, () => aceConfig]]
  ]);
  for (const [served, file] of [
    ['ace.js', 'ace.js'],
    ['theme-github.js', 'theme-github.js'],
    ['theme-monokai.js', 'theme-monokai.js'],
    ['ext-beautify.js', 'ext-beautify.js'],
    ['ext-prompt.js', 'ext-prompt.js'],
    ['ext-searchbox.js', 'ext-searchbox.js'],
    ['ext-settings_menu.js', 'ext-settings-menu.js'],
    ['keybinding-vim.js', 'keybinding-vim.js'],
    ['license.txt', 'license.txt']
  ]) {
    routes.set(`/apps/obelisk/ace/${served}`, [
      file.endsWith('.js') ? js : text,
      () => fs.readFileSync(path.join(aceRoot, file))
    ]);
  }
  const server = http.createServer((request, response) => {
    const requestPath = new URL(request.url, 'http://127.0.0.1').pathname;
    const route = request.method === 'GET' && routes.get(requestPath);
    if (route) {
      response.writeHead(200, {'content-type': route[0]});
      response.end(route[1]());
      return;
    }
    response.writeHead(404, {'content-type': text});
    response.end('not found');
  });
  server.listen(port, '127.0.0.1');
}

module.exports = {compileAssets};

if (require.main === module) {
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
}
