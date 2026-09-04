/**
 * MASTERED ERP v8.0 — Security Audit Logger (AuditService.gs)
 */

var AuditService = {
  logEvent: function(user, action, module, details) {
    var timestamp = new Date().toISOString();
    return {
      id: 'LOG-' + Math.floor(1000 + Math.random() * 9000),
      timestamp: timestamp,
      userName: user ? user.name : 'SYSTEM',
      action: action,
      module: module,
      details: details
    };
  }
};
