/**
 * MASTERED ERP v8.0 — Google Drive Storage Repository (DriveRepository.gs)
 */

var DriveRepository = {
  getRootFolder: function() {
    var folders = DriveApp.getFoldersByName('MASTERED');
    if (folders.hasNext()) {
      return folders.next();
    } else {
      return DriveApp.createFolder('MASTERED');
    }
  },

  testDriveConnections: function() {
    try {
      var root = this.getRootFolder();
      var tempFile = root.createFile('HEALTH_TEST_' + Date.now() + '.txt', 'Health check test file');
      var fileId = tempFile.getId();
      tempFile.setTrashed(true);
      return { success: true, fileId: fileId };
    } catch (err) {
      return { success: false, error: err.toString() };
    }
  }
};
