const fs = require('fs');
const path = require('path');

const jsonPath = path.join(__dirname, '../reports/HTML/execution-report.json');
const summaryPath = path.join(__dirname, '../reports/Summary/summary.md');

if (!fs.existsSync(jsonPath)) {
    console.error('Execution JSON report not found!');
    process.exit(0);
}

const report = JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
const stats = report.stats;

const summary = `
# Live GitHub Pages E2E Execution Summary

Execution Date: ${new Date(stats.end).toISOString()}

Total Test Cases: ${stats.tests}
Executed: ${stats.tests}
Passed: ${stats.passes}
Failed: ${stats.failures}
Skipped: ${stats.pending}

Pass Percentage: ${stats.passPercent.toFixed(2)}%
Execution Duration: ${stats.duration} ms

Artifacts Generated:
✓ Excel Reports
✓ HTML Reports
✓ Screenshots
✓ Logs
✓ JSON Results
`;

const summaryDir = path.dirname(summaryPath);
if (!fs.existsSync(summaryDir)) fs.mkdirSync(summaryDir, { recursive: true });
fs.writeFileSync(summaryPath, summary);
console.log('Summary markdown generated successfully.');
