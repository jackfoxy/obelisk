const {test, expect} = require('@playwright/test');
const {installBackend, editorSource, setEditorSource, openReady} =
  require('./fixtures/backend.js');

const command = {
  index: 0,
  results: [{
    type: 'result-set',
    value: {
      columns: [{name: 'id', aura: '@ud'}],
      rows: [
        [{name: 'id', aura: '@ud', value: '1'}],
        [{name: 'id', aura: '@ud', value: '2'}]
      ]
    }
  }]
};

//  Export goes through urui's file dialog with obelisk's format field;
//  the agent writes it under /results, which the tree then offers, and
//  it reopens read-only because /results has no user save.
test('an exported result reopens from the Files view, read-only',
  async ({page}) => {
    const calls = [];
    const files = new Map();
    await installBackend(page, {
      run: () => [command], files, calls, exportText: () => 'id\n1\n2\n'
    });
    await openReady(page);
    await setEditorSource(page, 'FROM db1.dbo.widgets SELECT id;');
    await page.locator('#run-btn').click();
    await expect(page.locator('#results')).toContainText('2');

    const save = page.locator('#save-output-btn');
    await expect(save).toBeEnabled();
    await save.click();
    const dialog = page.locator('#urui-file-dialog');
    await expect(dialog).toBeVisible();
    await expect(page.locator('#urui-file-dialog-title'))
      .toHaveText('Save results');
    await expect(page.locator('#urui-file-dialog-path'))
      .toHaveValue('results-1');
    await expect(page.locator('#results-format-select')).toHaveValue('%csv');
    await page.locator('#urui-file-dialog-confirm').click();
    await expect(dialog).toBeHidden();

    await expect.poll(() => {
      return calls.find((call) => call.op === 'results/save')?.body;
    }).toMatchObject({
      type: 'result-save',
      resultId: '7',
      commandIndex: '0',
      format: 'csv',
      path: ['results', 'results-1', 'csv'],
      overwrite: false
    });
    await expect(page.locator('#urui-toast-message'))
      .toHaveText('Saved results-1.csv.');

    await page.locator('[data-explorer-view="files"]').click();
    const file = page.locator('[data-path="results/results-1/csv"]');
    await expect(file).toBeVisible();
    await file.click();
    await expect(page.locator('#editor-pane-script-tabs')
      .getByRole('tab', {name: 'results-1.csv', exact: true}))
      .toHaveAttribute('aria-selected', 'true');
    await expect.poll(() => editorSource(page)).toBe('id\n1\n2\n');
    await expect(page.locator('#script-save')).toBeHidden();
  });
