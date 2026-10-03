const {defineConfig, devices} = require('@playwright/test');

const externalServer = Boolean(process.env.OBELISK_URL);
const baseURL = process.env.OBELISK_URL || 'http://127.0.0.1:4174';

module.exports = defineConfig({
  testDir: __dirname,
  testMatch: '*.spec.js',
  fullyParallel: false,
  forbidOnly: true,
  retries: 0,
  workers: 1,
  reporter: 'line',
  webServer: externalServer ? undefined : {
    command: 'node serve-app.js',
    url: `${baseURL}/apps/obelisk/`,
    reuseExistingServer: false,
    timeout: 180_000
  },
  use: {
    ...devices['Desktop Chrome'],
    baseURL,
    locale: 'en-US',
    timezoneId: 'UTC',
    colorScheme: 'light',
    trace: 'off',
    screenshot: 'off',
    video: 'off'
  },
  projects: [{
    name: 'chromium',
    use: {browserName: 'chromium'}
  }]
});
