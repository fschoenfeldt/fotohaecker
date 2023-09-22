import { test, expect } from "../fixtures/axe-test";
import { changeLanguage, uploadPhoto } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("Search", () => {
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
    await expect(page.getByTestId("result_list")).toContainText(photo.title);
  });

  test("can see submitted search results", async ({ page }) => {
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
    await expect(page.locator("#search")).toContainText(photo.title);
  });
});

test.describe("Search Page", () => {
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
    await searchInput.press("Enter");
    await expect(page.locator("#search")).toContainText(photo.title);

    const accessibilityScanResults = await makeAxeBuilder().analyze();
    expect(accessibilityScanResults.violations).toEqual([]);

    await page.emulateMedia({ colorScheme: "dark" });
    const accessibilityScanResultsDarkMode = await makeAxeBuilder().analyze();
    expect(accessibilityScanResultsDarkMode.violations).toEqual([]);
  });
});
