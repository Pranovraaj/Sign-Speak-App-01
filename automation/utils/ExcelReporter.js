const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

class ExcelReporter {
    constructor() {
        this.workbook = new ExcelJS.Workbook();
        this.resultsSheet = this.workbook.addWorksheet('Executed Test Cases');
        
        this.resultsSheet.columns = [
            { header: 'Test ID', key: 'id', width: 15 },
            { header: 'Module', key: 'module', width: 20 },
            { header: 'Test Name', key: 'name', width: 40 },
            { header: 'Status', key: 'status', width: 15 },
            { header: 'Duration (ms)', key: 'duration', width: 15 },
            { header: 'Error', key: 'error', width: 50 }
        ];

        this.results = [];
    }

    addResult(result) {
        this.results.push(result);
        this.resultsSheet.addRow(result);
    }

    async saveReport() {
        const reportDir = path.join(__dirname, '../reports/Excel');
        if (!fs.existsSync(reportDir)) {
            fs.mkdirSync(reportDir, { recursive: true });
        }
        await this.workbook.xlsx.writeFile(path.join(reportDir, 'Automation_Test_Report.xlsx'));
    }
}

module.exports = new ExcelReporter();
