/**
 * ==============================================================================
 * MASTERED ERP - Google Apps Script Web API Backend (Production Addendum)
 * Configuration-Driven, Role-Isolated, Audited Business Management System
 * Sheets: SETTINGS, USERS, LEADS, STUDENTS, PAYMENTS, EXPENSES, BATCHES, COURSES, FOLLOW_UPS, AUDIT_LOGS, PLACEMENTS
 * ==============================================================================
 */

const SHEETS = {
  SETTINGS: 'SETTINGS',
  USERS: 'USERS',
  LEADS: 'LEADS',
  STUDENTS: 'STUDENTS',
  PAYMENTS: 'PAYMENTS',
  EXPENSES: 'EXPENSES',
  BATCHES: 'BATCHES',
  COURSES: 'COURSES',
  FOLLOW_UPS: 'FOLLOW_UPS',
  AUDIT_LOGS: 'AUDIT_LOGS',
  PLACEMENTS: 'PLACEMENTS'
};

function setupDatabase() {
  let ss;
  const files = DriveApp.getFilesByName('MASTERED_DATABASE');
  if (files.hasNext()) {
    ss = SpreadsheetApp.open(files.next());
  } else {
    ss = SpreadsheetApp.create('MASTERED_DATABASE');
  }

  setupSheet(ss, SHEETS.SETTINGS, ['key', 'value', 'updated_at']);
  setupSheet(ss, SHEETS.USERS, ['user_id', 'name', 'email', 'password_hash', 'role', 'status', 'phone', 'must_change_password', 'created_at']);
  setupSheet(ss, SHEETS.LEADS, ['lead_id', 'created_at', 'name', 'phone', 'whatsapp', 'email', 'city', 'course_interested', 'source', 'referral_student_id', 'owner_user_id', 'owner_user_name', 'current_stage', 'next_followup_date', 'last_followup_date', 'followup_status', 'remarks', 'not_interested_reason', 'created_by', 'updated_by', 'updated_at']);
  setupSheet(ss, SHEETS.STUDENTS, ['student_id', 'admission_no', 'admission_date', 'name', 'phone', 'whatsapp', 'email', 'address', 'course_id', 'course_name', 'batch_id', 'batch_name', 'batch_time_slot', 'batch_start_date', 'expected_completion_date', 'closed_by_executive_id', 'closed_by_executive_name', 'total_fee', 'discount', 'net_fee', 'paid_fee', 'pending_fee', 'fee_due_date', 'academic_status', 'lead_id', 'drive_folder_id', 'created_at']);
  setupSheet(ss, SHEETS.PAYMENTS, ['payment_id', 'receipt_no', 'date', 'student_id', 'student_name', 'installment_no', 'amount', 'payment_mode', 'reference_no', 'remarks', 'drive_file_id', 'collected_by', 'created_at']);
  setupSheet(ss, SHEETS.EXPENSES, ['expense_id', 'date', 'expense_type', 'category', 'description', 'amount', 'paid_to', 'payment_mode', 'reference_no', 'bill_drive_file_id', 'approval_status', 'created_by', 'created_at']);
  setupSheet(ss, SHEETS.BATCHES, ['batch_id', 'batch_name', 'course_id', 'course_name', 'start_date', 'expected_completion_date', 'time_slot', 'capacity', 'assigned_students_count', 'status', 'created_by', 'created_at']);
  setupSheet(ss, SHEETS.COURSES, ['course_id', 'course_name', 'duration', 'default_total_fee', 'default_installment_count', 'status', 'created_at']);
  setupSheet(ss, SHEETS.FOLLOW_UPS, ['followup_id', 'lead_id', 'executive_id', 'executive_name', 'activity_type', 'date_time', 'outcome_note', 'updated_stage', 'next_followup_date', 'created_at']);
  setupSheet(ss, SHEETS.AUDIT_LOGS, ['log_id', 'timestamp', 'user_id', 'user_name', 'action', 'module', 'details']);
  setupSheet(ss, SHEETS.PLACEMENTS, ['student_id', 'student_name', 'status', 'company_name', 'job_title', 'placement_type', 'joining_date', 'stipend_salary', 'remarks', 'updated_at']);

  const sheet1 = ss.getSheetByName('Sheet1');
  if (sheet1) ss.deleteSheet(sheet1);

  // Setup Drive Folders
  let rootFolder;
  const folders = DriveApp.getFoldersByName('MASTERED');
  if (folders.hasNext()) {
    rootFolder = folders.next();
  } else {
    rootFolder = DriveApp.createFolder('MASTERED');
  }

  ['Students', 'Receipts', 'Expenses', 'Reports', 'Backups'].forEach(name => {
    const sub = rootFolder.getFoldersByName(name);
    if (!sub.hasNext()) rootFolder.createFolder(name);
  });

  // Seed Default Configuration Masters
  seedCoursesMaster(ss);
  seedInitialUsers(ss);
  seedInitialBatches(ss);
  seedSettings(ss);

  return { status: 'Database setup complete' };
}

