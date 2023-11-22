import { test, expect } from "../fixtures/axe-test";
import { changeLanguage, uploadPhoto } from "./helpers";
import AxeBuilder from "@axe-core/playwright";

test.describe("Search", () => {
  test("photo: can see search suggestions below search input", async ({
    page,
  }) => {
    const photo = {
      title: "Test Photo Search",
      tags: ["test", "search"],
    };
    await page.goto("/fh");
    await uploadPhoto(page, photo);
    await page.goto("/fh");

    const searchInput = page.locator("input#search_query");
    await searchInput.type("search");
    await expect(page.getByTestId("result_list--photo")).toContainText(
      photo.title
    );
  });

  test("photo: can submit search and see result", async ({ page }) => {
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

  // TODO
  test("user: can see search suggestions below search input", async ({
    page,
  }) => {
    expect(false).toBe(true);
  });

  test("user: can submit search and see result", async ({ page }) => {
    expect(false).toBe(true);
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
