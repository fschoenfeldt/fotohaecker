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
    await page.locator("button", { hasText: "logout" }).click();
    await expect(page.locator(".alert--info")).toContainText("logged out");
    await page.locator(".alert--info").click();
    await expect(page.locator("a", { hasText: "login" })).toBeVisible();
  });
});

// TODO: I'm not sure if we should test this here
// test.describe.serial("Register / Delete User", () => {
//   test.beforeEach(async ({ page }) => {
//     await page.goto("/fh/auth/logout");
//   });

//   test("can register a new user", async ({ page, context }) => {
//     const alert = page.locator(".alert--info");
//     await expect(alert).toContainText("logged out");
//     await alert.click();
//     // clear cookies
//     await context.clearCookies();
//     const loginLink = page.locator("a", { hasText: "login" });
//     await loginLink.click();
//     await page.locator("a", { hasText: "Sign up" }).click();

//     await page.locator("#email").fill("testuser@example.com");
//     await page.locator("#password").fill("Testuser1234");
//     await page.locator("#password").press("Enter");
//     await page.locator("button", { hasText: "Accept" }).click();
//     await expect(alert).toContainText("authenticated");
//     await page.goto("/fh/en_US/user");
//     await page.locator("button", { hasText: "Delete Account" }).click();
//     await expect(alert).toContainText("Your account has been deleted!");
//   });
// });
