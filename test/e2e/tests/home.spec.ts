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

test("can not upload photo with title longer than 32 characters", async ({
  page,
}) => {
  await page.goto("/fh");

  const title = "very long title".repeat(10);

  const uploadForm = page.locator("form.upload_form");
  await uploadForm.locator("#photo_title").type(title);
  expect(await uploadForm.locator("#photo_title").inputValue()).toBe(
    title.slice(0, 32)
  );
});

test("can click on 'show more' button", async ({ page }) => {
  // TODO: this test is very slow because of the uploadPhoto function calls
  // upload 6 photos
  for (let i = 0; i < 6; i++) {
    await uploadPhoto(page);
  }

  await page.goto("/fh");

  // get current number of photos inside the list
  const photosCountBefore = await page.locator("ul#photos > li").count();

  await page.getByTestId("show_more_photos_button").click();

  // TODO: test a11y (focus after click)
  // --> https://github.com/fschoenfeldt/fotohaecker/issues/79

  await page.waitForSelector("ul#photos > li:nth-child(6)");
  const photosCountAfter = await page.locator("ul#photos > li").count();

  expect(photosCountAfter).toBeGreaterThan(photosCountBefore);
});
