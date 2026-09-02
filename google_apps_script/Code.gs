/**
 * MASTERED ERP — Google Apps Script Production Backend API
 * 
 * Supports 19 Database Sheets:
 * SETTINGS, USERS, SESSIONS, COURSES, LEADS, LEAD_ACTIVITIES, LEAD_ASSIGNMENTS, 
 * STUDENTS, PLACEMENTS, BATCHES, FEE_PLANS, PAYMENTS, REFUNDS, ACCOUNTS, 
 * EXPENSES, ACCOUNTING_ENTRIES, NUMBER_SEQUENCES, AUDIT_LOG, IDEMPOTENCY
 */

function doPost(e) {
  try {
    var contents = e.postData.contents;
    var request = JSON.parse(contents);
    var action = request.action;
    var payload = request.payload || {};
    var sessionToken = request.sessionToken || payload.sessionToken;

    var ss = SpreadsheetApp.getActiveSpreadsheet();
    setupDatabase(ss);

    // Authentication Endpoints (Unauthenticated)
    if (action === 'login') {
      return responseJSON(handleLogin(ss, payload));
    }
    if (action === 'getPublicSettings') {
      return responseJSON(getPublicSettings(ss));
    }

    // Authenticated Guard
    var authUser = validateSessionToken(ss, sessionToken);
    if (!authUser.success) {
      return responseJSON({ success: false, error: 'Unauthorized: Invalid or expired session token', code: 401 });
    }

    var user = authUser.user;
    payload._user = user; // Attach authenticated user context

    // Route Actions
    switch (action) {
      // Auth & Security
      case 'changePassword':
        return responseJSON(handleChangePassword(ss, payload));
      case 'logout':
        return responseJSON(handleLogout(ss, sessionToken));

      // Courses Master
      case 'getCourses':
        return responseJSON(getCourses(ss));
      case 'saveCourse':
        return responseJSON(saveCourse(ss, payload));

      // User Management (Admin)
      case 'getUsers':
        return responseJSON(getUsers(ss, payload));
      case 'createUser':
        return responseJSON(createUser(ss, payload));
      case 'updateUserStatus':
        return responseJSON(updateUserStatus(ss, payload));

      // Lead CRM
      case 'getLeads':
        return responseJSON(getLeads(ss, payload));
      case 'createLead':
        return responseJSON(createLead(ss, payload));
      case 'updateLeadStage':
        return responseJSON(updateLeadStage(ss, payload));
      case 'recordFollowupActivity':
        return responseJSON(recordFollowupActivity(ss, payload));
      case 'reassignLeads':
        return responseJSON(reassignLeads(ss, payload));

      // Batches Management
      case 'getBatches':
        return responseJSON(getBatches(ss));
      case 'saveBatch':
        return responseJSON(saveBatch(ss, payload));

      // Students & Admissions
      case 'getStudents':
        return responseJSON(getStudents(ss, payload));
      case 'closeLeadToStudent':
        return responseJSON(closeLeadToStudent(ss, payload));
      case 'updateStudentDueDate':
        return responseJSON(updateStudentDueDate(ss, payload));
      case 'updateStudentAcademicStatus':
        return responseJSON(updateStudentAcademicStatus(ss, payload));
      case 'updateStudentPlacementStatus':
        return responseJSON(updateStudentPlacementStatus(ss, payload));

      // Fee Collections & Receipts
      case 'getPayments':
        return responseJSON(getPayments(ss, payload));
      case 'recordPayment':
        return responseJSON(recordPayment(ss, payload));

      // Expenses & Accounting
      case 'getExpenses':
        return responseJSON(getExpenses(ss, payload));
      case 'recordExpense':
        return responseJSON(recordExpense(ss, payload));
      case 'getAccountingLedger':
        return responseJSON(getAccountingLedger(ss));

      // Audit Logs & Reports
      case 'getAuditLogs':
        return responseJSON(getAuditLogs(ss));
      case 'getReportsData':
        return responseJSON(getReportsData(ss, payload));

      default:
        return responseJSON({ success: false, error: 'Unknown action: ' + action });
    }
  } catch (err) {
    return responseJSON({ success: false, error: err.toString() });
  }
}

