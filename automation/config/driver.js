const { Builder } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

class DriverFactory {
    static async getDriver() {
        let options = new chrome.Options();
        options.addArguments('--headless=new');
        options.addArguments('--disable-gpu');
        options.addArguments('--window-size=1920,1080');
        options.addArguments('--no-sandbox');
        options.addArguments('--disable-dev-shm-usage');

        let driver = await new Builder()
            .forBrowser('chrome')
            .setChromeOptions(options)
            .build();
        
        // Setup implicit wait
        await driver.manage().setTimeouts({ implicit: 10000 });
        return driver;
    }
}

module.exports = DriverFactory;
