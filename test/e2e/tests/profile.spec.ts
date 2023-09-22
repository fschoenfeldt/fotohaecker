import { test, expect } from "../fixtures/axe-test";
import { userFixture } from "./helpers";

test.describe("User Profile page", () => {
  test.beforeEach(async ({ page }) => {
    const { id } = userFixture;
    await page.goto("/fh/en_US/user");
    await page.click("text=logout");
    await page.goto(`/fh/en_US/user/${encodeURIComponent(id)}`);
  });

  test("should not have any automatically detectable accessibility issues", async ({
    makeAxeBuilder,
  }) => {
    test.slow();
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("should not have any automatically detectable accessibility issues in dark mode", async ({
    page,
    makeAxeBuilder,
  }) => {
    test.slow();
    await page.emulateMedia({ colorScheme: "dark" });
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});