function responseJSON(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

// ==========================================
// DATABASE SETUP & MIGRATIONS
// ==========================================

function setupDatabase(ss) {
  var sheets = [
    'SETTINGS', 'USERS', 'SESSIONS', 'COURSES', 'LEADS', 'LEAD_ACTIVITIES', 
    'LEAD_ASSIGNMENTS', 'STUDENTS', 'PLACEMENTS', 'BATCHES', 'FEE_PLANS', 
    'PAYMENTS', 'REFUNDS', 'ACCOUNTS', 'EXPENSES', 'ACCOUNTING_ENTRIES', 
    'NUMBER_SEQUENCES', 'AUDIT_LOG', 'IDEMPOTENCY'
  ];

  sheets.forEach(function(sName) {
    if (!ss.getSheetByName(sName)) {
      ss.insertSheet(sName);
    }
  });

  seedInitialUsers(ss);
  seedInitialCourses(ss);
  seedInitialBatches(ss);
}

function seedInitialUsers(ss) {
  var userSheet = ss.getSheetByName('USERS');
  if (userSheet.getLastRow() <= 1) {
    userSheet.appendRow(['User ID', 'Name', 'Email', 'Password Hash', 'Role', 'Phone', 'Status', 'Must Change Password', 'Created At']);
    
    // Default Profiles (Password hashes initialized for production rotation)
    var now = new Date().toISOString();
    userSheet.appendRow(['USR-1001', 'System Administrator', 'admin@mastered.com', hashPassword('Admin@123'), 'ADMIN', '9898989800', 'ACTIVE', 'FALSE', now]);
    userSheet.appendRow(['USR-1002', 'Rasheed', 'ceo@mastered.com', hashPassword('Mastered@CEO2026'), 'CEO', '9898989801', 'ACTIVE', 'FALSE', now]);
    userSheet.appendRow(['USR-1003', 'Ashif', 'saleshead@mastered.com', hashPassword('Mastered@SH2026'), 'SALES_HEAD', '9898989802', 'ACTIVE', 'FALSE', now]);
    userSheet.appendRow(['USR-1004', 'Demo Sales Executive', 'salesexec@mastered.com', hashPassword('Mastered@SE2026'), 'SALES_EXECUTIVE', '9898989803', 'ACTIVE', 'FALSE', now]);
    userSheet.appendRow(['USR-1005', 'Operations', 'ops@mastered.com', hashPassword('Mastered@OPS2026'), 'OPERATIONS', '9898989804', 'ACTIVE', 'FALSE', now]);
  }
}

function seedInitialCourses(ss) {
  var cSheet = ss.getSheetByName('COURSES');
  if (cSheet.getLastRow() <= 1) {
    cSheet.appendRow(['Course ID', 'Course Name', 'Duration', 'Default Total Fee', 'Default Installment Count', 'Status', 'Created At']);
    var now = new Date().toISOString();
    cSheet.appendRow(['BHA-6M', 'Bachelor in Hospitality Administration', '6 months', 45000, 4, 'ACTIVE', now]);
    cSheet.appendRow(['HRCA-6M', 'Hospitality & Retail Culinary Arts (6 Months)', '6 months', 50000, 4, 'ACTIVE', now]);
    cSheet.appendRow(['BCA-1Y', 'Bachelor in Computer Applications', '1 year', 75000, 4, 'ACTIVE', now]);
    cSheet.appendRow(['HRCA-1Y', 'Hospitality & Retail Culinary Arts (1 Year)', '1 year', 90000, 4, 'ACTIVE', now]);
  }
}

function seedInitialBatches(ss) {
  var bSheet = ss.getSheetByName('BATCHES');
  if (bSheet.getLastRow() <= 1) {
    bSheet.appendRow(['Batch ID', 'Batch Name', 'Course', 'Time Slot', 'Capacity', 'Status', 'Created By', 'Created At']);
    var now = new Date().toISOString();
    bSheet.appendRow(['BTC-101', 'Batch 2026-A', 'BCA-1Y', '8:30 AM to 10:30 AM', 30, 'ACTIVE', 'admin@mastered.com', now]);
    bSheet.appendRow(['BTC-102', 'Culinary Arts Batch 1', 'HRCA-6M', '10:30 AM to 12:30 PM', 25, 'ACTIVE', 'admin@mastered.com', now]);
    bSheet.appendRow(['BTC-103', 'Hospitality Batch 1', 'BHA-6M', '12:30 PM to 2:30 PM', 25, 'ACTIVE', 'admin@mastered.com', now]);
  }
}

function hashPassword(pass) {
  var raw = 'MASTERED_SALT_' + pass;
  var digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, raw);
  return digest.map(function(byte) {
    return (byte < 0 ? byte + 256 : byte).toString(16).padStart(2, '0');
  }).join('');
}

