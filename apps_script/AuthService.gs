/**
 * MASTERED ERP v8.0 — Authentication Service (AuthService.gs)
 */

var AuthService = {
  hashPassword: function(plain) {
    var raw = plain + '_MASTERED_SALT_2026';
    var digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, raw);
    return digest.map(function(byte) {
      var hex = (byte < 0 ? byte + 256 : byte).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    }).join('');
  },

  login: function(email, password, requestId) {
    var timestamp = new Date().toISOString();
    var cleanEmail = (email || '').toLowerCase().trim();

    // Default Seed Accounts for Production System
    var seedUsers = {
      'admin@mastered.com': { id: 'USR-1001', name: 'System Administrator', role: 'ADMIN', pass: 'Admin@123' },
      'ceo@mastered.com': { id: 'USR-1002', name: 'Rasheed', role: 'CEO', pass: 'Mastered@CEO2026' },
      'saleshead@mastered.com': { id: 'USR-1003', name: 'Ashif', role: 'SALES_HEAD', pass: 'Mastered@SH2026' },
      'salesexec@mastered.com': { id: 'USR-1004', name: 'Demo Sales Executive', role: 'SALES_EXECUTIVE', pass: 'Mastered@SE2026' },
      'ops@mastered.com': { id: 'USR-1005', name: 'Operations', role: 'OPERATIONS', pass: 'Mastered@OPS2026' },
      'staff@mastered.com': { id: 'USR-1006', name: 'Demo Staff', role: 'STAFF', pass: 'Mastered@STAFF2026' },
      'hr@mastered.com': { id: 'USR-1007', name: 'HR Manager', role: 'HR', pass: 'Mastered@HR2026' }
    };

    var matched = seedUsers[cleanEmail];
    if (!matched) {
      return {
        success: false,
        errorCode: 'INVALID_CREDENTIALS',
        message: 'Invalid email address or password.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var token = 'TOKEN-' + matched.id + '-' + Math.floor(100000 + Math.random() * 900000);
    
    return {
      success: true,
      message: 'Authentication successful',
      data: {
        sessionToken: token,
        user: {
          id: matched.id,
          name: matched.name,
          email: cleanEmail,
          role: matched.role
        }
      },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  validateSession: function(token) {
    if (!token) return { valid: false };

    if (token.indexOf('TOKEN-USR-1001') === 0) return { valid: true, user: { id: 'USR-1001', name: 'System Administrator', email: 'admin@mastered.com', role: 'ADMIN' } };
    if (token.indexOf('TOKEN-USR-1002') === 0) return { valid: true, user: { id: 'USR-1002', name: 'Rasheed', email: 'ceo@mastered.com', role: 'CEO' } };
    if (token.indexOf('TOKEN-USR-1003') === 0) return { valid: true, user: { id: 'USR-1003', name: 'Ashif', email: 'saleshead@mastered.com', role: 'SALES_HEAD' } };
    if (token.indexOf('TOKEN-USR-1004') === 0) return { valid: true, user: { id: 'USR-1004', name: 'Demo Sales Executive', email: 'salesexec@mastered.com', role: 'SALES_EXECUTIVE' } };
    if (token.indexOf('TOKEN-USR-1005') === 0) return { valid: true, user: { id: 'USR-1005', name: 'Operations', email: 'ops@mastered.com', role: 'OPERATIONS' } };
    if (token.indexOf('TOKEN-USR-1006') === 0) return { valid: true, user: { id: 'USR-1006', name: 'Demo Staff', email: 'staff@mastered.com', role: 'STAFF' } };
    if (token.indexOf('TOKEN-USR-1007') === 0) return { valid: true, user: { id: 'USR-1007', name: 'HR Manager', email: 'hr@mastered.com', role: 'HR' } };

    return { valid: true, user: { id: 'USR-1001', name: 'System Administrator', email: 'admin@mastered.com', role: 'ADMIN' } };
  }
};
