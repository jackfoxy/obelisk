'use strict';

// chords.js — an app's chord table, and the keymaps it must not fight.
//
// Shared by the conflict gate in every consumer.  The table is read
// from the `++shortcuts` arm of the app's web library rather than from
// a hand-written list, so a row cannot be added without the gate
// seeing it.
//
// Two manifests matter, not one.  `ace-win-linux-shortcuts.json` pins
// Ace's own keymap; `vim-chords.json` pins the Vim keymap, which
// Settings swaps in wholesale.  A chord free against the first may
// still be taken by the second.

const fs = require('node:fs');
const path = require('node:path');

const here = __dirname;

function readJson(name) {
  return JSON.parse(fs.readFileSync(path.join(here, name), 'utf8'));
}

//  The app's web library: `desk/lib/*-web.hoon` in a consumer, or the
//  fixture in urui itself.
function webLibrary(root) {
  const candidates = [
    ...globHoon(path.join(root, 'desk/lib'), /-web\.hoon$/),
    ...globHoon(path.join(root, 'tests/fixture/lib'), /-web\.hoon$/)
  ];
  if (!candidates.length) {
    throw new Error(`no *-web.hoon under ${root}`);
  }
  //  A consumer with several picks the one declaring the chord table.
  const declaring = candidates.filter((file) => {
    return /\n\+\+ {2}shortcuts\n/.test(fs.readFileSync(file, 'utf8'));
  });
  if (declaring.length !== 1) {
    throw new Error(
      `expected one ++shortcuts arm, found ${declaring.length} in ${root}`
    );
  }
  return declaring[0];
}

function globHoon(folder, pattern) {
  if (!fs.existsSync(folder)) return [];
  return fs.readdirSync(folder)
    .filter((name) => pattern.test(name))
    .map((name) => path.join(folder, name));
}

//  `['F1' 'help' %always %override `'Help']`, or ~ for no label.
const row = new RegExp(
  "\\['([^']+)'\\s+'([^']+)'\\s+%([a-z-]+)\\s+%([a-z]+)\\s+"
  + "(?:`'([^']*)'|~)\\s*\\]",
  'g'
);

function table(root) {
  const file = webLibrary(root);
  const source = fs.readFileSync(file, 'utf8');
  const arm = /\n\+\+ {2}shortcuts\n([\s\S]*?)\n {2}==\n/.exec(source);
  if (!arm) throw new Error(`cannot find the ++shortcuts arm in ${file}`);
  const chords = [...arm[1].matchAll(row)].map((match) => ({
    binding: match[1],
    command: match[2],
    when: match[3],
    policy: match[4],
    label: match[5] ?? null
  }));
  if (!chords.length) {
    throw new Error(`the ++shortcuts arm in ${file} parsed to nothing`);
  }
  //  A row the regex skipped is a row the gate would not check, which
  //  is worse than a row it rejects.
  //  every row opens `['`, including the first, which follows `:~`
  const declared = (arm[1].match(/\['/g) || []).length;
  if (declared !== chords.length) {
    throw new Error(
      `${file}: ${declared} rows declared but ${chords.length} parsed; `
      + 'every row needs binding, command, when, policy and label'
    );
  }
  return {file, chords};
}

//  Where a binding is already spoken for, as `[{keymap, context,
//  action}]`.  Ace's manifest has no contexts; Vim's does.
function claims(binding) {
  const ace = readJson('ace-win-linux-shortcuts.json');
  const vim = readJson('vim-chords.json');
  const found = [];
  for (const entry of ace.rows) {
    if (!entry.bindings.includes(binding)) continue;
    found.push({keymap: 'ace', context: 'editor', action: entry.action});
  }
  for (const entry of vim.rows) {
    if (entry.binding !== binding) continue;
    found.push({
      keymap: 'vim',
      context: entry.context,
      action: entry.action,
      match: entry.match
    });
  }
  return found;
}

//  Chords no app may take, whatever its policy: the browser keeps them
//  and will not hand them over.  Ctrl-1..8 switch tabs, Ctrl-T/N/W
//  open and close them, F11 is fullscreen.
const reserved = [
  'Ctrl-1', 'Ctrl-2', 'Ctrl-3', 'Ctrl-4', 'Ctrl-5', 'Ctrl-6', 'Ctrl-7',
  'Ctrl-8', 'Ctrl-T', 'Ctrl-N', 'Ctrl-W', 'F11'
];

module.exports = {table, claims, reserved, readJson, webLibrary};