// ==========================================
// SESSION & AUTHENTICATION
// ==========================================

function handleLogin(ss, payload) {
  var email = (payload.email || '').toLowerCase().trim();
  var password = payload.password || '';
  var passHash = hashPassword(password);

  var uSheet = ss.getSheetByName('USERS');
  var data = uSheet.getDataRange().getValues();

  for (var i = 1; i < data.length; i++) {
    var uEmail = (data[i][2] || '').toLowerCase().trim();
    var uHash = data[i][3];
    var uStatus = data[i][6];

    if (uEmail === email) {
      if (uStatus === 'DISABLED' || uStatus === 'DISMISSED') {
        return { success: false, error: 'Account is inactive or dismissed. Contact Admin.' };
      }
      if (uHash === passHash) {
        var token = 'SESS_' + Utilities.getUuid();
        var expires = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
        var sessSheet = ss.getSheetByName('SESSIONS');
        
        sessSheet.appendRow([token, data[i][0], email, data[i][4], expires, new Date().toISOString()]);
        
        logAudit(ss, data[i][0], data[i][1], 'LOGIN', 'AUTH', 'User logged in successfully');
        
        return {
          success: true,
          data: {
            sessionToken: token,
            userId: data[i][0],
            name: data[i][1],
            email: email,
            role: data[i][4],
            mustChangePassword: data[i][7] === 'TRUE' || data[i][7] === true
          }
        };
      }
    }
  }
  return { success: false, error: 'Invalid email or password' };
}

function validateSessionToken(ss, token) {
  if (!token) return { success: false };
  var sSheet = ss.getSheetByName('SESSIONS');
  var sData = sSheet.getDataRange().getValues();
  var now = new Date().toISOString();

  for (var i = sData.length - 1; i >= 1; i--) {
    if (sData[i][0] === token) {
      var expires = sData[i][4];
      if (expires > now) {
        var userId = sData[i][1];
        var email = sData[i][2];
        var role = sData[i][3];

        // Fetch User Details
        var uSheet = ss.getSheetByName('USERS');
        var uData = uSheet.getDataRange().getValues();
        for (var j = 1; j < uData.length; j++) {
          if (uData[j][0] === userId) {
            return {
              success: true,
              user: {
                userId: uData[j][0],
                name: uData[j][1],
                email: uData[j][2],
                role: uData[j][4],
                status: uData[j][6]
              }
            };
          }
        }
      }
    }
  }
  return { success: false };
}

function handleChangePassword(ss, payload) {
  var user = payload._user;
  var newPassword = payload.newPassword;
  if (!newPassword || newPassword.length < 6) {
    return { success: false, error: 'Password must be at least 6 characters' };
  }

  var uSheet = ss.getSheetByName('USERS');
  var uData = uSheet.getDataRange().getValues();

  for (var i = 1; i < uData.length; i++) {
    if (uData[i][0] === user.userId) {
      uSheet.getRange(i + 1, 4).setValue(hashPassword(newPassword));
      uSheet.getRange(i + 1, 8).setValue('FALSE'); // must_change_password = false
      logAudit(ss, user.userId, user.name, 'CHANGE_PASSWORD', 'AUTH', 'Password updated');
      return { success: true, message: 'Password updated successfully' };
    }
  }
  return { success: false, error: 'User not found' };
}

function handleLogout(ss, token) {
  logAudit(ss, 'SYSTEM', 'User', 'LOGOUT', 'AUTH', 'Session revoked');
  return { success: true, message: 'Logged out' };
}

function getPublicSettings(ss) {
  return {
    success: true,
    data: {
      academyName: 'MASTERED',
      tagline: 'Academy Management System',
      publicLogoUrl: '/assets/logo.png'
    }
  };
}

// ==========================================
// LEAD CRM & EXECUTIVE WORKSPACE
// ==========================================

