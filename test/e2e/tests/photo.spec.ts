import { test, expect } from "@playwright/test";
import { changeLanguage, uploadPhoto } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

// TODO: remove serial
test.describe.serial("Photo Page: Static", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
    const photo = page.locator("ul#photos > li:first-child");
    await photo.click();
    await expect(page).toHaveURL(/.*\/photos\/\d+/);
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
  }) => {
    test.slow();
    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("can download photo", async ({ page, context }) => {
    const pagePromise = context.waitForEvent("page");
    await page.locator("a", { hasText: "Download" }).click();
    const newPage = await pagePromise;
    await newPage.waitForLoadState();
    await expect(newPage).toHaveTitle(/.jpg/);
  });

  test("can go back to home page", async ({ page }) => {
    await page.getByTestId("back-button").click();
    await expect(page).toHaveURL(/.*\/fh/);
  });

  test("can change language", async ({ page }) => {
    changeLanguage(page, "german");
    await expect(page).toHaveURL(/.*de_DE*/);
  });
});

test.describe("Photo Page: CRUD", () => {
  test.beforeEach(async ({ page }) => {
    await uploadPhoto(page);
  });

  test("can edit photo title", async ({ page, browserName }) => {
    await page.getByTestId("edit-button-title").click();
    if (browserName === "webkit") {
      await page.waitForTimeout(300);
    }
    await page.locator("#photo_title").fill("New Title");
    if (browserName === "webkit") {
      await page.waitForTimeout(300);
    }
    await page
      .locator('form[phx-submit="edit_submit"] button[type="submit"]')
      .click();
    await expect(page.getByTestId("title")).toContainText("New Title");
    await expect(page.locator(".alert--info")).toContainText("photo updated");
  });

  test("can edit photo tags", async ({ page, browserName }) => {
    await page.getByTestId("edit-button-tags").click();
    if (browserName === "webkit") {
      await page.waitForTimeout(300);
    }
    await page.locator("#photo_tags").fill("fancy, new, tags");
    if (browserName === "webkit") {
      await page.waitForTimeout(300);
    }
    await page
      .locator('form[phx-submit="edit_submit"] button[type="submit"]')
      .click();
    await expect(page.getByTestId("tags").locator("li")).toContainText([
      "fancy",
      "new",
      "tags",
    ]);
    await expect(page.locator(".alert--info")).toContainText("photo updated");
  });
});
