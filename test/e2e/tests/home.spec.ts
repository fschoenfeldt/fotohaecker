import { test, expect } from "../fixtures/axe-test";
import { changeLanguage, uploadPhoto } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("Home page", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
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