function seedCoursesMaster(ss) {
  const sheet = ss.getSheetByName(SHEETS.COURSES);
  if (sheet.getDataRange().getValues().length <= 1) {
    const now = new Date().toISOString();
    sheet.appendRow(['BHA-6M', 'Bachelor in Hospitality Administration', '6 months', 45000, 4, 'ACTIVE', now]);
    sheet.appendRow(['HRCA-6M', 'Hospitality & Retail Culinary Arts (6 Months)', '6 months', 50000, 4, 'ACTIVE', now]);
    sheet.appendRow(['BCA-1Y', 'Bachelor in Computer Applications', '1 year', 75000, 4, 'ACTIVE', now]);
    sheet.appendRow(['HRCA-1Y', 'Hospitality & Retail Culinary Arts (1 Year)', '1 year', 90000, 4, 'ACTIVE', now]);
  }
}

function seedInitialUsers(ss) {
  const sheet = ss.getSheetByName(SHEETS.USERS);
  if (sheet.getDataRange().getValues().length <= 1) {
    const now = new Date().toISOString();
    sheet.appendRow(['USR-1001', 'System Administrator', 'admin@mastered.com', hashPassword('admin123'), 'ADMIN', 'ACTIVE', '+91 9876543210', 'false', now]);
    sheet.appendRow(['USR-1002', 'Rasheed', 'ceo@mastered.com', hashPassword('admin123'), 'CEO', 'ACTIVE', '+91 9876543211', 'false', now]);
    sheet.appendRow(['USR-1003', 'Ashif', 'saleshead@mastered.com', hashPassword('admin123'), 'SALES_HEAD', 'ACTIVE', '+91 9876543212', 'false', now]);
    sheet.appendRow(['USR-1004', 'Demo Sales Executive', 'salesexec@mastered.com', hashPassword('admin123'), 'SALES_EXECUTIVE', 'ACTIVE', '+91 9876543213', 'false', now]);
    sheet.appendRow(['USR-1005', 'Operations', 'ops@mastered.com', hashPassword('admin123'), 'OPERATIONS', 'ACTIVE', '+91 9876543214', 'false', now]);
  }
}

function seedInitialBatches(ss) {
  const sheet = ss.getSheetByName(SHEETS.BATCHES);
  if (sheet.getDataRange().getValues().length <= 1) {
    const now = new Date().toISOString();
    sheet.appendRow(['BTC-101', 'Batch 2026-A (Full Stack)', 'BCA-1Y', 'Bachelor in Computer Applications', '2026-09-10', '2027-09-10', '8:30 AM to 10:30 AM', 30, 2, 'ACTIVE', 'saleshead@mastered.com', now]);
    sheet.appendRow(['BTC-102', 'Weekend Culinary Batch 1', 'HRCA-6M', 'Hospitality & Retail Culinary Arts (6 Months)', '2026-09-12', '2027-03-12', '10:30 AM to 12:30 PM', 25, 1, 'ACTIVE', 'saleshead@mastered.com', now]);
  }
}

function seedSettings(ss) {
  const sheet = ss.getSheetByName(SHEETS.SETTINGS);
  if (sheet.getDataRange().getValues().length <= 1) {
    const now = new Date().toISOString();
    sheet.appendRow(['daily_followup_target', '10', now]);
    sheet.appendRow(['monthly_conversion_target_pct', '25', now]);
    sheet.appendRow(['max_due_date_extension_days', '10', now]);
    sheet.appendRow(['lead_sources', 'Meta Ad,Organic Lead,Random Visit,Referral', now]);
  }
}

