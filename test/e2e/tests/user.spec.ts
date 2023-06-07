import { test, expect } from "@playwright/test";
import { userFixture } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("User Settings page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
  }) => {
    test.slow();
    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("can visit account settings page", async ({ page }) => {
    const { email, password } = userFixture;
    await page.locator("a", { hasText: "your account" }).click();

    await expect(page.locator("h1")).toHaveText("Your Account");
    await expect(page.locator("div#user")).toContainText(email);
  });

  test("can logout", async ({ page }) => {
    await page.locator("a", { hasText: "your account" }).click();
    await page.locator("a", { hasText: "logout" }).click();
    await expect(page.locator(".alert--info")).toContainText("logged out");
    await page.locator(".alert--info").click();
    await expect(page.locator("a", { hasText: "login" })).toBeVisible();
  });
});
