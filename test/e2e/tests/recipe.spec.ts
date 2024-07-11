import { test, expect } from "../fixtures/axe-test";
import { recipeManagementEnabled, userFixture } from "./helpers";

test.describe("Recipe page", () => {
  test.beforeEach(async ({ page }) => {
    if (recipeManagementEnabled) {
      await page.goto("/fh/en_US/recipes/1");
    } else {
      console.info(
        `Skipping Recipe tests because environment variables are not set.`
      );
      test.skip();
    }
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
