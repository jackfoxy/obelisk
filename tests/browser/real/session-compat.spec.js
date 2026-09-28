const {test, expect} = require('@playwright/test');
const sessionV2 = require('../fixtures/session-v2.json');
const {installBackend, editorSource, openReady} =
  require('./fixtures/backend.js');

const key = 'obelisk.session.v1';
const strip = '#editor-pane-script-tabs';

//  The record obelisk writes today (version 2): urui's slots and
//  obelisk's `workbench` slot come back together, and survive a reload.
test('a v2 session restores tabs, drafts, views, and the workbench',
  async ({context, page}) => {
    await context.addInitScript(([storageKey, session]) => {
      if (!localStorage.getItem(storageKey)) {
        localStorage.setItem(storageKey, JSON.stringify(session));
      }
    }, [key, sessionV2]);
    const files = new Map([
      ['scripts/q1/txt', 'FROM db1.dbo.widgets SELECT id;\n']
    ]);
    await installBackend(page, {files});
    await openReady(page);

    await expect.poll(() => {
      return page.locator(`${strip} .document-tab`).allTextContents();
    }).toEqual(['q1.txt', 'draft-a']);
    await expect(page.locator(strip)
      .getByRole('tab', {name: 'draft-a', exact: true}))
      .toHaveAttribute('aria-selected', 'true');
    await expect(page.locator(`${strip} .active .document-tab-close`))
      .toHaveText('●');
    await expect.poll(() => editorSource(page))
      .toBe('FROM db1.dbo.widgets SELECT name;\n');
    await expect(page.locator('[data-explorer-view="files"]'))
      .toHaveAttribute('aria-selected', 'true');
    await expect(page.locator('#workspace'))
      .toHaveAttribute('data-layout', 'columns');
    await expect(page.locator('#default-db')).toHaveValue('db1');

    //  obelisk's own slot: the saved expansion opens db1
    await page.locator('[data-explorer-view="schemas"]').click();
    await expect.poll(() => page.locator(
      '#schemas-tree details[data-schema-key="db:db1"]'
    ).evaluate((details) => details.open)).toBe(true);

    //  an edit is saved to the record and comes back on reload
    await page.evaluate(() => {
      const editor = window.urui.editor.primary();
      editor.replaceRange(0, 0, '-- kept\n');
    });
    await expect.poll(() => page.evaluate((storageKey) => {
      const record = JSON.parse(localStorage.getItem(storageKey));
      return record.scriptTabs.find((tab) => tab.id === 'script-2')?.text;
    }, key)).toBe('-- kept\nFROM db1.dbo.widgets SELECT name;\n');
    await page.reload();
    await page.locator('html[data-obelisk="ready"]')
      .waitFor({state: 'attached'});
    await expect.poll(() => editorSource(page))
      .toBe('-- kept\nFROM db1.dbo.widgets SELECT name;\n');
    await expect(page.locator('#workspace'))
      .toHaveAttribute('data-layout', 'columns');
  });
