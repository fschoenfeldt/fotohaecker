import { test, expect } from "@playwright/test";
import { changeLanguage } from "../features/languageMenu";
import { uploadPhoto } from "./helpers";

test.describe.skip("Home page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
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

test("can upload photo", async ({ page }) => {
  await uploadPhoto(page);
});
