import { test, expect } from "../../fixtures/axe-test";
import { photographerFixture } from "../helpers";

test.describe("User Settings page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
    await page.locator("a", { hasText: "your account" }).click();
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
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

  test("can visit account settings page", async ({ page }) => {
    const { email, password } = photographerFixture;

    await expect(page.locator("h1")).toHaveText("Your Account");
    // can't check for mail because Auth0UserManagement isn't enabled.
    // await expect(page.locator("div#user")).toContainText(email);
  });

  test("can open donation dashboard", async ({ page }) => {
    await page.locator("a", { hasText: "donation dashboard" }).click();
    await expect(page.locator("h1")).toHaveText("Donations");
  });

  test("can logout", async ({ page }) => {
    await page.locator("button", { hasText: "logout" }).click();
    await expect(page.locator(".alert--info")).toContainText("logged out");
    await page.locator(".alert--info").click();
    await expect(page.locator("a", { hasText: "login" })).toBeVisible();
  });
});
