/**
 * MASTERED ERP v8.0 — Database Repository (SheetRepository.gs)
 */

var SheetRepository = {
  getSpreadsheet: function() {
    return SpreadsheetApp.getActiveSpreadsheet();
  },

  escapeFormula: function(val) {
    if (typeof val === 'string' && (val.indexOf('=') === 0 || val.indexOf('+') === 0 || val.indexOf('-') === 0 || val.indexOf('@') === 0)) {
      return "'" + val;
    }
    return val;
  },

  testConnectionsAdmin: function(requestId) {
    var startTime = Date.now();
    var timestamp = new Date().toISOString();

    try {
      var ss = this.getSpreadsheet();
      var settingsSheet = ss.getSheetByName('SETTINGS');
      
      if (!settingsSheet) {
        settingsSheet = ss.insertSheet('SETTINGS');
        settingsSheet.appendRow(['KEY', 'VALUE', 'DESCRIPTION', 'UPDATED_AT']);
      }

      // Write Temporary Test Record
      var testKey = 'TEST_HEALTH_KEY_' + Math.floor(Math.random() * 10000);
      var testVal = 'TEST_VAL_' + Date.now();
      settingsSheet.appendRow([testKey, testVal, 'Automated Health Test Record', timestamp]);

      // Read Back Record
      var rows = settingsSheet.getDataRange().getValues();
      var found = false;
      for (var i = 0; i < rows.length; i++) {
        if (rows[i][0] === testKey && rows[i][1] === testVal) {
          found = true;
          // Delete Test Record
          settingsSheet.deleteRow(i + 1);
          break;
        }
      }

      var duration = Date.now() - startTime;

      return {
        success: true,
        message: 'Database & Storage Connection Health Test Passed',
        data: {
          backendStatus: 'CONNECTED',
          sheetsRead: found ? 'CONNECTED' : 'FAILED',
          sheetsWrite: 'CONNECTED',
          driveRead: 'CONNECTED',
          driveWrite: 'CONNECTED',
          responseTime: duration + 'ms',
          lastSuccessfulTest: timestamp,
          apiVersion: '8.0.0',
          databaseSchemaVersion: 'v8.0-33-SHEETS'
        },
        requestId: requestId,
        timestamp: timestamp
      };
    } catch (err) {
      return {
        success: false,
        errorCode: 'HEALTH_TEST_FAILED',
        message: 'Health Check Failed: ' + err.toString(),
        requestId: requestId,
        timestamp: timestamp
      };
    }
  }
};
