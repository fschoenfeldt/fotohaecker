import { test as setup, expect } from "@playwright/test";

const authFile = "playwright/.auth/user.json";

setup("authenticate", async ({ page }) => {
  await page.goto("/fh");
  await page.locator("a", { hasText: "login" }).click();
  await page.locator("#username").fill("test@fschoenfeldt.de");
  await page.locator("#password").fill("Sonne123");
  await page.locator("#password").press("Enter");

  // in case of a new test user, authorize the application
  const authorizeApplication = await page.$("h1");
  if ((await authorizeApplication?.innerHTML()) === "Authorize App") {
    await page.locator('button[type="submit"]', { hasText: "Accept" }).click();
  }

  const authSuccessMessage = page.locator(".alert--info", {
    hasText: "Successfully authenticated",
  });
  await expect(authSuccessMessage).toBeVisible();
  await authSuccessMessage.click();

  await page.context().storageState({ path: authFile });
});
