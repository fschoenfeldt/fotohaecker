import { test, expect } from "@playwright/test";
import { userFixture } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe.skip("User Profile page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh/en_US/user/auth0%7C647dba8fe4e45a9886c854ad");
    const el = await page.waitForSelector("[data-testid='profile-picture']", {
      timeout: 10000,
    });
    const src = await el.getAttribute("src");
    console.log(`src: ${src}`);

    // await page.waitForTimeout(10000);
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
  }) => {
    test.slow();
    const accessibilityScanResults = await new AxeBuilder({ page })
      .exclude("canvas")
      .analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("should not have any automatically detectable accessibility issues in dark mode", async ({
    page,
  }) => {
    test.slow();
    await page.emulateMedia({ colorScheme: "dark" });
    const accessibilityScanResults = await new AxeBuilder({ page })
      .exclude("canvas")
      .analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
