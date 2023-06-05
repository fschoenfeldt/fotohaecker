import { test, expect } from '@playwright/test';
import { changeLanguage } from '../features/languageMenu';

test.describe('Photo page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/fh');
    const photo = page.locator('ul#photos > li:first-child');
    await photo.click();
    await expect(page).toHaveURL(/.*\/photos\/\d+/);
  });
  
  test('can edit photo title', async ({ page }) => {
    page.getByTestId('edit-button-title').click();
    page.locator('#photo_title').fill('New Title');
    await page.locator('form[phx-submit="edit_submit"] button[type="submit"]').click();
    await expect(page.locator('.alert--info')).toContainText("photo updated");
  });

  test('can edit photo tags', async ({ page }) => {
    page.getByTestId('edit-button-tags').click();
    page.locator('#photo_tags').fill('fancy, new, tags');
    await page.locator('form[phx-submit="edit_submit"] button[type="submit"]').click();
    await expect(page.locator('.alert--info')).toContainText("photo updated");
  });

  test('can download photo', async ({ page, context }) => {
    const pagePromise = context.waitForEvent('page');
    await page.locator('a', { hasText: 'Download' }).click();
    const newPage = await pagePromise;
    await newPage.waitForLoadState();
    await expect(newPage).toHaveTitle(/.jpg/)
  });

  test('can go back to home page', async ({ page }) => {
    await page.getByTestId('back-button').click();
    await expect(page).toHaveURL(/.*\/fh/);
  });

  test('can change language', async ({ page }) => {
    changeLanguage(page, "german");
    await expect(page).toHaveURL(/.*de_DE*/);
  });
});  