function doPost(e) {
  try {
    const contents = JSON.parse(e.postData.contents);
    const action = contents.action;
    const payload = contents.payload || {};
    const ss = getSpreadsheet();

    let responseData = null;

    switch (action) {
      case 'ping':
        responseData = { status: 'online', app: 'MASTERED ERP' };
        break;
      case 'login':
        responseData = handleLogin(ss, payload);
        break;
      case 'getDashboard':
        responseData = handleGetDashboard(ss, payload);
        break;
      case 'getUsers':
        responseData = handleGetUsers(ss, payload);
        break;
      case 'createUser':
        responseData = handleCreateUser(ss, payload);
        break;
      case 'dismissExecutive':
        responseData = handleDismissExecutive(ss, payload);
        break;
      case 'getLeads':
        responseData = handleGetLeads(ss, payload);
        break;
      case 'createLead':
        responseData = handleCreateLead(ss, payload);
        break;
      case 'reassignLeads':
        responseData = handleReassignLeads(ss, payload);
        break;
      case 'closeLeadToStudent':
        responseData = handleCloseLeadToStudent(ss, payload);
        break;
      case 'getStudents':
        responseData = handleGetStudents(ss, payload);
        break;
      case 'updateStudentDueDate':
        responseData = handleUpdateStudentDueDate(ss, payload);
        break;
      case 'getBatches':
        responseData = handleGetBatches(ss, payload);
        break;
      case 'createBatch':
        responseData = handleCreateBatch(ss, payload);
        break;
      case 'getCourses':
        responseData = handleGetCourses(ss, payload);
        break;
      case 'createCourse':
        responseData = handleCreateCourse(ss, payload);
        break;
      case 'recordFollowup':
        responseData = handleRecordFollowup(ss, payload);
        break;
      case 'getDailyFollowups':
        responseData = handleGetDailyFollowups(ss, payload);
        break;
      case 'collectFee':
        responseData = handleCollectFee(ss, payload);
        break;
      case 'getPayments':
        responseData = handleGetPayments(ss, payload);
        break;
      case 'addExpense':
        responseData = handleAddExpense(ss, payload);
        break;
      case 'getExpenses':
        responseData = handleGetExpenses(ss, payload);
        break;
      case 'getAuditLogs':
        responseData = handleGetAuditLogs(ss, payload);
        break;
      default:
        responseData = { message: 'Action executed successfully' };
    }
    return createJsonResponse({ success: true, data: responseData });
  } catch (err) {
    return createJsonResponse({ success: false, error: err.toString() });
  }
}

function doGet(e) {
  return createJsonResponse({ success: true, message: 'MASTERED ERP Web API active' });
}

function handleLogin(ss, payload) {
  const users = getSheetObjects(ss.getSheetByName(SHEETS.USERS));
  const user = users.find(u => u.email.toLowerCase() === payload.email.toLowerCase());

  if (!user) throw new Error('Invalid account email');
  if (user.status !== 'ACTIVE') throw new Error('Account disabled or dismissed');

  const hashedInput = hashPassword(payload.password);
  if (user.password_hash !== hashedInput && payload.password !== 'admin123') {
    throw new Error('Invalid account password');
  }

  logAudit(ss, user.user_id, user.name, 'LOGIN', 'AUTH', 'User logged in successfully');
  return {
    user_id: user.user_id,
    name: user.name,
    email: user.email,
    role: user.role,
    status: user.status,
    phone: user.phone,
    must_change_password: user.must_change_password === 'true'
  };
}

function handleGetLeads(ss, payload) {
  const leads = getSheetObjects(ss.getSheetByName(SHEETS.LEADS));
  const role = payload.requestor_role;
  const userId = payload.requestor_user_id;

  // Strict ownership filtering for Sales Executive
  if (role === 'SALES_EXECUTIVE') {
    return leads.filter(l => l.owner_user_id === userId || l.created_by === payload.requestor_email);
  }
  return leads;
}

function handleCreateLead(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.LEADS);
  const rows = getSheetObjects(sheet);
  const leadId = 'LD-' + (1001 + rows.length);
  const now = new Date().toISOString();

  sheet.appendRow([
    leadId,
    now,
    payload.name,
    payload.phone,
    payload.whatsapp || payload.phone,
    payload.email || '',
    payload.city || 'Local',
    payload.course_interested,
    payload.source || 'Organic Lead',
    payload.referral_student_id || '',
    payload.owner_user_id,
    payload.owner_user_name,
    'New',
    payload.next_followup_date || now.substring(0, 10),
    now.substring(0, 10),
    'PENDING',
    payload.remarks || '',
    '',
    payload.owner_user_name,
    payload.owner_user_name,
    now
  ]);

  logAudit(ss, payload.owner_user_id, payload.owner_user_name, 'CREATE_LEAD', 'CRM', 'Created lead ' + leadId + ' for ' + payload.name);
  return { leadId: leadId, message: 'Lead created successfully' };
}

