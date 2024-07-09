import { test, expect } from "../fixtures/axe-test";
import { recipeManagementEnabled, userFixture } from "./helpers";

test.describe("User Settings page", () => {
  test.beforeEach(async ({ page }) => {
    if (recipeManagementEnabled) {
      // TODO
      test.fail();
    } else {
      console.info(
        `Skipping Recipe tests because environment variables are not set.`
      );
      test.skip();
    }
  });
});
