'use strict';

// The cross-app conflict gate.
//
// An application chord competes with two keymaps the editor may be
// running -- Ace's own and Vim's -- and with the browser, which keeps
// some chords whatever the page asks.  `policy` on each row declares
// what the chord costs; this checks the declaration against the pinned
// manifests, so a colliding chord fails the build instead of being
// discovered by a user whose editor was in the wrong mode.
//
// The table is read from the app's `++shortcuts` arm, so a row cannot
// be added without this seeing it.  A deliberate conflict is allowed,
// but only with an entry in `shortcut-exceptions.json` naming what it
// displaces and how that stays reachable -- the evidence that the
// override was a decision.

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const {table, claims, reserved} = require('./chords.js');

const root = path.resolve(__dirname, '../..');
const {file, chords} = table(root);
const label = path.relative(root, file);

const exceptionsPath = path.join(__dirname, 'shortcut-exceptions.json');
const exceptions = fs.existsSync(exceptionsPath)
  ? JSON.parse(fs.readFileSync(exceptionsPath, 'utf8'))
  : {overrides: [], reserved: []};

const overrideFor = (binding) => (exceptions.overrides || [])
  .find((entry) => entry.binding === binding);
const reservedFor = (binding) => (exceptions.reserved || [])
  .find((entry) => entry.binding === binding);

test(`${label}: every row declares a known policy and context`, () => {
  const policies = new Set(['free', 'override', 'gated']);
  const contexts = new Set(['always', 'preview', 'editor', 'no-editor']);
  for (const chord of chords) {
    assert.ok(policies.has(chord.policy),
      `${chord.binding}: unknown policy ${chord.policy}`);
    assert.ok(contexts.has(chord.when),
      `${chord.binding}: unknown context ${chord.when}`);
    assert.ok(chord.label, `${chord.binding}: no label`);
  }
});

test(`${label}: a %free chord is claimed by neither keymap`, () => {
  for (const chord of chords.filter((item) => item.policy === 'free')) {
    const taken = claims(chord.binding);
    assert.deepEqual(taken, [],
      `${chord.binding} is declared %free but ${taken
        .map((entry) => `${entry.keymap}/${entry.context} ${entry.action}`)
        .join('; ')}`);
  }
});

test(`${label}: a %override chord really displaces something`, () => {
  for (const chord of chords.filter((item) => item.policy === 'override')) {
    const taken = claims(chord.binding);
    const excepted = overrideFor(chord.binding);
    //  An override that displaces nothing is mislabelled and should be
    //  %free -- unless the exception says the command is absent from
    //  the pinned bundle, which is a claim about this build, not the
    //  upstream table.
    if (!taken.length) {
      assert.ok(excepted?.unshipped,
        `${chord.binding} is %override but neither keymap claims it`);
    }
    assert.ok(excepted,
      `${chord.binding} is %override with no shortcut-exceptions entry`);
    assert.equal(excepted.command, chord.command);
    assert.ok(excepted.displaces, `${chord.binding}: nothing recorded as displaced`);
    assert.ok(excepted.alternative,
      `${chord.binding}: no alternative route to what it displaced`);
  }
});

test(`${label}: a %gated chord never fires everywhere`, () => {
  for (const chord of chords.filter((item) => item.policy === 'gated')) {
    assert.notEqual(chord.when, 'always',
      `${chord.binding} is %gated, so it cannot be when=always`);
  }
});

test(`${label}: an editing chord is gated, not free`, () => {
  //  A chord either keymap claims may still be taken, but only as a
  //  documented override or outside the editor.  Declaring it %free is
  //  the mistake this catches.
  for (const chord of chords) {
    if (!claims(chord.binding).length) continue;
    assert.notEqual(chord.policy, 'free',
      `${chord.binding} is claimed by a keymap but declared %free`);
  }
});

test(`${label}: no two rows share a binding in one context`, () => {
  const seen = new Map();
  for (const chord of chords) {
    const key = `${chord.binding} ${chord.when}`;
    assert.ok(!seen.has(key),
      `${chord.binding} is bound twice in ${chord.when}: `
      + `${seen.get(key)} and ${chord.command}`);
    seen.set(key, chord.command);
  }
});

test(`${label}: a browser-reserved chord is justified`, () => {
  for (const chord of chords) {
    if (!reserved.includes(chord.binding)) continue;
    const excepted = reservedFor(chord.binding);
    assert.ok(excepted,
      `${chord.binding} is kept by the browser and has no `
      + 'shortcut-exceptions entry');
    assert.equal(excepted.command, chord.command);
    assert.ok(excepted.reason, `${chord.binding}: no reason recorded`);
  }
});

test(`${label}: every command has somewhere to come from`, () => {
  //  urui registers its two dialogs and a store's four actions; the
  //  app registers the rest in its own javascript.  A command named by
  //  neither is a chord that silently does nothing on a ship.
  const source = fs.readFileSync(file, 'utf8');
  const stores = [...source.matchAll(/name=%([a-z-]+)/g)].map((m) => m[1]);
  const uruiOwned = new Set(['help', 'settings']);
  const storeActions = new Set(['open', 'save', 'save-as', 'copy']);
  for (const chord of chords) {
    if (uruiOwned.has(chord.command)) continue;
    const [action, store] = chord.command.split(':');
    if (store) {
      assert.ok(storeActions.has(action),
        `${chord.command}: urui registers no ${action} for a store`);
      assert.ok(stores.includes(store),
        `${chord.command}: no store named ${store} is declared`);
      continue;
    }
    //  Either named at the call -- `register('parse', …)` -- or a key
    //  in a map the app loops over, which is equally a registration
    //  and equally greppable.
    const name = action.replace(/[-]/g, '\\-');
    const named = new RegExp(`shortcuts\\.register\\('${name}'`);
    const looped = /shortcuts\.register\((?:command|name|key)\b/.test(source)
      && new RegExp(`(?:^|[\\s{])'?${name}'?:`, 'm').test(source);
    assert.ok(named.test(source) || looped,
      `${chord.command}: nothing registers it`);
  }
});

test(`${label}: the exceptions file describes only real rows`, () => {
  const bindings = new Set(chords.map((chord) => chord.binding));
  for (const entry of exceptions.overrides || []) {
    assert.ok(bindings.has(entry.binding),
      `exceptions name ${entry.binding}, which the table no longer binds`);
  }
  for (const entry of exceptions.reserved || []) {
    assert.ok(bindings.has(entry.binding),
      `exceptions name ${entry.binding}, which the table no longer binds`);
  }
});
