import { Page, expect } from "@playwright/test";
import path from "path";

/**
 * Uploads a photo to the server, redirects to the photo page
 * @param page {Page}
 */
export const uploadPhoto = async (page: Page, photo: any = {}) => {
  await page.goto("/fh");

  photo = Object.assign(
    {
      title: `Test Photo ${Math.random().toString(36)}`,
      file: applyPathMagic("fixtures/photo_fixture.jpg", "tests/"),
      tags: [""],
    },
    photo
  );

  const uploadForm = page.locator("form.upload_form");
  await uploadForm.locator("#photo_title").type(photo.title);
  await uploadForm.locator("input[type=file]").setInputFiles(photo.file);
  await uploadForm.locator("button[type=submit]").click();

  await page.waitForSelector('[phx-submit="submission_submit_tags"]');
  await expect(page.locator(".alert--info")).toBeVisible();
  await expect(page.locator(".alert--info")).toContainText(
    "Photo uploaded successfully."
  );
  await expect(uploadForm).toContainText(photo.title);
  await page.fill("#photo_tags", photo.tags.join(", "));
  await page.locator("button[type=submit]", { hasText: "submit" }).click();
  return { photo };
};

export const openDeletePhotoModal = async (page: Page) => {
  await page.getByText("Delete").click();
  const modal = page.locator("#modal");
  return modal;
};

export const deletePhoto = async (page: Page) => {
  const modal = await openDeletePhotoModal(page);
  await modal.getByTestId("confirm-delete-button").click();
};

/**
 * Changes the language of the page
 * @param page {Page}
 * @param targetLanguage {string | RegExp}
 */
export const changeLanguage = async (
  page: Page,
  targetLanguage: string | RegExp = "german"
) => {
  const langButton = page.getByTestId("change-locale-button");
  await langButton.click();
  const langMenu = page.getByTestId("change-locale-menu");
  const languageButton = langMenu.getByText(targetLanguage);
  await languageButton.click();
};

/**
 * Joins the given path with the directory name.
 * @param {string} join - The path to join with the directory name.
 * @returns {string} - The joined path.
 */
const joinPath = (join: string): string => path.join(__dirname, join);

/**
 * Applies path magic by joining the given path and replacing the strip string.
 * @param {string} filePath - The path to join and modify.
 * @param {string} strip - The string to be replaced in the joined path.
 * @returns {string} - The modified path.
 */
const applyPathMagic = (filePath: string, strip: string): string =>
  joinPath(filePath).replace(strip, "");

export const userFixture = {
  id: process.env.E2E_USER_ID || "",
  email: process.env.E2E_USER_EMAIL || "",
  password: process.env.E2E_USER_PASSWORD || "",
};

export const authFileUser = applyPathMagic(
  "playwright/.auth/authUser.json",
  "tests/"
);

export const photographerFixture = {
  id: process.env.E2E_PHOTOGRAPHER_ID || "",
  email: process.env.E2E_PHOTOGRAPHER_EMAIL || "",
  password: process.env.E2E_PHOTOGRAPHER_PASSWORD || "",
};

export const authFilePhotographer = applyPathMagic(
  "playwright/.auth/authPhotographer.json",
  "tests/"
);

export const recipeManagementEnabled = !!process.env.RECIPE_IMPLEMENTATION;

export const auth0UserManagementEnabled =
  process.env.AUTH0_CLIENT_ID &&
  process.env.AUTH0_CLIENT_SECRET &&
  process.env.AUTH0_DOMAIN &&
  process.env.AUTH0_MANAGEMENT_CLIENT_ID &&
  process.env.AUTH0_MANAGEMENT_CLIENT_SECRET;

export const stripePaymentEnabled =
  process.env.STRIPE_SECRET &&
  process.env.STRIPE_CONNECT_CLIENT_ID &&
  process.env.STRIPE_PRICE_ID;
