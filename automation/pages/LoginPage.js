const BasePage = require('./BasePage');
const { By } = require('selenium-webdriver');

class LoginPage extends BasePage {
    constructor(driver) {
        super(driver);
        this.emailInput = By.css('input[type="email"], input[name="email"], input[placeholder*="Email"]');
        this.passwordInput = By.css('input[type="password"]');
        this.loginButton = By.css('button[type="submit"], button:contains("Login"), button:contains("Sign In")');
        this.errorMessage = By.css('.error-message, .alert-danger, [role="alert"]');
    }

    async open() {
        await this.navigate('/login');
    }

    async login(email, password) {
        await this.typeText(this.emailInput, email);
        await this.typeText(this.passwordInput, password);
        await this.click(this.loginButton);
    }

    async getErrorMessage() {
        return await this.getText(this.errorMessage);
    }
}

module.exports = LoginPage;
