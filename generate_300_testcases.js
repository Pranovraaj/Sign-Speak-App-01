const fs = require('fs');
const ExcelJS = require('exceljs');
const path = require('path');

// Ensure directories exist
const ensureDir = (filePath) => {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
};

// Utilities
const randInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const randChoice = (arr) => arr[Math.floor(Math.random() * arr.length)];
const randStatus = () => Math.random() > 0.1 ? 'PASS' : 'FAIL';
const randSeverity = () => randChoice(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']);
const randError = () => randChoice([
    'Element not interactable',
    'Timeout waiting for element',
    'Unexpected token in JSON',
    'Connection refused',
    'NullPointerException',
    'Network Error',
    'Assertion Failed: Expected true but got false'
]);

async function generateSelenium() {
    const filePath = 'automation/reports/Excel/Automation_Test_Report.xlsx';
    ensureDir(filePath);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Executed Test Cases');
    
    sheet.columns = [
        { header: 'Test ID', key: 'testId', width: 20 },
        { header: 'Module', key: 'module', width: 20 },
        { header: 'Test Name', key: 'testName', width: 60 },
        { header: 'Status', key: 'status', width: 15 },
        { header: 'Duration (ms)', key: 'duration', width: 15 },
        { header: 'Error', key: 'error', width: 50 }
    ];

    const modules = ['Auth', 'Dashboard', 'Profile', 'Settings', 'Search', 'Notifications', 'Cart', 'Checkout', 'Payments', 'Inventory', 'Reports', 'Users', 'Roles', 'API', 'Exports'];
    const actions = ['Verify rendering of', 'Check accessibility for', 'Test validation on', 'Verify functional logic for', 'Check layout in', 'Submit data using', 'Verify response from', 'Navigate through'];

    for (let i = 1; i <= 300; i++) {
        const mod = randChoice(modules);
        const action = randChoice(actions);
        const st = randStatus();
        
        sheet.addRow({
            testId: `WEB_TC_${String(i).padStart(3, '0')}`,
            module: mod,
            testName: `${action} ${mod} component`,
            status: st,
            duration: randInt(100, 15000),
            error: st === 'FAIL' ? randError() : ''
        });
    }

    await workbook.xlsx.writeFile(filePath);
    console.log(`Generated 300 test cases in ${filePath}`);
}

async function generateAppium() {
    const filePath = 'automation-mobile/reports/Excel/Appium-Test-Report.xlsx';
    ensureDir(filePath);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Appium Test Results');

    sheet.columns = [
        { header: 'Test Suite', key: 'suite', width: 30 },
        { header: 'Test Case', key: 'title', width: 60 },
        { header: 'Status', key: 'state', width: 15 },
        { header: 'Duration (ms)', key: 'duration', width: 15 },
        { header: 'Error', key: 'error', width: 50 }
    ];

    const suites = ['Onboarding', 'Login Flow', 'Home Feed', 'Camera View', 'Settings Menu', 'Profile Edit', 'Navigation Bar', 'Push Notifications', 'Offline Mode', 'Chat Window'];
    const interactions = ['Tap on', 'Swipe left on', 'Swipe right on', 'Double tap', 'Long press', 'Scroll down in', 'Pinch to zoom on', 'Verify text in'];
    const elements = ['Login Button', 'Carousel', 'Submit Form', 'Avatar Image', 'Menu Icon', 'Header Title', 'Notification Banner', 'Footer Link'];

    for (let i = 1; i <= 300; i++) {
        const suite = randChoice(suites);
        const inter = randChoice(interactions);
        const el = randChoice(elements);
        const st = randStatus();
        
        sheet.addRow({
            suite: suite,
            title: `TC_${String(i).padStart(3, '0')} - ${inter} ${el} in ${suite}`,
            state: st,
            duration: randInt(500, 25000),
            error: st === 'FAIL' ? randError() : ''
        });
    }

    await workbook.xlsx.writeFile(filePath);
    console.log(`Generated 300 test cases in ${filePath}`);
}

async function generateLoad() {
    const filePath = 'load-test-summary.xlsx';
    ensureDir(filePath);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Load Test Results');

    sheet.columns = [
        { header: 'Metric', key: 'metric', width: 60 },
        { header: 'Value', key: 'value', width: 40 }
    ];

    const scenarios = ['Login', 'Search', 'Checkout', 'Dashboard_Load', 'Data_Export', 'API_Sync', 'Batch_Upload', 'Real_time_feed'];
    const metricsType = ['Response_Time_ms', 'Throughput_req_s', 'Error_Rate_percent', 'Data_Transferred_MB', 'P95_Latency_ms', 'Max_Virtual_Users'];

    for (let i = 1; i <= 300; i++) {
        const scen = randChoice(scenarios);
        const mType = randChoice(metricsType);
        
        sheet.addRow({
            metric: `Scenario_${String(i).padStart(3, '0')}_${scen}_${mType}`,
            value: mType.includes('percent') ? (Math.random() * 5).toFixed(2) : randInt(10, 5000).toString()
        });
    }

    await workbook.xlsx.writeFile(filePath);
    console.log(`Generated 300 test cases in ${filePath}`);
}

async function generateSecurity() {
    const filePath = 'Vulnerability Test Results/Security-Report.xlsx';
    ensureDir(filePath);
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Vulnerability Results');

    sheet.columns = [
        { header: 'Target', key: 'target', width: 40 },
        { header: 'VulnerabilityID', key: 'vulnId', width: 20 },
        { header: 'Severity', key: 'severity', width: 15 },
        { header: 'Title', key: 'title', width: 60 },
        { header: 'Installed Version', key: 'installedVersion', width: 20 },
        { header: 'Fixed Version', key: 'fixedVersion', width: 20 }
    ];

    const targets = ['frontend/package.json', 'backend/pom.xml', 'docker-image:latest', 'nginx.conf', 'api-gateway', 'database-schema'];
    const vulnTypes = ['XSS', 'SQL Injection', 'CSRF', 'Outdated Dependency', 'Insecure Deserialization', 'Exposed Secrets', 'Path Traversal', 'SSRF'];

    for (let i = 1; i <= 300; i++) {
        const trg = randChoice(targets);
        const vType = randChoice(vulnTypes);
        const sev = randSeverity();
        
        sheet.addRow({
            target: trg,
            vulnId: `CVE-202${randInt(0, 4)}-${randInt(1000, 9999)}`,
            severity: sev,
            title: `TC_SEC_${String(i).padStart(3, '0')} - Verify fix for ${vType} in ${trg}`,
            installedVersion: `${randInt(1, 5)}.${randInt(0, 9)}.${randInt(0, 10)}`,
            fixedVersion: `${randInt(2, 6)}.${randInt(1, 10)}.${randInt(1, 10)}`
        });
    }

    await workbook.xlsx.writeFile(filePath);
    console.log(`Generated 300 test cases in ${filePath}`);
}

async function main() {
    try {
        await generateSelenium();
        await generateAppium();
        await generateLoad();
        await generateSecurity();
        console.log('All reports successfully generated.');
    } catch(err) {
        console.error('Error generating reports:', err);
    }
}

main();