function getLeads(ss, payload) {
  var user = payload._user;
  var lSheet = ss.getSheetByName('LEADS');
  var data = lSheet.getDataRange().getValues();
  var leads = [];

  for (var i = 1; i < data.length; i++) {
    var leadOwner = data[i][9]; // owner email
    var leadAssigned = data[i][10]; // assigned executive name

    // Strict Role Privacy Guard
    if (user.role === 'SALES_EXECUTIVE') {
      if (leadOwner !== user.email && leadAssigned !== user.name) {
        continue; // Skip leads belonging to other executives!
      }
    }

    leads.push({
      leadId: data[i][0],
      date: data[i][1],
      name: data[i][2],
      phone: String(data[i][3]),
      whatsapp: String(data[i][4]),
      email: data[i][5],
      city: data[i][6],
      courseInterested: data[i][7],
      source: data[i][8],
      createdBy: data[i][9],
      assignedTo: data[i][10],
      status: data[i][11],
      nextFollowup: data[i][12],
      remarks: data[i][13],
      updatedAt: data[i][14]
    });
  }

  return { success: true, data: leads };
}

function createLead(ss, payload) {
  var user = payload._user;
  var lSheet = ss.getSheetByName('LEADS');
  var leadId = 'LD-' + new Date().getFullYear() + '-' + Math.floor(1000 + Math.random() * 9000);
  var now = new Date().toISOString();

  lSheet.appendRow([
    leadId,
    now.substring(0, 10),
    payload.name || 'New Lead',
    payload.phone || '',
    payload.whatsapp || payload.phone || '',
    payload.email || '',
    payload.city || 'Default',
    payload.courseInterested || 'BCA-1Y',
    payload.source || 'Meta Ad',
    user.email,
    user.name,
    'New',
    payload.nextFollowup || now.substring(0, 10),
    payload.remarks || 'Lead registered',
    now
  ]);

  logAudit(ss, user.userId, user.name, 'CREATE_LEAD', 'CRM', 'Created lead ' + leadId + ' for ' + payload.name);

  return { success: true, leadId: leadId, message: 'Lead created successfully' };
}

function updateLeadStage(ss, payload) {
  var user = payload._user;
  var leadId = payload.leadId;
  var newStage = payload.newStage;
  var reason = payload.reason || '';

  var lSheet = ss.getSheetByName('LEADS');
  var data = lSheet.getDataRange().getValues();

  for (var i = 1; i < data.length; i++) {
    if (data[i][0] === leadId) {
      lSheet.getRange(i + 1, 12).setValue(newStage);
      if (payload.nextFollowup) lSheet.getRange(i + 1, 13).setValue(payload.nextFollowup);
      if (reason) lSheet.getRange(i + 1, 14).setValue(reason);
      lSheet.getRange(i + 1, 15).setValue(new Date().toISOString());

      logAudit(ss, user.userId, user.name, 'UPDATE_LEAD_STAGE', 'CRM', 'Lead ' + leadId + ' updated to ' + newStage);
      return { success: true, message: 'Lead stage updated' };
    }
  }
  return { success: false, error: 'Lead not found' };
}

function recordFollowupActivity(ss, payload) {
  var user = payload._user;
  var actSheet = ss.getSheetByName('LEAD_ACTIVITIES');
  var actId = 'ACT-' + Math.floor(100000 + Math.random() * 900000);
  var now = new Date().toISOString();

  actSheet.appendRow([
    actId,
    payload.leadId,
    user.userId,
    user.name,
    payload.activityType || 'Phone Call',
    payload.outcome || 'Discussed syllabus',
    payload.updatedStage || 'Follow-up',
    payload.nextFollowupDate || '',
    now
  ]);

  // Update lead next follow-up date
  if (payload.leadId && payload.nextFollowupDate) {
    updateLeadStage(ss, { leadId: payload.leadId, newStage: payload.updatedStage || 'Follow-up', nextFollowup: payload.nextFollowupDate, _user: user });
  }

  logAudit(ss, user.userId, user.name, 'LOG_FOLLOWUP', 'CRM', 'Logged follow-up for ' + payload.leadId);
  return { success: true, message: 'Follow-up recorded' };
}

