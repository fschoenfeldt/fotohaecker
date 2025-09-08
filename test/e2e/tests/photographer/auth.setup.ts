import { test as setup } from "@playwright/test";
import {
  auth0UserManagementEnabled,
  authFilePhotographer,
  authenticateUser,
  photographerFixture,
} from "../helpers";

setup("authenticate user", async ({ page }) => {
  if (!auth0UserManagementEnabled) {
    console.info(
      `Skipping Auth tests because environment variables are not set.`
    );
    setup.skip();
  } else {
    await authenticateUser(page, photographerFixture, authFilePhotographer);
  }
});
