import { test, expect } from '@playwright/test';

test('shows index page', async ({ page }) => {
  await page.goto("/fh");

  // expect page title to match
  await expect(page).toHaveTitle("Home · Fotohaecker");
})

