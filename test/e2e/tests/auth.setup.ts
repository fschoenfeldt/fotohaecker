import { test as setup } from "@playwright/test";
import { authFileUser, authenticateUser, userFixture } from "./helpers";

setup("authenticate user", async ({ page }) => {
  if (!process.env["AUTH0_CLIENT_ID"]) {
    console.info(
      `Skipping Auth tests because environment variables are not set.`
    );
    setup.skip();
  } else {
    await authenticateUser(page, userFixture, authFileUser);
  }
});
