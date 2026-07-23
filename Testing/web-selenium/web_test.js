const { Builder, By, until } = require('selenium-webdriver');
const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

async function runSeleniumTests() {
    // 1. Initialize Excel Workbook
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Test Results');
    worksheet.columns = [
        { header: 'Test Case ID', key: 'id', width: 15 },
        { header: 'Test Name', key: 'name', width: 30 },
        { header: 'Status', key: 'status', width: 15 },
        { header: 'Duration (ms)', key: 'duration', width: 15 },
        { header: 'Error Message', key: 'error', width: 40 }
    ];

    // Ensure reports directory exists
    const reportsDir = path.join(__dirname, 'reports');
    if (!fs.existsSync(reportsDir)) {
        fs.mkdirSync(reportsDir, { recursive: true });
    }

    // 2. Setup Selenium WebDriver (Chrome)
    let driver;
    try {
        const chrome = require('selenium-webdriver/chrome');
        let options = new chrome.Options();
        // Run headlessly in GitHub Actions (or any CI)
        options.addArguments('--headless');
        options.addArguments('--no-sandbox');
        options.addArguments('--disable-dev-shm-usage');

        driver = await new Builder()
            .forBrowser('chrome')
            .setChromeOptions(options)
            .build();
        
        // 3. Define Test Cases
        await runTest('TC_01', 'Navigate to App', worksheet, async () => {
            await driver.get('http://localhost:8080/'); // Assuming flutter web is running or backend serves UI
            await driver.sleep(2000); // Wait for flutter to load
            
            // Example assertion: Check title
            const title = await driver.getTitle();
            if (!title) throw new Error("Page title is empty");
        });

        await runTest('TC_02', 'Verify Login Page Elements', worksheet, async () => {
            // Note: Replace these locators with the actual IDs or paths in your Flutter app
            // Flutter web uses semantic web elements if enabled, otherwise canvas
            console.log("Add specific Selenium locators for your UI elements here.");
        });

    } catch (e) {
        console.error("Global Test Execution Error: ", e);
    } finally {
        if (driver) {
            await driver.quit();
        }
        
        // 4. Save Excel Report
        const reportPath = path.join(reportsDir, 'web_test_report.xlsx');
        await workbook.xlsx.writeFile(reportPath);
        console.log(`Selenium Web Test Report generated at: ${reportPath}`);
    }
}

// Helper to run individual tests and catch results for Excel
async function runTest(id, name, worksheet, testFn) {
    const startTime = Date.now();
    let status = 'PASS';
    let errorMsg = '';
    
    console.log(`Running Test: ${id} - ${name}`);
    
    try {
        await testFn();
    } catch (err) {
        status = 'FAIL';
        errorMsg = err.message;
        console.error(`[FAIL] ${name}: ${err.message}`);
    }
    
    const duration = Date.now() - startTime;
    
    worksheet.addRow({
        id: id,
        name: name,
        status: status,
        duration: duration,
        error: errorMsg
    });
}

runSeleniumTests();
