const {test, expect} = require('@playwright/test');
const {installBackend, setEditorSource, editorSource, openReady} =
  require('./fixtures/backend.js');

async function expectRightmost(page) {
  const button = page.locator('#script-ref');
  await expect(button).toHaveText('Add Ref');
  expect(await button.evaluate(node => {
    const bounds = node.getBoundingClientRect();
    return node === node.parentElement.lastElementChild &&
      [...node.parentElement.children].every(sibling =>
        sibling === node || !sibling.getClientRects().length ||
        sibling.getBoundingClientRect().right <= bounds.left);
  })).toBe(true);
}

test('Add Ref mirrors the current script and shares drag-and-drop references',
  async ({page}) => {
    await installBackend(page);
    await openReady(page);
    await expectRightmost(page);
    const button = page.locator('#script-ref');
    await expect(button).toBeDisabled();
    const source = 'FROM db1.dbo.widgets SELECT id;';
    await setEditorSource(page, source);
    await expect(button).toBeEnabled();
    await button.click();
    const refs = page.locator('[data-ref-tab]');
    await expect(refs).toHaveCount(1);
    await expect(refs.getByRole('tab'))
      .toHaveAttribute('aria-selected', 'true');
    const content = page.locator('.ref-explorer-panel:visible .ref-source');
    await expect(content).toHaveText(source);

    const edited = `${source}\nFROM db1.dbo.widgets SELECT name;`;
    await setEditorSource(page, edited);
    await expect(content).toHaveText(edited);
    await page.locator('[data-explorer-view="files"]').click();
    await button.click();
    await expect(refs).toHaveCount(1);
    await expect(content).toBeVisible();

    // Every region of the reference pane accepts a document-tab drop.
    const sourceTab = page.locator(
      '#editor-pane-script-tabs [draggable="true"]'
    );
    for (const target of [
      '#explorer-pane-ship', '#explorer-pane-view-tabs', '#files-panel'
    ]) {
      await sourceTab.dragTo(page.locator(target));
      await expect(refs).toHaveCount(1);
      await expect(content).toHaveText(edited);
      await page.locator('.ref-tab-close').click();
      await expect(refs).toHaveCount(0);
      await page.locator('[data-explorer-view="files"]').click();
    }
    expect(await editorSource(page)).toBe(edited);
  });

test('Add Ref stays rightmost with preview controls and follows the active tab',
  async ({page}) => {
    const files = new Map([
      ['scripts/first/txt', 'FROM first SELECT *;'],
      ['results/second/md', '# Second result']
    ]);
    await installBackend(page, {files});
    await openReady(page);
    await page.locator('[data-explorer-view="files"]').click();
    await page.locator('[data-path="scripts/first/txt"]').click();
    await expect.poll(() => editorSource(page)).toBe(files.get('scripts/first/txt'));
    await page.locator('#script-ref').click();
    await page.locator('[data-explorer-view="files"]').click();
    await page.locator('[data-path="results/second/md"]').click();
    await expect(page.locator('#script-display')).toBeVisible();
    await expectRightmost(page);
    await page.locator('#script-ref').click();
    const refs = page.locator('[data-ref-tab]');
    await expect(refs).toHaveCount(2);
    await expect(refs.getByRole('tab', {name: 'second.md', exact: true}))
      .toHaveAttribute('aria-selected', 'true');
    await expect(page.locator('.ref-explorer-panel:visible'))
      .toContainText('Second result');
    await page.locator('#editor-pane-script-tabs')
      .getByRole('tab', {name: 'first.txt', exact: true}).click();
    await page.locator('#script-ref').click();
    await expect(refs).toHaveCount(2);
    await expect(refs.getByRole('tab', {name: 'first.txt', exact: true}))
      .toHaveAttribute('aria-selected', 'true');
    await expect(page.locator('.ref-explorer-panel:visible .ref-source'))
      .toHaveText(files.get('scripts/first/txt'));
  });
