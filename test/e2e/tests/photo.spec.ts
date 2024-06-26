import { test, expect } from "../fixtures/axe-test";
import {
  changeLanguage,
  deletePhoto,
  openDeletePhotoModal,
  uploadPhoto,
} from "./helpers";

test.describe("Photo Page: Static", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/fh");
    const photo = page.locator("ul#photos > li:first-child");
    await photo.click();
    await expect(page).toHaveURL(/.*\/photos\/\d+/);
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