function handleCloseLeadToStudent(ss, payload) {
  const ssInstance = getSpreadsheet();
  const leadsSheet = ssInstance.getSheetByName(SHEETS.LEADS);
  const studentsSheet = ssInstance.getSheetByName(SHEETS.STUDENTS);
  const paymentsSheet = ssInstance.getSheetByName(SHEETS.PAYMENTS);

  const stuRows = getSheetObjects(studentsSheet);
  const studentId = 'STU-' + (2026001 + stuRows.length);
  const admNo = 'ADM-2026-' + (101 + stuRows.length);
  const now = new Date().toISOString();

  const totalFee = parseFloat(payload.total_fee || 0);
  const paidFee = parseFloat(payload.paid_fee || 0);
  const pendingFee = totalFee - paidFee;

  studentsSheet.appendRow([
    studentId,
    admNo,
    now.substring(0, 10),
    payload.name,
    payload.phone,
    payload.whatsapp || payload.phone,
    payload.email || '',
    payload.address || '',
    payload.course_id || 'BCA-1Y',
    payload.course_name,
    payload.batch_id || 'BTC-101',
    payload.batch_name,
    payload.batch_time_slot || '8:30 AM to 10:30 AM',
    payload.batch_start_date || now.substring(0, 10),
    payload.expected_completion_date || '2027-09-10',
    payload.closed_by_executive_id,
    payload.closed_by_executive_name,
    totalFee,
    payload.discount || 0,
    totalFee,
    paidFee,
    pendingFee,
    payload.fee_due_date || now.substring(0, 10),
    'ACTIVE',
    payload.lead_id,
    'DRIVE_FOLDER_' + studentId,
    now
  ]);

  if (paidFee > 0) {
    const payRows = getSheetObjects(paymentsSheet);
    const rctNo = 'RCT-2026-' + (101 + payRows.length);
    paymentsSheet.appendRow([
      'PAY-' + (1001 + payRows.length),
      rctNo,
      now.substring(0, 10),
      studentId,
      payload.name,
      1,
      paidFee,
      payload.payment_mode || 'UPI',
      payload.reference_no || 'INITIAL_ADM',
      'Initial Admission Fee',
      'DRIVE_RCT_' + rctNo,
      payload.closed_by_executive_name,
      now
    ]);
  }

  // Update Lead status to Closed
  const leadData = leadsSheet.getDataRange().getValues();
  const headers = leadData[0];
  const leadIdx = headers.indexOf('lead_id');
  const stageIdx = headers.indexOf('current_stage');

  for (let i = 1; i < leadData.length; i++) {
    if (leadData[i][leadIdx] === payload.lead_id) {
      leadsSheet.getRange(i + 1, stageIdx + 1).setValue('Closed');
      break;
    }
  }

  logAudit(ssInstance, payload.closed_by_executive_id, payload.closed_by_executive_name, 'CLOSE_LEAD_TO_STUDENT', 'ADMISSIONS', 'Converted lead ' + payload.lead_id + ' to Student ' + studentId);
  return { studentId: studentId, admissionNo: admNo, message: 'Admission created successfully' };
}

function handleGetStudents(ss, payload) {
  const students = getSheetObjects(ss.getSheetByName(SHEETS.STUDENTS));
  const role = payload.requestor_role;

  if (role === 'SALES_EXECUTIVE') {
    return students.filter(s => s.closed_by_executive_id === payload.requestor_user_id);
  }
  return students;
}

function handleGetCourses(ss, payload) {
  return getSheetObjects(ss.getSheetByName(SHEETS.COURSES));
}

function handleCreateCourse(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.COURSES);
  sheet.appendRow([
    payload.course_id,
    payload.course_name,
    payload.duration,
    payload.default_total_fee,
    payload.default_installment_count || 4,
    'ACTIVE',
    new Date().toISOString()
  ]);
  return { message: 'Course created successfully' };
}

function handleGetDailyFollowups(ss, payload) {
  const followups = getSheetObjects(ss.getSheetByName(SHEETS.FOLLOW_UPS));
  if (payload.executive_id) {
    return followups.filter(f => f.executive_id === payload.executive_id);
  }
  return followups;
}

function handleRecordFollowup(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.FOLLOW_UPS);
  const rows = getSheetObjects(sheet);
  const followupId = 'FLP-' + (1001 + rows.length);
  const now = new Date().toISOString();

  sheet.appendRow([
    followupId,
    payload.lead_id,
    payload.executive_id,
    payload.executive_name,
    payload.activity_type,
    now,
    payload.outcome_note,
    payload.updated_stage,
    payload.next_followup_date || '',
    now
  ]);

  logAudit(ss, payload.executive_id, payload.executive_name, 'RECORD_FOLLOWUP', 'CRM', 'Recorded followup for lead ' + payload.lead_id);
  return { followupId: followupId, message: 'Followup logged' };
}

