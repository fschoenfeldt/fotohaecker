import { test, expect } from "@playwright/test";
import { changeLanguage, uploadPhoto } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("Home page", () => {
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

  test("shows index page", async ({ page }) => {
    await expect(page).toHaveTitle("Home · Fotohaecker");
  });

  test("can change language", async ({ page }) => {
    await changeLanguage(page, "german");
    await expect(page).toHaveURL(/.*de_DE*/);
    await expect(page).toHaveTitle("Startseite · Fotohaecker");
    await expect(page.locator("h1")).toHaveText(
      "Lade Deine Fotos hoch, lizenzfrei."
    );
  });

  test("can navigate to a photo", async ({ page }) => {
    const photo = page.locator("ul#photos > li:first-child");
    await photo.click();
    await expect(page).toHaveURL(/.*\/photos\/\d+/);
  });
});

test("can use search", async ({ page }) => {
  await page.goto("/fh");

  const searchInput = page.locator("form#search_form input[type='search']");
  await searchInput.fill("test");
  await expect(false).toBeTruthy();
});

test("can upload photo", async ({ page }) => {
  await uploadPhoto(page);
});