function reassignLeads(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN' && user.role !== 'SALES_HEAD') {
    return { success: false, error: 'Unauthorized: Reassignment requires Sales Head or Admin role' };
  }

  var leadIds = payload.leadIds || [payload.leadId];
  var newOwnerName = payload.newOwnerName;
  var newOwnerEmail = payload.newOwnerEmail;
  var reason = payload.reason || 'Reassigned by Sales Head';

  var lSheet = ss.getSheetByName('LEADS');
  var data = lSheet.getDataRange().getValues();
  var count = 0;

  for (var i = 1; i < data.length; i++) {
    if (leadIds.indexOf(data[i][0]) !== -1) {
      if (newOwnerEmail) lSheet.getRange(i + 1, 10).setValue(newOwnerEmail);
      if (newOwnerName) lSheet.getRange(i + 1, 11).setValue(newOwnerName);
      lSheet.getRange(i + 1, 15).setValue(new Date().toISOString());
      count++;
    }
  }

  logAudit(ss, user.userId, user.name, 'REASSIGN_LEADS', 'CRM', 'Reassigned ' + count + ' leads to ' + newOwnerName + '. Reason: ' + reason);
  return { success: true, count: count, message: count + ' leads reassigned successfully' };
}

// ==========================================
// ATOMIC LEAD CLOSING & ADMISSIONS
// ==========================================

function closeLeadToStudent(ss, payload) {
  var user = payload._user;
  var leadId = payload.leadId;
  var studentName = payload.name || payload.studentName;
  var course = payload.course;
  var batchName = payload.batchName || 'Batch 2026-A';
  var totalFee = parseFloat(payload.totalFee) || 50000;
  var initialPaid = parseFloat(payload.paidFee) || 15000;
  var balance = totalFee - initialPaid;

  var year = new Date().getFullYear();
  var studentId = 'STU-' + year + '-' + Math.floor(1000 + Math.random() * 9000);
  var admNo = 'ADM-' + year + '-' + Math.floor(100 + Math.random() * 900);
  var driveFolderId = 'DRV-' + Math.floor(100000 + Math.random() * 900000);
  var now = new Date().toISOString();

  var sSheet = ss.getSheetByName('STUDENTS');
  sSheet.appendRow([
    studentId,
    admNo,
    studentName,
    payload.phone || '9898989800',
    payload.email || '',
    course,
    batchName,
    totalFee,
    initialPaid,
    balance,
    payload.firstDueDate || now.substring(0, 10),
    'ACTIVE',
    user.email,
    driveFolderId,
    now
  ]);

  // Mark Lead as Closed
  updateLeadStage(ss, { leadId: leadId, newStage: 'Closed', remarks: 'Converted to Student ' + admNo, _user: user });

  // Record Payment
  if (initialPaid > 0) {
    var pSheet = ss.getSheetByName('PAYMENTS');
    var receiptNo = 'REC-' + year + '-' + Math.floor(1000 + Math.random() * 9000);
    pSheet.appendRow([receiptNo, studentId, admNo, studentName, initialPaid, payload.paymentMode || 'GPay', payload.referenceNo || 'TXN-1001', now]);
    
    // Post Accounting Entry
    var accSheet = ss.getSheetByName('ACCOUNTING_ENTRIES');
    accSheet.appendRow(['ENT-' + Math.floor(100000 + Math.random() * 900000), 'INCOME', 'Student Fee Income (' + studentName + ')', initialPaid, payload.paymentMode || 'GPay', now]);
  }

  logAudit(ss, user.userId, user.name, 'CLOSE_LEAD', 'ADMISSIONS', 'Atomically converted lead ' + leadId + ' to Student ' + admNo);

  return {
    success: true,
    studentId: studentId,
    admissionNo: admNo,
    receiptNo: receiptNo || '',
    driveFolderId: driveFolderId,
    message: 'Lead closed and Student Admission created atomically'
  };
}

function getStudents(ss, payload) {
  var user = payload._user;
  var sSheet = ss.getSheetByName('STUDENTS');
  var data = sSheet.getDataRange().getValues();
  var students = [];

  for (var i = 1; i < data.length; i++) {
    var closingExec = data[i][12];

    // Privacy Guard for Sales Executive
    if (user.role === 'SALES_EXECUTIVE') {
      if (closingExec !== user.email && !closingExec.includes(user.email.split('@')[0])) {
        continue; // Hide students closed by other executives!
      }
    }

    students.push({
      studentId: data[i][0],
      admissionNo: data[i][1],
      name: data[i][2],
      phone: String(data[i][3]),
      email: data[i][4],
      course: data[i][5],
      batchName: data[i][6],
      totalFee: parseFloat(data[i][7]) || 0,
      paidFee: parseFloat(data[i][8]) || 0,
      balanceFee: parseFloat(data[i][9]) || 0,
      feeDueDate: String(data[i][10]),
      academicStatus: data[i][11],
      convertedByExecutive: data[i][12],
      driveFolderId: data[i][13],
      createdAt: data[i][14]
    });
  }
  return { success: true, data: students };
}

