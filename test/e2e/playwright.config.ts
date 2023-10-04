import { FullConfig, defineConfig, devices } from "@playwright/test";
import { authFilePhotographer, authFileUser } from "./tests/helpers";

const PORT = 1338;

/**
 * Read environment variables from file.
 * https://github.com/motdotla/dotenv
 */
// require('dotenv').config();

/**
 * See https://playwright.dev/docs/test-configuration.
 */
export default defineConfig({
  // timeout: 10 * 1000,
  testDir: "./tests",
  testIgnore: "tests/photographer/**/*",
  /* Run tests in files in parallel */
  fullyParallel: true,
  /* Fail the build on CI if you accidentally left test.only in the source code. */
  forbidOnly: !!process.env.CI,
  /* Retry on CI only */
  retries: process.env.CI ? 2 : 0,
  /* Opt out of parallel tests on CI. */
  workers: process.env.CI ? 1 : undefined,
  /* Reporter to use. See https://playwright.dev/docs/test-reporters */
  reporter: "html",
  /* Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions. */
  use: {
    /* Base URL to use in actions like `await page.goto('/')`. */
    baseURL: `http://localhost:${PORT}/fh`,

    /* Collect trace when retrying the failed test. See https://playwright.dev/docs/trace-viewer */
    trace: "on-first-retry",
  },

  /* Configure projects for major browsers */
  projects: [
    // source: https://playwright.dev/docs/auth
    // Setup project
    { name: "setup", testMatch: /.*\.setup\.ts/ },
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        // Use prepared auth state.
        storageState: authFileUser,
      },
      dependencies: ["setup"],
    },

    {
      name: "firefox",
      use: {
        ...devices["Desktop Firefox"],
        // Use prepared auth state.
        storageState: authFileUser,
      },
      dependencies: ["setup"],
    },

    {
      name: "webkit",
      use: {
        ...devices["Desktop Safari"],
        storageState: authFileUser,
      },
      dependencies: ["setup"],
    },

    /* Test against mobile viewports. */
    {
      name: "Mobile Chrome",
      use: {
        ...devices["Pixel 6"],
        storageState: authFileUser,
      },
      dependencies: ["setup"],
    },
    {
      name: "Mobile Safari",
      use: {
        ...devices["iPhone 12"],
        storageState: authFileUser,
      },
      dependencies: ["setup"],
    },
    {
      name: "setup photographer",
      testDir: "./tests/photographer",
      testMatch: /.*\.setup\.ts/,
    },
    {
      name: "chromium photographer",
      testDir: "./tests/photographer",
      use: {
        ...devices["Desktop Chrome"],
        // Use prepared auth state.
        storageState: authFilePhotographer,
      },
    },

    /* Test against branded browsers. */
    // {
    //   name: 'Microsoft Edge',
    //   use: { ...devices['Desktop Edge'], channel: 'msedge' },
    // },
    // {
    //   name: 'Google Chrome',
    //   use: { ..devices['Desktop Chrome'], channel: 'chrome' },
    // },
  ],

  /* Run your local dev server before starting the tests */
  webServer: {
    command: `cd ../../ && MIX_ENV=e2e PORT=${PORT} mix phx.server`,
    url: `http://localhost:${PORT}/fh`,
    reuseExistingServer: false,
    timeout: 30 * 1000,
  },
  globalTeardown: require.resolve("./globalTeardown.ts"),
});
