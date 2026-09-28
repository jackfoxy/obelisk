const {test, expect} = require('@playwright/test');
const {installBackend, sampleSchema, editorSource, openReady} =
  require('./fixtures/backend.js');

//  Schema → relation menu → a new query script, by keyboard: the menu is
//  urui's (runtime.a11y.menu), the template and the script store call are
//  obelisk's.
test('a relation template opens as a new script from the keyboard',
  async ({page}) => {
    await installBackend(page);
    await openReady(page);

    const tree = page.locator('#schemas-tree');
    await tree.locator('summary', {hasText: 'db1'}).click();
    await tree.locator('summary', {hasText: 'dbo'}).click();
    const actions = page.getByRole('button', {name: 'Actions for widgets'});
    await expect(actions).toHaveAttribute('aria-haspopup', 'menu');
    await expect(actions).toHaveAttribute('aria-expanded', 'false');

    //  Enter opens it on the first item; Escape closes it back to `…`
    const menu = page.locator('#relation-menu');
    await actions.focus();
    await page.keyboard.press('Enter');
    await expect(menu).toBeVisible();
    await expect(actions).toHaveAttribute('aria-expanded', 'true');
    await expect(page.locator('#relation-select')).toBeFocused();
    await page.keyboard.press('ArrowDown');
    await expect(page.locator('#relation-insert')).toBeFocused();
    await page.keyboard.press('Escape');
    await expect(menu).toBeHidden();
    await expect(actions).toBeFocused();
    await expect(actions).toHaveAttribute('aria-expanded', 'false');

    //  End, Up, and Enter pick INSERT
    await page.keyboard.press('Enter');
    await expect(page.locator('#relation-select')).toBeFocused();
    await page.keyboard.press('End');
    await expect(page.locator('#relation-create')).toBeFocused();
    await page.keyboard.press('ArrowUp');
    await expect(page.locator('#relation-insert')).toBeFocused();
    await page.keyboard.press('Enter');
    await expect(menu).toBeHidden();

    const tabs = page.locator('#editor-pane-script-tabs [role="tab"]');
    await expect(tabs).toHaveCount(2);
    await expect(tabs.nth(1)).toHaveAttribute('aria-selected', 'true');
    await expect.poll(() => editorSource(page)).toBe(
      "INSERT INTO db1.dbo.widgets\n  (id, name)\nVALUES\n  (0, '');"
    );
  });

//  A view has no INSERT or CREATE; the menu skips what it hides.
test('a view offers SELECT alone', async ({page}) => {
  const schema = structuredClone(sampleSchema);
  schema.databases[0].namespaces[0].relations[0].kind = 'view';
  await installBackend(page, {schema});
  await openReady(page);

  const tree = page.locator('#schemas-tree');
  await tree.locator('summary', {hasText: 'db1'}).click();
  await tree.locator('summary', {hasText: 'dbo'}).click();
  await page.getByRole('button', {name: 'Actions for widgets'}).focus();
  await page.keyboard.press('Enter');
  await expect(page.locator('#relation-insert')).toBeHidden();
  await expect(page.locator('#relation-create')).toBeHidden();
  await expect(page.locator('#relation-select')).toBeFocused();
  await page.keyboard.press('ArrowDown');
  await expect(page.locator('#relation-select')).toBeFocused();
  await page.keyboard.press('Escape');
});
