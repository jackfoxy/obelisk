'use strict';

// Playwright double for %obelisk-web's HTTP surface: the api routes under
// /apps/obelisk/api, urui's json file wire at /apps/obelisk/files, and a
// docs site that is not installed.
//
// `installBackend(page, options)`:
//   * schema: the value `api/schema` answers (default `sampleSchema`)
//   * run(body): the `commands` `api/run` answers; its resultId is '7'
//   * files: a Map of joined Clay path (`scripts/q1/txt`) to text; browse
//     lists it by scope, load reads it, save and a result export write it
//   * exportText(body): the text a result export stores
//   * calls: an array every api and file request is pushed to, as
//     `{op, body}`; file ops are `files:browse`, `files:load`, and so on

const sampleSchema = {
  defaultDatabase: 'db1',
  databases: [{
    name: 'db1',
    default: true,
    namespaces: [{
      name: 'dbo',
      relations: [{
        database: 'db1',
        namespace: 'dbo',
        name: 'widgets',
        kind: 'table',
        columns: [
          {
            name: 'id', aura: '@ud', bunt: '0', ordinal: 1,
            key: {ordinal: 1, ascending: true}
          },
          {name: 'name', aura: '@t', bunt: "''", ordinal: 2, key: null}
        ],
        foreignKeys: []
      }]
    }]
  }]
};

//  what the agent would hash; any stable token will do here
function hashOf(text) {
  let hash = 0;
  for (const char of String(text)) {
    hash = (hash * 31 + char.codePointAt(0)) | 0;
  }
  return `0v${(hash >>> 0).toString(32)}`;
}

function json(status, body) {
  return {status, contentType: 'application/json', body: JSON.stringify(body)};
}

function error(code, message) {
  return {code, message, retryable: false, details: []};
}

async function installBackend(page, options = {}) {
  const {
    schema = sampleSchema,
    run = () => [],
    files = new Map(),
    exportText = () => '',
    calls = []
  } = options;

  await page.route('**/docs', (route) => {
    return route.fulfill({status: 404, contentType: 'text/plain', body: ''});
  });

  await page.route('**/apps/obelisk/api/**', async (route) => {
    const request = route.request();
    const body = JSON.parse(request.postData() || '{}');
    const op = new URL(request.url()).pathname
      .replace('/apps/obelisk/api/', '');
    calls.push({op, body});
    if (op === 'schema') {
      return route.fulfill(json(200, {type: 'schema', value: schema}));
    }
    if (op === 'run') {
      return route.fulfill(json(200, {
        type: 'run', resultId: '7', commands: run(body), schemaChanged: false
      }));
    }
    if (op === 'results/save' || op === 'results/save-text') {
      const joined = body.path.join('/');
      if (files.has(joined) && !body.overwrite) {
        return route.fulfill(json(409, {
          ok: false, error: error('exists', `${joined} exists`)
        }));
      }
      files.set(joined, op === 'results/save' ? exportText(body) : body.text);
      return route.fulfill(json(200, {ok: true}));
    }
    return route.fulfill(json(404, {
      type: 'error', error: error('not-found', `no route ${op}`)
    }));
  });

  await page.route('**/apps/obelisk/files', async (route) => {
    const body = JSON.parse(route.request().postData() || '{}');
    calls.push({op: `files:${body.op}`, body});
    if (body.op === 'browse') {
      const prefix = `${(body.scope || []).join('/')}/`;
      const entries = [...files.keys()]
        .filter((key) => key.startsWith(prefix))
        .map((key) => ({path: key.split('/'), kind: 'file'}));
      return route.fulfill(json(200, {ok: true, entries}));
    }
    const joined = (body.path || []).join('/');
    if (body.op === 'load') {
      if (!files.has(joined)) {
        return route.fulfill(json(404, {
          ok: false, error: error('not-found', `${joined} not found`)
        }));
      }
      const text = files.get(joined);
      return route.fulfill(json(200, {ok: true, text, hash: hashOf(text)}));
    }
    if (body.op === 'save') {
      files.set(joined, body.text);
      return route.fulfill(json(200, {ok: true, hash: hashOf(body.text)}));
    }
    if (body.op === 'delete') files.delete(joined);
    return route.fulfill(json(200, {ok: true}));
  });
}

//  The editor urui mounted for the `script` store, through the facade.
function editorSource(page) {
  return page.evaluate(() => window.urui.editor.primary().getSource());
}

function setEditorSource(page, text) {
  return page.evaluate((value) => {
    window.urui.editor.primary().setSource(value);
  }, text);
}

async function openReady(page) {
  await page.goto('/apps/obelisk/');
  await page.locator('html[data-obelisk="ready"]').waitFor({state: 'attached'});
}

module.exports = {
  installBackend, sampleSchema, editorSource, setEditorSource, openReady
};
