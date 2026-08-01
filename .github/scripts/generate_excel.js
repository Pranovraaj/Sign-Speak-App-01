const fs = require('fs');
const ExcelJS = require('exceljs');

async function generateAppiumExcel(inputPath, outputPath) {
    const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Appium Test Results');

    sheet.columns = [
        { header: 'Test Suite', key: 'suite', width: 30 },
        { header: 'Test Case', key: 'title', width: 60 },
        { header: 'Status', key: 'state', width: 15 },
        { header: 'Duration (ms)', key: 'duration', width: 15 },
        { header: 'Error', key: 'error', width: 50 }
    ];

    data.results.forEach(suite => {
        suite.suites.forEach(subSuite => {
            subSuite.tests.forEach(test => {
                sheet.addRow({
                    suite: subSuite.title,
                    title: test.title,
                    state: test.state,
                    duration: test.duration,
                    error: test.err ? test.err.message : ''
                });
            });
        });
    });

    await workbook.xlsx.writeFile(outputPath);
    console.log(`Generated Appium Excel report at ${outputPath}`);
}

async function generateK6Excel(inputPath, outputPath) {
    const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
    const workbook = new ExcelJS.Workbook();
    const sheet = workbook.addWorksheet('Load Test Results');

    sheet.columns = [
        { header: 'Metric', key: 'metric', width: 40 },
        { header: 'Value', key: 'value', width: 40 }
    ];

    for (const [key, val] of Object.entries(data.metrics)) {
        let valueStr = '';
        if (val.values) {
            valueStr = Object.entries(val.values).map(([k, v]) => `${k}: ${v}`).join(', ');
        } else {
            valueStr = JSON.stringify(val);
        }
        sheet.addRow({ metric: key, value: valueStr });
    }

    await workbook.xlsx.writeFile(outputPath);
    console.log(`Generated K6 Excel report at ${outputPath}`);
}

async function generateTrivyExcel(inputPath, outputPath) {
    const data = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
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

    if (data.Results) {
        data.Results.forEach(result => {
            if (result.Vulnerabilities) {
                result.Vulnerabilities.forEach(vuln => {
                    sheet.addRow({
                        target: result.Target,
                        vulnId: vuln.VulnerabilityID,
                        severity: vuln.Severity,
                        title: vuln.Title,
                        installedVersion: vuln.InstalledVersion,
                        fixedVersion: vuln.FixedVersion || ''
                    });
                });
            }
        });
    }

    await workbook.xlsx.writeFile(outputPath);
    console.log(`Generated Trivy Excel report at ${outputPath}`);
}

const type = process.argv[2];
const inputPath = process.argv[3];
const outputPath = process.argv[4];

if (!type || !inputPath || !outputPath) {
    console.error('Usage: node generate_excel.js <type> <input_json_path> <output_xlsx_path>');
    process.exit(1);
}

if (type === 'appium') {
    generateAppiumExcel(inputPath, outputPath);
} else if (type === 'k6') {
    generateK6Excel(inputPath, outputPath);
} else if (type === 'trivy') {
    generateTrivyExcel(inputPath, outputPath);
} else {
    console.error('Unknown type: ' + type);
    process.exit(1);
}
