const axios = require('axios');
const ExcelJS = require('exceljs');
const path = require('path');

// Test Configuration
const TARGET_URL = 'http://localhost:8080/api/health'; // Update this to your actual API endpoint
const VIRTUAL_USERS = 100;
const DURATION_SECONDS = 60; // 1 minute

// Metrics
let totalRequestsSent = 0;
let totalRequestsCompleted = 0;
let totalRequestsFailed = 0;
let responseTimes = []; // Store all response times for math calculation
let testStartTime = 0;
let isRunning = false;

// Sleep utility
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function virtualUserTask(userId) {
    while (isRunning) {
        const reqStart = Date.now();
        try {
            totalRequestsSent++;
            
            // Adjust axios settings to bypass keep-alive limits if needed, 
            // but standard config is fine for baseline
            await axios.get(TARGET_URL, { timeout: 10000 });
            
            const reqDuration = Date.now() - reqStart;
            responseTimes.push(reqDuration);
            totalRequestsCompleted++;
        } catch (error) {
            totalRequestsFailed++;
        }
        
        // Add a small delay between requests to simulate real user behavior 
        // and avoid immediate socket exhaustion (e.g., 50ms to 200ms)
        await sleep(Math.floor(Math.random() * 150) + 50);
    }
}

async function runLoadTest() {
    console.log(`Starting Load Test: ${VIRTUAL_USERS} users for ${DURATION_SECONDS} seconds.`);
    console.log(`Target URL: ${TARGET_URL}`);
    console.log(`Please wait...`);

    testStartTime = Date.now();
    isRunning = true;

    // Start all virtual users concurrently
    const userPromises = [];
    for (let i = 0; i < VIRTUAL_USERS; i++) {
        userPromises.push(virtualUserTask(i));
    }

    // Wait for the specified duration
    await sleep(DURATION_SECONDS * 1000);
    isRunning = false; // Signal all users to stop

    // Wait a brief moment to allow pending requests to finish or fail
    await sleep(2000); 

    const testDurationSec = (Date.now() - testStartTime) / 1000;
    
    // Calculate Metrics
    const rps = (totalRequestsCompleted / testDurationSec).toFixed(2);
    
    let minTime = 0;
    let maxTime = 0;
    let avgTime = 0;
    
    if (responseTimes.length > 0) {
        minTime = Math.min(...responseTimes);
        maxTime = Math.max(...responseTimes);
        const sum = responseTimes.reduce((a, b) => a + b, 0);
        avgTime = (sum / responseTimes.length).toFixed(2);
    }

    console.log("\n=== LOAD TEST RESULTS ===");
    console.log(`Total Requests Sent: ${totalRequestsSent}`);
    console.log(`Successful Requests: ${totalRequestsCompleted}`);
    console.log(`Failed Requests:     ${totalRequestsFailed}`);
    console.log(`Requests Per Second: ${rps} req/sec`);
    console.log(`Response Time:`);
    console.log(`  - Average: ${avgTime} ms`);
    console.log(`  - Min:     ${minTime} ms`);
    console.log(`  - Max:     ${maxTime} ms`);
    console.log("=========================\n");

    // Generate Excel Report
    await generateExcelReport({
        totalRequestsSent,
        totalRequestsCompleted,
        totalRequestsFailed,
        rps,
        avgTime,
        minTime,
        maxTime,
        duration: DURATION_SECONDS,
        users: VIRTUAL_USERS
    });
}

async function generateExcelReport(metrics) {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Load Test Report');

    // Headers
    worksheet.columns = [
        { header: 'Metric', key: 'metric', width: 30 },
        { header: 'Value', key: 'value', width: 25 }
    ];
    worksheet.getRow(1).font = { bold: true };

    // Data
    worksheet.addRows([
        { metric: 'Virtual Users', value: metrics.users },
        { metric: 'Duration (Seconds)', value: metrics.duration },
        { metric: 'Total Requests Sent', value: metrics.totalRequestsSent },
        { metric: 'Successful Requests', value: metrics.totalRequestsCompleted },
        { metric: 'Failed Requests', value: metrics.totalRequestsFailed },
        { metric: 'Requests Per Second (RPS)', value: `${metrics.rps} req/sec` },
        { metric: 'Average Response Time', value: `${metrics.avgTime} ms` },
        { metric: 'Min Response Time', value: `${metrics.minTime} ms` },
        { metric: 'Max Response Time', value: `${metrics.maxTime} ms` }
    ]);

    const reportPath = path.join(__dirname, 'Load_Test_Report.xlsx');
    await workbook.xlsx.writeFile(reportPath);
    console.log(`✅ Excel Report Generated: ${reportPath}`);
}

runLoadTest();
