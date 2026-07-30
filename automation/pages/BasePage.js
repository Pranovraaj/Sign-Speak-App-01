const { By, until } = require('selenium-webdriver');

class BasePage {
    constructor(driver) {
        this.driver = driver;
        this.baseUrl = process.env.BASE_URL || 'https://pranovraaj.github.io/Sign-Speak-App-01';
    }

    async navigate(path = '') {
        await this.driver.get(`${this.baseUrl}${path}`);
    }

    async findElement(locator) {
        await this.driver.wait(until.elementLocated(locator), 15000);
        return this.driver.findElement(locator);
    }

    async click(locator) {
        const element = await this.findElement(locator);
        await this.driver.wait(until.elementIsVisible(element), 10000);
        await this.driver.wait(until.elementIsEnabled(element), 10000);
        await element.click();
    }

    async typeText(locator, text) {
        const element = await this.findElement(locator);
        await this.driver.wait(until.elementIsVisible(element), 10000);
        await element.clear();
        await element.sendKeys(text);
    }

    async getText(locator) {
        const element = await this.findElement(locator);
        await this.driver.wait(until.elementIsVisible(element), 10000);
        return element.getText();
    }

    async waitForUrlContains(text) {
        await this.driver.wait(until.urlContains(text), 15000);
    }
}

module.exports = BasePage;
