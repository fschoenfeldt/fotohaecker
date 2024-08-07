import { test, expect } from "../fixtures/axe-test";
import {
  changeLanguage,
  deletePhoto,
  openDeletePhotoModal,
  uploadPhoto,
  selectFirstPhoto,
} from "./helpers";

test.describe("Photo Page: Static", () => {
  test.beforeEach(async ({ page }) => {
    await selectFirstPhoto(page);
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

  test("can download photo", async ({ page, context }) => {
    await uploadPhoto(page);
    const downloadPromise = page.waitForEvent("download");
    await page.locator("a", { hasText: "Download" }).click();

    const download = await downloadPromise;
    expect(download.suggestedFilename()).toContain("live_view_upload-");
    expect(download.suggestedFilename()).toContain(".jpg");
  });

  test("can go back to home page and preserve url params and scroll position", async ({
    page,
  }) => {
    await page.goBack();

    // click "show more button" to load more photos
    await page.getByTestId("show_more_photos_button").click();

    // save current get parameters
    const expectedParams = new URL(page.url()).searchParams;
    const expectedScrollY = await page.evaluate(() => window.scrollY);

    await selectFirstPhoto(page);
    await page.goBack();

    const actualParams = new URL(page.url()).searchParams;
    const actualScrollY = await page.evaluate(() => window.scrollY);

    expect(actualParams).toEqual(expectedParams);
    // be close to one pixel
    expect(actualScrollY - expectedScrollY).toBeLessThanOrEqual(1);
    await expect(page).toHaveURL(/.*\/fh/);
  });

  test("can change language", async ({ page }) => {
    changeLanguage(page, "german");
    await expect(page).toHaveURL(/.*de_DE*/);
    const homepageLink = await page
      .locator("header a", { hasText: "Fotohäcker" })
      .getAttribute("href");
    expect(homepageLink).toContain("/de_DE");
  });
});

test.describe("Photo Page: CRUD", () => {
  test.beforeEach(async ({ page, context }) => {
    const { photo } = await uploadPhoto(page);
    context.photo = photo;
  });

  test("can edit photo title", async ({ page, browserName, context }) => {
    await expect(page.getByTestId("title")).toContainText(context.photo.title);
    await expect(page.getByTestId("tags")).toContainText("no tags");

    await page.getByTestId("edit-button-title").click();

    await page.waitForTimeout(300);
    const titleInput = page.locator("#photo_title");
    await expect(titleInput).toBeFocused();
    await titleInput.fill("New Title");
    await page.waitForTimeout(300);

    await page
      .locator('form[phx-submit="edit_submit"] button[type="submit"]')
      .click();
    await expect(page.getByTestId("title")).toContainText("New Title");
    await expect(page.locator(".alert--info")).toContainText("photo updated");
  });

  test("can edit photo tags", async ({ page, browserName, context }) => {
    await expect(page.getByTestId("title")).toContainText(context.photo.title);
    await expect(page.getByTestId("tags")).toContainText("no tags");

    await page.getByTestId("edit-button-tags").click();

    await page.waitForTimeout(300);
    const tagsInput = page.locator("input#photo_tags");
    await expect(tagsInput).toBeFocused();
    await tagsInput.fill("fancy, new, tags");
    await page.waitForTimeout(300);

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

  test("should not have any automatically detectable accessibility issues while editing tags", async ({
    context,
    page,
    makeAxeBuilder,
  }) => {
    test.slow();

    await expect(page.getByTestId("title")).toContainText(context.photo.title);
    await expect(page.getByTestId("tags")).toContainText("no tags");

    await page.getByTestId("edit-button-tags").click();
    await page.locator("input#photo_tags").fill("fancy, accessible, tags");

    await page.waitForTimeout(300);

    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("should not have any automatically detectable accessibility issues while editing tags in dark mode", async ({
    context,
    page,
    makeAxeBuilder,
  }) => {
    test.slow();

    await page.emulateMedia({ colorScheme: "dark" });

    await expect(page.getByTestId("title")).toContainText(context.photo.title);
    await expect(page.getByTestId("tags")).toContainText("no tags");

    await page.getByTestId("edit-button-tags").click();
    await page.locator("input#photo_tags").fill("fancy, accessible, tags");

    await page.waitForTimeout(300);

    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("can delete photo", async ({ page, context }) => {
    await deletePhoto(page);
    await expect(page.locator(".alert--info")).toContainText("photo deleted");
  });
});

test.describe("Photo Page: Delete Modal", () => {
  test.beforeEach(async ({ page, context }) => {
    const { photo } = await uploadPhoto(page);
    context.photo = photo;
  });

  test("should not have any automatically detectable accessibility issues", async ({
    page,
    makeAxeBuilder,
  }) => {
    test.slow();
    await openDeletePhotoModal(page);
    // wait for animation finish
    // TODO: flaky
    await page.waitForTimeout(300);
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test("should not have any automatically detectable accessibility issues in dark mode", async ({
    page,
    makeAxeBuilder,
  }) => {
    test.slow();
    await page.emulateMedia({ colorScheme: "dark" });
    await openDeletePhotoModal(page);
    // wait for animation finish
    // TODO: flaky
    await page.waitForTimeout(300);
    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);
  });
});

test.describe("Photo Page: Permissions", () => {
  test.beforeEach(async ({ page, context }) => {
    page.goto("/fh/en_US/photos/-1");
    await page.waitForLoadState("networkidle");
  });

  test("Can't edit photo title of a photo not owned", async ({ page }) => {
    const nonexistentEditButton = await page.$("data-testid=edit-button-title");
    expect(nonexistentEditButton).toBeNull();
  });

  test("Can't edit photo tags of a photo not owned", async ({ page }) => {
    const nonexistentEditButton = await page.$("data-testid=edit-button-tags");
    expect(nonexistentEditButton).toBeNull();
  });
});
