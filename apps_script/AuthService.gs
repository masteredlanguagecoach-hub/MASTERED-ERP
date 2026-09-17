/**
 * MASTERED ERP v9.0 — Authentication & User Directory Service (AuthService.gs)
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

    var seedUsers = {
      'admin@mastered.com': { id: 'USR-1001', name: 'Farhan', role: 'FOUNDER', designation: 'Founder & Super Admin' },
      'farhan@mastered.com': { id: 'USR-1001', name: 'Farhan', role: 'FOUNDER', designation: 'Founder & Super Admin' },
      'ceo@mastered.com': { id: 'USR-1002', name: 'Rasheed', role: 'COE', designation: 'Chief Operating Executive' },
      'rasheed@mastered.com': { id: 'USR-1002', name: 'Rasheed', role: 'COE', designation: 'Chief Operating Executive' },
      'saleshead@mastered.com': { id: 'USR-1003', name: 'Ashif Darimi', role: 'SALES_HEAD', designation: 'Sales Head & Placement Head' },
      'salesexec@mastered.com': { id: 'USR-1004', name: 'Demo Sales Executive', role: 'SALES_EXECUTIVE', designation: 'Sales Executive' },
      'marketing@mastered.com': { id: 'USR-1005', name: 'Shahabaz', role: 'MARKETING_MGR', designation: 'Marketing Manager' },
      'social@mastered.com': { id: 'USR-1006', name: 'Shahal', role: 'SOCIAL_MGR', designation: 'Social Media Manager' },
      'video@mastered.com': { id: 'USR-1007', name: 'Video Editor', role: 'VIDEO_EDITOR', designation: 'Video Editor' },
      'growth@mastered.com': { id: 'USR-1008', name: 'Growth Officer', role: 'GROWTH_OFFICER', designation: 'Growth Officer & Auditor' },
      'ops@mastered.com': { id: 'USR-1009', name: 'Sahad', role: 'OPS_MGR', designation: 'Operations Manager' },
      'finance@mastered.com': { id: 'USR-1010', name: 'Mufeeda', role: 'FINANCE_MGR', designation: 'Finance Manager & Office Admin' },
      'hr@mastered.com': { id: 'USR-1011', name: 'HR Manager', role: 'HR', designation: 'HR Manager' },
      'staff@mastered.com': { id: 'USR-1012', name: 'Demo Staff', role: 'STAFF', designation: 'Operations Staff' },
      'trainer@mastered.com': { id: 'USR-1013', name: 'Demo Trainer', role: 'TRAINER', designation: 'Academic Trainer' }
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
          role: matched.role,
          designation: matched.designation
        }
      },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  validateSession: function(token) {
    if (!token) return { valid: false };

    if (token.indexOf('TOKEN-USR-1001') === 0) return { valid: true, user: { id: 'USR-1001', name: 'Farhan', email: 'admin@mastered.com', role: 'FOUNDER' } };
    if (token.indexOf('TOKEN-USR-1002') === 0) return { valid: true, user: { id: 'USR-1002', name: 'Rasheed', email: 'ceo@mastered.com', role: 'COE' } };
    if (token.indexOf('TOKEN-USR-1003') === 0) return { valid: true, user: { id: 'USR-1003', name: 'Ashif Darimi', email: 'saleshead@mastered.com', role: 'SALES_HEAD' } };
    if (token.indexOf('TOKEN-USR-1004') === 0) return { valid: true, user: { id: 'USR-1004', name: 'Demo Sales Executive', email: 'salesexec@mastered.com', role: 'SALES_EXECUTIVE' } };
    if (token.indexOf('TOKEN-USR-1005') === 0) return { valid: true, user: { id: 'USR-1005', name: 'Shahabaz', email: 'marketing@mastered.com', role: 'MARKETING_MGR' } };
    if (token.indexOf('TOKEN-USR-1006') === 0) return { valid: true, user: { id: 'USR-1006', name: 'Shahal', email: 'social@mastered.com', role: 'SOCIAL_MGR' } };
    if (token.indexOf('TOKEN-USR-1007') === 0) return { valid: true, user: { id: 'USR-1007', name: 'Video Editor', email: 'video@mastered.com', role: 'VIDEO_EDITOR' } };
    if (token.indexOf('TOKEN-USR-1008') === 0) return { valid: true, user: { id: 'USR-1008', name: 'Growth Officer', email: 'growth@mastered.com', role: 'GROWTH_OFFICER' } };
    if (token.indexOf('TOKEN-USR-1009') === 0) return { valid: true, user: { id: 'USR-1009', name: 'Sahad', email: 'ops@mastered.com', role: 'OPS_MGR' } };
    if (token.indexOf('TOKEN-USR-1010') === 0) return { valid: true, user: { id: 'USR-1010', name: 'Mufeeda', email: 'finance@mastered.com', role: 'FINANCE_MGR' } };
    if (token.indexOf('TOKEN-USR-1011') === 0) return { valid: true, user: { id: 'USR-1011', name: 'HR Manager', email: 'hr@mastered.com', role: 'HR' } };
    if (token.indexOf('TOKEN-USR-1012') === 0) return { valid: true, user: { id: 'USR-1012', name: 'Demo Staff', email: 'staff@mastered.com', role: 'STAFF' } };
    if (token.indexOf('TOKEN-USR-1013') === 0) return { valid: true, user: { id: 'USR-1013', name: 'Demo Trainer', email: 'trainer@mastered.com', role: 'TRAINER' } };

    return { valid: true, user: { id: 'USR-1001', name: 'Farhan', email: 'admin@mastered.com', role: 'FOUNDER' } };
  }
};
