const {test, expect} = require('@playwright/test');
const {installBackend, setEditorSource, openReady} =
  require('./fixtures/backend.js');

const cell = (name, aura, value) => ({name, aura, value});

const commands = [
  {
    index: 0,
    results: [
      {
        type: 'result-set',
        value: {
          columns: [{name: 'id', aura: '@ud'}],
          rows: [[cell('id', '@ud', '1')], [cell('id', '@ud', '2')]]
        }
      },
      {type: 'message', value: 'first'}
    ]
  },
  {
    index: 1,
    results: [
      {
        type: 'result-set',
        value: {
          columns: [{name: 'name', aura: '@t'}],
          rows: [[cell('name', '@t', 'bolt')]]
        }
      },
      {type: 'message', value: 'second'}
    ]
  }
];

//  The command strip is urui's dynamic tab level; each command's
//  Results/Messages tabs are obelisk's markup on urui's tablist helper.
test('multi-command results switch by keyboard at both levels',
  async ({page}) => {
    const calls = [];
    await installBackend(page, {run: () => commands, calls});
    await openReady(page);
    const script = 'FROM db1.dbo.widgets SELECT id;\n' +
      'FROM db1.dbo.widgets SELECT name;';
    await setEditorSource(page, script);
    await page.locator('#run-btn').click();

    const strip = page.locator('#output-pane-command-tabs');
    await expect(strip.getByRole('tab')).toHaveText(['Command 1', 'Command 2']);
    expect(calls.find((call) => call.op === 'run').body)
      .toMatchObject({type: 'run', script});

    //  outer: Right moves to Command 2 and shows its panel
    await strip.getByRole('tab', {name: 'Command 1'}).focus();
    await page.keyboard.press('ArrowRight');
    await expect(strip.getByRole('tab', {name: 'Command 2'}))
      .toHaveAttribute('aria-selected', 'true');
    await expect(page.locator('#command-tab-panel-1')).toBeVisible();
    await expect(page.locator('#command-tab-panel-0')).toBeHidden();

    //  inner: one tab stop; Right and Home select by keyboard
    const panel = page.locator('#command-tab-panel-1');
    const results = panel.getByRole('tab', {name: 'Results'});
    const messages = panel.getByRole('tab', {name: 'Messages'});
    await expect(results).toHaveAttribute('tabindex', '0');
    await expect(messages).toHaveAttribute('tabindex', '-1');
    await expect(panel.locator('#command-1-results')).toContainText('bolt');

    await results.focus();
    await page.keyboard.press('ArrowRight');
    await expect(messages).toBeFocused();
    await expect(messages).toHaveAttribute('aria-selected', 'true');
    await expect(messages).toHaveAttribute('tabindex', '0');
    await expect(results).toHaveAttribute('tabindex', '-1');
    await expect(panel.locator('#command-1-messages')).toBeVisible();
    await expect(panel.locator('#command-1-messages')).toContainText('second');
    await expect(panel.locator('#command-1-results')).toBeHidden();

    await page.keyboard.press('ArrowRight');
    await expect(results).toBeFocused();
    await page.keyboard.press('End');
    await expect(messages).toBeFocused();
    await page.keyboard.press('Home');
    await expect(results).toBeFocused();
    await expect(results).toHaveAttribute('aria-selected', 'true');
    await expect(panel.locator('#command-1-results')).toBeVisible();
  });

//  urui's fullscreen toggle expands the whole output pane, so a paged
//  result keeps its pagers, and its command tabs, while expanded.
test('fullscreen output keeps the result pagers', async ({page}) => {
  const rows = Array.from({length: 900}, (_, index) => {
    return [cell('id', '@ud', String(index + 1))];
  });
  const paged = [{
    index: 0,
    results: [{
      type: 'result-set',
      value: {columns: [{name: 'id', aura: '@ud'}], rows}
    }]
  }];
  await installBackend(page, {run: () => paged, calls: []});
  await openReady(page);
  await setEditorSource(page, 'FROM t SELECT *');
  await page.locator('#run-btn').click();

  const toggle = page.locator('#output-fullscreen');
  await expect(toggle).toHaveAttribute('title', 'Expand results to fullscreen');
  await toggle.click();
  await expect.poll(() => page.evaluate(() => {
    return document.fullscreenElement?.id;
  })).toBe('output-pane');
  await expect(toggle).toHaveAttribute('aria-pressed', 'true');

  const pager = page.locator('#output-pane .result-pager-top');
  await expect(pager).toBeVisible();
  await expect(pager.locator('.result-pager-status'))
    .toContainText('Page 1 of 2');
  await pager.getByRole('button', {name: 'Next'}).click();
  await expect(pager.locator('.result-pager-status'))
    .toContainText('Page 2 of 2');

  await toggle.click();
  await expect.poll(() => page.evaluate(() => {
    return document.fullscreenElement === null;
  })).toBe(true);
  await expect(toggle).toHaveAttribute('aria-pressed', 'false');
});
