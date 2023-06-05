import { test, expect } from '@playwright/test';

test.describe('Home page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/fh');
  });
  test('shows index page', async ({ page }) => {
  
    // expect page title to match
    await expect(page).toHaveTitle("Home · Fotohaecker");
  })
  
  test('can change language', async ({ page }) => {
    const langButton = await page.getByTestId("change-locale-button");
    await langButton.click();
    const langMenu = await page.getByTestId("change-locale-menu");
    const germanButton = await langMenu.getByText("german");
    await germanButton.click();
    await expect(page).toHaveURL(/.*de_DE*/);
    await expect(page).toHaveTitle("Startseite · Fotohaecker");
    await expect(page.locator("h1")).toHaveText("Lade Deine Fotos hoch, lizenzfrei.");
  })
});  

test.describe("Upload Photo", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/fh');
  });

  test('can upload photo', async ({ page }) => {
    const photo = {
      title: "Test Photo",
      file: './fixtures/photo_fixture.jpg'
      /* {
        name: 'photo_fixture.jpg',
        mimeType: 'image/jpeg',
        buffer: Buffer.from('fixtures/photo_fixture.jpg', 'utf-8'),
      } */
    };

    // console.log(photo.file.buffer)

    const uploadForm = page.locator("form.upload_form");
    await uploadForm.locator('#photo_title').type("Test Photo");
    // await uploadForm.locator('input[type=file]').click();
    await uploadForm.locator('input[type=file]').setInputFiles(photo.file);
    await uploadForm.locator('button[type=submit]').click();

    await page.waitForSelector('[phx-submit="submission_submit_tags"]');
    await page.waitForLoadState('networkidle');
    expect(page.locator('.alert--info')).toBeVisible();
    expect(page.locator('.alert--info')).toContainText("Photo uploaded successfully.");
    expect(uploadForm).toContainText(photo.title)

  });
})