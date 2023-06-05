import { test, expect } from '@playwright/test';
import { changeLanguage } from '../features/languageMenu';

test.describe('Home page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/fh');
  });

  test('shows index page', async ({ page }) => {
    await expect(page).toHaveTitle("Home · Fotohaecker");
  })
  
  test('can change language', async ({ page }) => {
    await changeLanguage(page, "german");
    await expect(page).toHaveURL(/.*de_DE*/);
    await expect(page).toHaveTitle("Startseite · Fotohaecker");
    await expect(page.locator("h1")).toHaveText("Lade Deine Fotos hoch, lizenzfrei.");
  })

  test('can navigate to a photo', async ({ page }) => {
    const photo = page.locator('ul#photos > li:first-child');
    await photo.click();
    await expect(page).toHaveURL(/.*\/photos\/\d+/);
  });
});  

test.describe("Upload Photo", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/fh');
  });

  test('can upload photo', async ({ page }) => {
    const photo = {
      title: "Test Photo",
      file: './fixtures/photo_fixture.jpg'
    };


    const uploadForm = page.locator("form.upload_form");
    await uploadForm.locator('#photo_title').type("Test Photo");
    await uploadForm.locator('input[type=file]').setInputFiles(photo.file);
    await uploadForm.locator('button[type=submit]').click();

    await page.waitForSelector('[phx-submit="submission_submit_tags"]');
    await page.waitForLoadState('networkidle');
    expect(page.locator('.alert--info')).toBeVisible();
    expect(page.locator('.alert--info')).toContainText("Photo uploaded successfully.");
    expect(uploadForm).toContainText(photo.title)
  });
})