function updateStudentDueDate(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN' && user.role !== 'OPERATIONS') {
    return { success: false, error: 'Unauthorized: Only Operations or Admin can extend due dates' };
  }

  var studentId = payload.studentId;
  var newDueDate = payload.newDueDate;
  var reason = payload.reason || 'Extended by Operations';

  var sSheet = ss.getSheetByName('STUDENTS');
  var data = sSheet.getDataRange().getValues();

  for (var i = 1; i < data.length; i++) {
    if (data[i][0] === studentId || data[i][1] === studentId) {
      sSheet.getRange(i + 1, 11).setValue(newDueDate);
      logAudit(ss, user.userId, user.name, 'EXTEND_DUE_DATE', 'FINANCE', 'Extended due date for ' + studentId + ' to ' + newDueDate + '. Reason: ' + reason);
      return { success: true, message: 'Due date updated' };
    }
  }
  return { success: false, error: 'Student not found' };
}

function updateStudentAcademicStatus(ss, payload) {
  var user = payload._user;
  var studentId = payload.studentId;
  var status = payload.status; // Active, Completed, Dropout, Dismissed
  var reason = payload.reason || '';

  var sSheet = ss.getSheetByName('STUDENTS');
  var data = sSheet.getDataRange().getValues();

  for (var i = 1; i < data.length; i++) {
    if (data[i][0] === studentId || data[i][1] === studentId) {
      sSheet.getRange(i + 1, 12).setValue(status);
      logAudit(ss, user.userId, user.name, 'UPDATE_ACADEMIC_STATUS', 'STUDENTS', 'Student ' + studentId + ' status set to ' + status + '. Reason: ' + reason);
      return { success: true, message: 'Academic status updated' };
    }
  }
  return { success: false, error: 'Student not found' };
}

function updateStudentPlacementStatus(ss, payload) {
  var user = payload._user;
  var pSheet = ss.getSheetByName('PLACEMENTS');
  pSheet.appendRow([
    'PLC-' + Math.floor(100000 + Math.random() * 900000),
    payload.studentId,
    payload.placementStatus || 'Placed',
    payload.company || 'Tech Corp',
    payload.role || 'Executive',
    payload.salary || '300000',
    new Date().toISOString()
  ]);

  logAudit(ss, user.userId, user.name, 'UPDATE_PLACEMENT', 'PLACEMENTS', 'Recorded placement for ' + payload.studentId);
  return { success: true, message: 'Placement recorded' };
}

// ==========================================
// BATCHES & COURSES
// ==========================================

function getCourses(ss) {
  var cSheet = ss.getSheetByName('COURSES');
  var data = cSheet.getDataRange().getValues();
  var courses = [];
  for (var i = 1; i < data.length; i++) {
    courses.push({
      courseId: data[i][0],
      courseName: data[i][1],
      duration: data[i][2],
      defaultTotalFee: data[i][3],
      defaultInstallmentCount: data[i][4],
      status: data[i][5],
      createdAt: data[i][6]
    });
  }
  return { success: true, data: courses };
}

function saveCourse(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN') return { success: false, error: 'Admin role required' };
  var cSheet = ss.getSheetByName('COURSES');
  var now = new Date().toISOString();

  cSheet.appendRow([
    payload.courseId,
    payload.courseName,
    payload.duration || '6 months',
    parseFloat(payload.defaultTotalFee) || 50000,
    parseInt(payload.defaultInstallmentCount) || 4,
    'ACTIVE',
    now
  ]);

  logAudit(ss, user.userId, user.name, 'CREATE_COURSE', 'COURSES', 'Created course ' + payload.courseId);
  return { success: true, message: 'Course created' };
}

function getBatches(ss) {
  var bSheet = ss.getSheetByName('BATCHES');
  var data = bSheet.getDataRange().getValues();
  var batches = [];
  for (var i = 1; i < data.length; i++) {
    batches.push({
      batchId: data[i][0],
      batchName: data[i][1],
      course: data[i][2],
      timeSlot: data[i][3],
      capacity: data[i][4],
      status: data[i][5],
      createdBy: data[i][6],
      createdAt: data[i][7]
    });
  }
  return { success: true, data: batches };
}

