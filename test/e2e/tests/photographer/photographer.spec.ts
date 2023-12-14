import { test, expect } from "../../fixtures/axe-test";
import {
  auth0UserManagementEnabled,
  conditionalTest,
  photographerFixture,
  stripePaymentEnabled,
} from "../helpers";

test.describe("Photographer: Settings page", () => {
  test.beforeEach(async ({ page }) => {
    if (stripePaymentEnabled && auth0UserManagementEnabled) {
      await page.goto("/fh");
      await page.locator("a", { hasText: "your account" }).click();
    } else {
      console.info(
        `Skipping Payment tests because environment variables are not set.`
      );
      test.skip();
    }
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

  test("can visit account settings page", async ({ page }) => {
    const { email, password } = photographerFixture;

    await expect(page.locator("h1")).toHaveText("Your Account");
    // can't check for mail because Auth0UserManagement isn't enabled.
    // await expect(page.locator("div#user")).toContainText(email);
  });

  test("donation dashboard is visible", async ({ page }) => {
    const donationDashboardLink = page.locator("a", {
      hasText: "donation dashboard",
    });
    await expect(donationDashboardLink).toBeVisible();
  });

  test("donation banner works", async ({ page }) => {
    await page.goto(`/fh/en_us/user/${photographerFixture.id}`);
    const donationBanner = page.getByTestId("donationBanner");

    await expect(donationBanner).toBeVisible();
    const donationButton = donationBanner.locator("button");
    await page.waitForSelector("div[data-phx-main].phx-connected");
    await donationButton.click();
    await page.waitForURL(/stripe\.com/);

    expect(page.url()).toContain("stripe.com");
  });

  test("can logout", async ({ page }) => {
    await page.locator("button", { hasText: "logout" }).click();
    await expect(page.locator(".alert--info")).toContainText("logged out");
    await page.locator(".alert--info").click();
    await expect(page.locator("a", { hasText: "login" })).toBeVisible();
  });
});