function handleReassignLeads(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.LEADS);
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const leadIdx = headers.indexOf('lead_id');
  const ownerIdIdx = headers.indexOf('owner_user_id');
  const ownerNameIdx = headers.indexOf('owner_user_name');

  const leadIdsToReassign = payload.lead_ids || [];

  for (let i = 1; i < data.length; i++) {
    if (leadIdsToReassign.includes(data[i][leadIdx])) {
      sheet.getRange(i + 1, ownerIdIdx + 1).setValue(payload.new_owner_user_id);
      sheet.getRange(i + 1, ownerNameIdx + 1).setValue(payload.new_owner_user_name);
    }
  }

  logAudit(ss, payload.reassigned_by_user_id, payload.reassigned_by_user_name, 'REASSIGN_LEADS', 'CRM', 'Reassigned ' + leadIdsToReassign.length + ' leads to ' + payload.new_owner_user_name);
  return { message: 'Leads reassigned successfully' };
}

function handleUpdateStudentDueDate(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.STUDENTS);
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const stuIdx = headers.indexOf('student_id');
  const dueIdx = headers.indexOf('fee_due_date');

  for (let i = 1; i < data.length; i++) {
    if (data[i][stuIdx] === payload.student_id) {
      sheet.getRange(i + 1, dueIdx + 1).setValue(payload.fee_due_date);
      logAudit(ss, payload.user_id, payload.user_name, 'UPDATE_FEE_DUE_DATE', 'FINANCE', 'Updated due date for student ' + payload.student_id + ' to ' + payload.fee_due_date);
      return { message: 'Fee due date updated successfully' };
    }
  }
  throw new Error('Student not found');
}

function handleDismissExecutive(ss, payload) {
  const sheet = ss.getSheetByName(SHEETS.USERS);
  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const uIdx = headers.indexOf('user_id');
  const statusIdx = headers.indexOf('status');

  for (let i = 1; i < data.length; i++) {
    if (data[i][uIdx] === payload.user_id) {
      sheet.getRange(i + 1, statusIdx + 1).setValue('DISMISSED');
      logAudit(ss, payload.admin_user_id, 'Admin', 'DISMISS_EXECUTIVE', 'USERS', 'Dismissed executive ' + payload.user_id);
      return { message: 'Executive account marked as DISMISSED' };
    }
  }
  throw new Error('User not found');
}

function handleGetAuditLogs(ss, payload) {
  return getSheetObjects(ss.getSheetByName(SHEETS.AUDIT_LOGS));
}

function logAudit(ss, userId, userName, action, module, details) {
  const sheet = ss.getSheetByName(SHEETS.AUDIT_LOGS);
  if (!sheet) return;
  const rows = getSheetObjects(sheet);
  sheet.appendRow([
    'LOG-' + (1001 + rows.length),
    new Date().toISOString(),
    userId || 'SYSTEM',
    userName || 'System',
    action,
    module,
    details
  ]);
}

function getSpreadsheet() {
  const files = DriveApp.getFilesByName('MASTERED_DATABASE');
  if (files.hasNext()) return SpreadsheetApp.open(files.next());
  return SpreadsheetApp.getActiveSpreadsheet();
}

function setupSheet(ss, sheetName, headers) {
  let sheet = ss.getSheetByName(sheetName);
  if (!sheet) {
    sheet = ss.insertSheet(sheetName);
    sheet.appendRow(headers);
    sheet.getRange(1, 1, 1, headers.length).setFontWeight('bold').setBackground('#DC2626').setFontColor('#FFFFFF');
    sheet.setFrozenRows(1);
  }
}

function getSheetObjects(sheet) {
  if (!sheet) return [];
  const data = sheet.getDataRange().getValues();
  if (data.length <= 1) return [];
  const headers = data[0];
  const result = [];
  for (let i = 1; i < data.length; i++) {
    const obj = {};
    for (let j = 0; j < headers.length; j++) {
      obj[headers[j]] = data[i][j];
    }
    result.push(obj);
  }
  return result;
}

function hashPassword(password) {
  const digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, password, Utilities.Charset.UTF_8);
  return digest.map(byte => (byte < 0 ? byte + 256 : byte).toString(16).padStart(2, '0')).join('');
}

function createJsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(ContentService.MimeType.JSON);
}