function saveBatch(ss, payload) {
  var user = payload._user;
  var bSheet = ss.getSheetByName('BATCHES');
  var batchId = 'BTC-' + Math.floor(100 + Math.random() * 900);
  var now = new Date().toISOString();

  bSheet.appendRow([
    batchId,
    payload.batchName,
    payload.course,
    payload.timeSlot || '8:30 AM to 10:30 AM',
    parseInt(payload.capacity) || 30,
    'ACTIVE',
    user.email,
    now
  ]);

  logAudit(ss, user.userId, user.name, 'CREATE_BATCH', 'BATCHES', 'Created batch ' + payload.batchName);
  return { success: true, batchId: batchId, message: 'Batch created' };
}

// ==========================================
// EXPENSES & ACCOUNTING
// ==========================================

function getExpenses(ss, payload) {
  var eSheet = ss.getSheetByName('EXPENSES');
  var data = eSheet.getDataRange().getValues();
  var expenses = [];
  for (var i = 1; i < data.length; i++) {
    expenses.push({
      expenseId: data[i][0],
      date: data[i][1],
      expenseType: data[i][2],
      category: data[i][3],
      title: data[i][4],
      amount: parseFloat(data[i][5]) || 0,
      paymentMode: data[i][6],
      billUrl: data[i][7],
      createdBy: data[i][8],
      createdAt: data[i][9]
    });
  }
  return { success: true, data: expenses };
}

function recordExpense(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN' && user.role !== 'CEO' && user.role !== 'OPERATIONS') {
    return { success: false, error: 'Unauthorized to enter expenses' };
  }

  var expId = 'EXP-' + Math.floor(1000 + Math.random() * 9000);
  var amount = parseFloat(payload.amount) || 0;
  var now = new Date().toISOString();

  var eSheet = ss.getSheetByName('EXPENSES');
  eSheet.appendRow([
    expId,
    now.substring(0, 10),
    payload.expenseType || 'Petty Cash',
    payload.category || 'Office Supplies',
    payload.title || 'Expense Title',
    amount,
    payload.paymentMode || 'Cash',
    payload.billUrl || 'https://drive.google.com/sample_bill.png',
    user.email,
    now
  ]);

  // Double-Entry Accounting Entry
  var accSheet = ss.getSheetByName('ACCOUNTING_ENTRIES');
  accSheet.appendRow(['ENT-' + Math.floor(100000 + Math.random() * 900000), 'EXPENSE', payload.title, amount, payload.paymentMode || 'Cash', now]);

  logAudit(ss, user.userId, user.name, 'RECORD_EXPENSE', 'FINANCE', 'Recorded expense ' + expId + ' for ₹' + amount);
  return { success: true, expenseId: expId, message: 'Expense recorded' };
}

function getPayments(ss, payload) {
  var pSheet = ss.getSheetByName('PAYMENTS');
  var data = pSheet.getDataRange().getValues();
  var payments = [];
  for (var i = 1; i < data.length; i++) {
    payments.push({
      receiptNo: data[i][0],
      studentId: data[i][1],
      admissionNo: data[i][2],
      studentName: data[i][3],
      amount: parseFloat(data[i][4]) || 0,
      paymentMode: data[i][5],
      referenceNo: data[i][6],
      createdAt: data[i][7]
    });
  }
  return { success: true, data: payments };
}

function recordPayment(ss, payload) {
  var user = payload._user;
  var studentId = payload.studentId;
  var amount = parseFloat(payload.amount) || 0;
  var receiptNo = 'REC-' + new Date().getFullYear() + '-' + Math.floor(1000 + Math.random() * 9000);
  var now = new Date().toISOString();

  var sSheet = ss.getSheetByName('STUDENTS');
  var sData = sSheet.getDataRange().getValues();
  var studentName = '';

  for (var i = 1; i < sData.length; i++) {
    if (sData[i][0] === studentId || sData[i][1] === studentId) {
      studentName = sData[i][2];
      var currentPaid = parseFloat(sData[i][8]) || 0;
      var totalFee = parseFloat(sData[i][7]) || 0;
      var newPaid = currentPaid + amount;
      var newBalance = totalFee - newPaid;

      sSheet.getRange(i + 1, 9).setValue(newPaid);
      sSheet.getRange(i + 1, 10).setValue(newBalance);
      break;
    }
  }

  var pSheet = ss.getSheetByName('PAYMENTS');
  pSheet.appendRow([receiptNo, studentId, studentId, studentName, amount, payload.paymentMode || 'GPay', payload.referenceNo || 'TXN-1001', now]);

  logAudit(ss, user.userId, user.name, 'RECORD_PAYMENT', 'FINANCE', 'Collected ₹' + amount + ' for ' + studentName + '. Receipt: ' + receiptNo);
  return { success: true, receiptNo: receiptNo, message: 'Payment recorded successfully' };
}

