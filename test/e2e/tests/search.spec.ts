import { test, expect } from "../fixtures/axe-test";
import {
  auth0UserManagementEnabled,
  changeLanguage,
  uploadPhoto,
} from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("Search Input and Suggestions: Users", () => {
  test.beforeEach(async ({ page }) => {
    if (!auth0UserManagementEnabled) {
      console.info(
        `Skipping Auth tests because environment variables are not set.`
      );
      test.skip();
    }
  });

  test("user: can see search suggestions below search input", async ({
    page,
  }) => {
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("test");
    await expect(page.getByTestId("result_preview_list--user")).toContainText(
      "test"
    );
  });

  test("user: can submit search and see result", async ({ page }) => {
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("test");
    await searchInput.press("Enter");
    await expect(page.getByTestId("result_list--user")).toContainText("test");
  });
});
test.describe("Search Input and Suggestions: Photos", () => {
  test("can see search suggestions below search input", async ({ page }) => {
    const photo = {
      title: "Test Photo Search",
      tags: ["test", "search"],
    };
    await page.goto("/fh");
    await uploadPhoto(page, photo);
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("search");
    await expect(page.getByTestId("result_preview_list--photo")).toContainText(
      photo.title
    );
  });

  test("can submit search and see result", async ({ page }) => {
    const photo = {
      title: "Test Photo Search Two",
      tags: ["test2", "search2"],
    };
    await page.goto("/fh");
    await uploadPhoto(page, photo);
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("search2");
    await searchInput.press("Enter");
    await expect(page.getByTestId("result_list--photo")).toContainText(
      photo.title
    );
  });
});

test.describe("Live Search and Results Page: Accessibility", () => {
  test("should not have any automatically detectable accessibility issues", async ({
    page,
    makeAxeBuilder,
  }) => {
    test.slow();
    const photo = {
      title: "Test Photo Search Three",
      tags: ["test2", "search3"],
    };
    await page.goto("/fh");
    await uploadPhoto(page, photo);
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("search3");

    // no violations in search result preview
    let accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);

    await page.emulateMedia({ colorScheme: "dark" });
    let accessibilityScanResultsDarkMode = await makeAxeBuilder().analyze();
    expect(accessibilityScanResultsDarkMode.violations).toEqual([]);
    await page.emulateMedia({ colorScheme: "light" });

    await searchInput.press("Enter");
    await expect(page.locator("#search")).toContainText(photo.title);

    // no violations in search result
    accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);

    await page.emulateMedia({ colorScheme: "dark" });
    accessibilityScanResultsDarkMode = await makeAxeBuilder().analyze();
    expect(accessibilityScanResultsDarkMode.violations).toEqual([]);
  });
});
