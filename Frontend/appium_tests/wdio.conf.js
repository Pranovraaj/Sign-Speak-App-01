exports.config = {
    runner: 'local',
    port: 4723,
    specs: [
        './test.e2e.js'
    ],
    exclude: [],
    maxInstances: 1,
    capabilities: [{
        platformName: 'Android',
        'appium:deviceName': 'Android Emulator',
        'appium:automationName': 'UiAutomator2',
        // Update this path to the correct emulator device name if necessary
        // 'appium:app': 'a:/project/Backend project/PDD/SignLanguageApp/SignSpeak.apk', // Absolute path recommended by appium
        // For wdio, resolving path from current dir
        'appium:app': '../SignSpeak.apk',
        'appium:autoGrantPermissions': true
    }],
    logLevel: 'info',
    bail: 0,
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    services: [
        ['appium', {
            command: 'appium',
        }]
    ],
    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    },
}