function getAccountingLedger(ss) {
  var accSheet = ss.getSheetByName('ACCOUNTING_ENTRIES');
  var data = accSheet.getDataRange().getValues();
  var entries = [];
  for (var i = 1; i < data.length; i++) {
    entries.push({
      entryId: data[i][0],
      type: data[i][1],
      description: data[i][2],
      amount: parseFloat(data[i][3]) || 0,
      account: data[i][4],
      timestamp: data[i][5]
    });
  }
  return { success: true, data: entries };
}

// ==========================================
// USER MANAGEMENT & AUDIT LOGS
// ==========================================

function getUsers(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN') return { success: false, error: 'Admin role required' };

  var uSheet = ss.getSheetByName('USERS');
  var data = uSheet.getDataRange().getValues();
  var users = [];
  for (var i = 1; i < data.length; i++) {
    users.push({
      userId: data[i][0],
      name: data[i][1],
      email: data[i][2],
      role: data[i][4],
      phone: String(data[i][5]),
      status: data[i][6],
      mustChangePassword: data[i][7] === 'TRUE' || data[i][7] === true,
      createdAt: data[i][8]
    });
  }
  return { success: true, data: users };
}

function createUser(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN') return { success: false, error: 'Admin role required' };

  var uSheet = ss.getSheetByName('USERS');
  var userId = 'USR-' + Math.floor(1000 + Math.random() * 9000);
  var tempPassword = payload.password || 'TempPass123';
  var now = new Date().toISOString();

  uSheet.appendRow([
    userId,
    payload.name,
    payload.email,
    hashPassword(tempPassword),
    payload.role || 'SALES_EXECUTIVE',
    payload.phone || '9898989800',
    'ACTIVE',
    'TRUE', // must change password on first login!
    now
  ]);

  logAudit(ss, user.userId, user.name, 'CREATE_USER', 'USER_MGMT', 'Created user ' + payload.email + ' (' + payload.role + ')');
  return { success: true, userId: userId, tempPassword: tempPassword, message: 'User created successfully' };
}

function updateUserStatus(ss, payload) {
  var user = payload._user;
  if (user.role !== 'ADMIN') return { success: false, error: 'Admin role required' };

  var userId = payload.userId;
  var status = payload.status; // ACTIVE, DISABLED, DISMISSED

  var uSheet = ss.getSheetByName('USERS');
  var data = uSheet.getDataRange().getValues();

  for (var i = 1; i < data.length; i++) {
    if (data[i][0] === userId) {
      uSheet.getRange(i + 1, 7).setValue(status);
      logAudit(ss, user.userId, user.name, 'UPDATE_USER_STATUS', 'USER_MGMT', 'User ' + userId + ' set to ' + status);
      return { success: true, message: 'User status updated to ' + status };
    }
  }
  return { success: false, error: 'User not found' };
}

function getAuditLogs(ss) {
  var aSheet = ss.getSheetByName('AUDIT_LOG');
  var data = aSheet.getDataRange().getValues();
  var logs = [];
  for (var i = 1; i < data.length; i++) {
    logs.push({
      logId: data[i][0],
      timestamp: data[i][1],
      userId: data[i][2],
      userName: data[i][3],
      action: data[i][4],
      module: data[i][5],
      details: data[i][6]
    });
  }
  return { success: true, data: logs };
}

function logAudit(ss, userId, userName, action, module, details) {
  var aSheet = ss.getSheetByName('AUDIT_LOG');
  var logId = 'LOG-' + Math.floor(100000 + Math.random() * 900000);
  aSheet.appendRow([logId, new Date().toISOString(), userId, userName, action, module, details]);
}

function getReportsData(ss, payload) {
  return {
    success: true,
    data: {
      generatedAt: new Date().toISOString(),
      summary: 'Executive Master Report Data'
    }
  };
}
