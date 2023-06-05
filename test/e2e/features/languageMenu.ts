import { Page } from "@playwright/test";

export const changeLanguage = async (page: Page, targetLanguage: string | RegExp = "german") => {
    const langButton = page.getByTestId("change-locale-button");
    await langButton.click();
    const langMenu = page.getByTestId("change-locale-menu");
    const languageButton = langMenu.getByText(targetLanguage);
    await languageButton.click();
};