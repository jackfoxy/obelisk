const {test, expect} = require('@playwright/test');
const {installBackend, setEditorSource, editorSource, openReady} =
  require('./fixtures/backend.js');

const source = 'FROM db1.dbo.widgets SELECT id;';
const executionCalls = calls => calls.filter(call =>
  call.op === 'parse' || call.op === 'run');

async function focus(page, target) {
  await page.locator(target === 'editor'
    ? '#query-editor .ace_text-input' : '#default-db').focus();
}

for (const target of ['editor', 'toolbar']) {
  for (const [key, button, panel, close, otherPanel] of [
    ['F1', 'help', 'help-panel', 'close-help', 'settings-modal'],
    ['F2', 'settings', 'settings-modal', 'close-settings', 'help-panel']
  ]) {
    test(`${key} opens ${button} from ${target} and respects modal focus`,
      async ({page}) => {
        const calls = [];
        await installBackend(page, {calls});
        await openReady(page);
        await setEditorSource(page, source);
        await focus(page, target);
        await expect(page.locator(`#${button}`))
          .toHaveAttribute('aria-keyshortcuts', key);
        await expect(page.locator(`#${button}`))
          .toHaveAttribute('title', new RegExp(key));
        const badge = page.locator(`#${button} kbd`);
        await expect(badge).toHaveText(key);
        await expect(badge).toHaveCSS('font-size',
          await page.locator('#run-btn kbd').evaluate(node =>
            getComputedStyle(node).fontSize));
        await page.keyboard.press(key);
        await expect(page.locator(`#${panel}`)).toBeVisible();
        await expect(page.locator(`#${close}`)).toBeFocused();
        await expect(page.locator(`#${button}`))
          .toHaveAttribute('aria-expanded', 'true');

        // Bound keys behind a modal must not open another dialog or execute.
        for (const chord of ['F1', 'F2', 'F3', 'F5']) {
          await page.keyboard.press(chord);
        }
        await expect(page.locator(`#${otherPanel}`)).toBeHidden();
        await page.keyboard.press('Escape');
        await expect(page.locator(`#${panel}`)).toBeHidden();
        await expect(page.locator(target === 'editor'
          ? '#query-editor .ace_text-input' : '#default-db')).toBeFocused();
        await expect(page.locator(`#${button}`))
          .toHaveAttribute('aria-expanded', 'false');
        expect(executionCalls(calls)).toEqual([]);
        expect(await editorSource(page)).toBe(source);
      });
  }

  test(`F3 parses without running from ${target}`, async ({page}) => {
    const calls = [];
    await installBackend(page, {calls, parse: () => 'parsed widgets'});
    await openReady(page);
    await expect(page.locator('#default-db')).toHaveValue('db1');
    await setEditorSource(page, source);
    await focus(page, target);
    await expect(page.locator('#parse-btn'))
      .toHaveAttribute('aria-keyshortcuts', 'F3');
    await page.keyboard.press('F3');
    await expect(page.locator('#results .parse-output'))
      .toHaveText('parsed widgets');
    expect(executionCalls(calls)).toEqual([{
      op: 'parse', body: {type: 'parse', defaultDatabase: 'db1', script: source}
    }]);
    expect(await editorSource(page)).toBe(source);
    await expect(page.locator('#parse-btn')).toBeEnabled();
    await expect(page.locator('#parse-btn kbd')).toHaveText('F3');
  });
}

test('Settings topics use consistent vertical spacing', async ({page}) => {
  await installBackend(page);
  await openReady(page);
  await page.locator('#settings').click();
  const margins = await page.locator(
    '#settings-modal .settings-card > .settings-field'
  ).evaluateAll(fields => fields.map(
    field => getComputedStyle(field).marginTop
  ));
  expect(margins).toEqual(['16px', '16px', '16px']);
});

test('F3 parses only the selected text', async ({page}) => {
  const calls = [];
  await installBackend(page, {calls});
  await openReady(page);
  await setEditorSource(page, `${source}\nFROM other SELECT *;`);
  await focus(page, 'editor');
  await page.keyboard.press('Control+Home');
  await page.keyboard.press('Shift+End');
  await page.keyboard.press('F3');
  await expect(page.locator('#results .parse-output')).toHaveText('parsed script');
  expect(executionCalls(calls)).toHaveLength(1);
  expect(executionCalls(calls)[0].body.script).toBe(source);
});

test('F3 does not submit again while parsing', async ({page}) => {
  const calls = [];
  let finish;
  const pending = new Promise(resolve => { finish = resolve; });
  await installBackend(page, {calls, parse: () => pending});
  await openReady(page);
  await setEditorSource(page, source);
  await focus(page, 'editor');
  try {
    await page.keyboard.press('F3');
    await expect.poll(() => executionCalls(calls).length).toBe(1);
    await expect(page.locator('#parse-btn')).toBeDisabled();
    await expect(page.locator('#parse-btn span')).toHaveText('Parsing…');
    await expect(page.locator('#parse-btn kbd')).toHaveText('F3');
    await page.keyboard.press('F3');
    await page.keyboard.press('F5');
  } finally {
    finish('parse completed');
  }
  await expect(page.locator('#results .parse-output')).toHaveText('parse completed');
  await expect(page.locator('#parse-btn')).toBeEnabled();
  await expect(page.locator('#parse-btn span')).toHaveText('Parse');
  await expect(page.locator('#parse-btn kbd')).toHaveText('F3');
  expect(executionCalls(calls)).toHaveLength(1);
});

test('F3 is disabled for an opened result file', async ({page}) => {
  const calls = [];
  const files = new Map([['results/example/csv', 'id\n1\n']]);
  await installBackend(page, {calls, files});
  await openReady(page);
  await page.locator('[data-explorer-view="files"]').click();
  await page.locator('[data-path="results/example/csv"]').click();
  await expect.poll(() => editorSource(page)).toBe('id\n1\n');
  await expect(page.locator('#parse-btn')).toBeDisabled();
  await focus(page, 'editor');
  await page.keyboard.press('F3');
  await page.keyboard.press('F5');
  expect(executionCalls(calls)).toEqual([]);
  expect(await editorSource(page)).toBe('id\n1\n');
});

test('modified function keys do not trigger workbench actions', async ({page}) => {
  const calls = [];
  await installBackend(page, {calls});
  await openReady(page);
  await focus(page, 'toolbar');
  for (const modifier of ['Shift', 'Control', 'Alt', 'Meta']) {
    for (const key of ['F1', 'F2', 'F3']) {
      await page.keyboard.press(`${modifier}+${key}`);
    }
  }
  await expect(page.locator('#help-panel')).toBeHidden();
  await expect(page.locator('#settings-modal')).toBeHidden();
  expect(executionCalls(calls)).toEqual([]);
});
