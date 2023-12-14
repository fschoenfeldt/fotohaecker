import { Page, expect } from "@playwright/test";

/**
 * Uploads a photo to the server, redirects to the photo page
 * @param page {Page}
 */
export const uploadPhoto = async (page: Page, photo: any = {}) => {
  await page.goto("/fh");

  photo = Object.assign(
    {
      title: `Test Photo ${Math.random().toString(36)}`,
      file: "./fixtures/photo_fixture.jpg",
      tags: [""],
    },
    photo
  );

  const uploadForm = page.locator("form.upload_form");
  await uploadForm.locator("#photo_title").type(photo.title);
  await uploadForm.locator("input[type=file]").setInputFiles(photo.file);
  await uploadForm.locator("button[type=submit]").click();

  await page.waitForSelector('[phx-submit="submission_submit_tags"]');
  // await page.waitForLoadState("networkidle");
  await expect(page.locator(".alert--info")).toBeVisible();
  await expect(page.locator(".alert--info")).toContainText(
    "Photo uploaded successfully."
  );
  await expect(uploadForm).toContainText(photo.title);
  await page.fill("#photo_tags", photo.tags.join(", "));
  await page.locator("button[type=submit]", { hasText: "submit" }).click();
  return { photo };
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

export const userFixture = {
  id: process.env.E2E_USER_ID || "",
  email: process.env.E2E_USER_EMAIL || "",
  password: process.env.E2E_USER_PASSWORD || "",
};

export const authFileUser = "playwright/.auth/authUser.json";

export const photographerFixture = {
  id: process.env.E2E_PHOTOGRAPHER_ID || "",
  email: process.env.E2E_PHOTOGRAPHER_EMAIL || "",
  password: process.env.E2E_PHOTOGRAPHER_PASSWORD || "",
};

export const authFilePhotographer = "playwright/.auth/authPhotographer.json";

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
