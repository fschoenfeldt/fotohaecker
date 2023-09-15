import { test, expect } from "../fixtures/axe-test";

test.describe.skip("User Profile page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh/en_US/user");
    await page.click("text=logout");
    await page.goto("/fh/en_US/user/auth0%7C647dba8fe4e45a9886c854ad");
    // await page.waitForTimeout(2000);
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
    makeAxeBuilder,
    browserName,
  }) => {
    if (browserName !== "chromium") {
      test.skip();
    }

    test.slow();
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("should not have any automatically detectable accessibility issues in dark mode", async ({
    page,
    makeAxeBuilder,
    browserName,
  }) => {
    if (browserName !== "chromium") {
      test.skip();
    }

    test.slow();
    await page.emulateMedia({ colorScheme: "dark" });
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
