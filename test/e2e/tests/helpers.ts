import { Page, expect } from "@playwright/test";

/**
 * Uploads a photo to the server, redirects to the photo page
 * @param page {Page}
 */
export const uploadPhoto = async (page: Page) => {
  await page.goto("/fh");
  const photo = {
    title: "Test Photo",
    file: "./fixtures/photo_fixture.jpg",
  };

  const uploadForm = page.locator("form.upload_form");
  await uploadForm.locator("#photo_title").type("Test Photo");
  await uploadForm.locator("input[type=file]").setInputFiles(photo.file);
  await uploadForm.locator("button[type=submit]").click();

  await page.waitForSelector('[phx-submit="submission_submit_tags"]');
  // await page.waitForLoadState("networkidle");
  await expect(page.locator(".alert--info")).toBeVisible();
  await expect(page.locator(".alert--info")).toContainText(
    "Photo uploaded successfully."
  );
  await expect(uploadForm).toContainText(photo.title);
  await page.locator("button[type=submit]", { hasText: "submit" }).click();
};
