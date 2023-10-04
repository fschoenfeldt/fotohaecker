import { test as setup, expect } from "@playwright/test";
import { authFilePhotographer, photographerFixture } from "../helpers";

setup("authenticate user", async ({ page }) => {
  const { email, password } = photographerFixture;
  await page.goto("/fh");
  await page.locator("a", { hasText: "login" }).click();
  await page.locator("#username").fill(email);
  await page.locator("#password").fill(password);
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

  await page.context().storageState({ path: authFilePhotographer });
});
