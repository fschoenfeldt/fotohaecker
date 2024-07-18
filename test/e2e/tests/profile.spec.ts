import { test, expect } from "../fixtures/axe-test";
import {
  auth0UserManagementEnabled,
  photographerFixture,
  userFixture,
} from "./helpers";

test.describe("User Profile page", () => {
  test.describe("User", () => {
    test.beforeEach(async ({ page }) => {
      if (auth0UserManagementEnabled) {
        const { id } = userFixture;
        await page.goto("/fh/en_US/user");
        await page.click("text=logout");
        await page.goto(`/fh/en_US/user/${encodeURIComponent(id)}`);
      } else {
        console.info(
          `Skipping Auth tests because environment variables are not set.`
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

  test.describe("Photographer", () => {
    test.beforeEach(async ({ page }) => {
      if (auth0UserManagementEnabled) {
        const { id } = photographerFixture;
        await page.goto("/fh/en_US/user");
        await page.click("text=logout");
        await page.goto(`/fh/en_US/user/${encodeURIComponent(id)}`);
      } else {
        console.info(
          `Skipping Auth tests because environment variables are not set.`
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
});
