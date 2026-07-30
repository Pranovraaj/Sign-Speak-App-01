const { expect } = require('chai');
const fs = require('fs');
const path = require('path');
const DriverFactory = require('../config/driver');
const LoginPage = require('../pages/LoginPage');
const excelReporter = require('../utils/ExcelReporter');

describe('Authentication Module', function() {
    let driver;
    let loginPage;

    before(async function() {
        driver = await DriverFactory.getDriver();
        loginPage = new LoginPage(driver);
    });

    after(async function() {
        await excelReporter.saveReport();
        if (driver) {
            await driver.quit();
        }
    });

    afterEach(async function() {
        const status = this.currentTest.state;
        const duration = this.currentTest.duration;
        const error = this.currentTest.err ? this.currentTest.err.message : '';
        
        excelReporter.addResult({
            id: `TC_AUTH_${Math.floor(Math.random() * 1000)}`,
            module: 'Authentication',
            name: this.currentTest.title,
            status: status === 'passed' ? 'PASS' : 'FAIL',
            duration: duration,
            error: error
        });

        if (status === 'failed') {
            const screenshot = await driver.takeScreenshot();
            const reportDir = path.join(__dirname, '../screenshots');
            if (!fs.existsSync(reportDir)) fs.mkdirSync(reportDir, { recursive: true });
            fs.writeFileSync(path.join(reportDir, `${this.currentTest.title.replace(/\s+/g, '_')}.png`), screenshot, 'base64');
        }
    });

    it('should show error for invalid credentials', async function() {
        await loginPage.open();
        await loginPage.login('invalid@example.com', 'wrongpassword');
        const errorMessage = await loginPage.getErrorMessage();
        expect(errorMessage).to.exist;
    });

    it('should successfully login with valid credentials', async function() {
        await loginPage.open();
        // Placeholder for valid login credentials test
        await loginPage.login('pranovraaj@gmail.com', 'Pranov@30');
        await loginPage.waitForUrlContains('/dashboard');
        const currentUrl = await driver.getCurrentUrl();
        expect(currentUrl).to.include('/dashboard');
    });
});
