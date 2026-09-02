import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/lead_model.dart';
import '../models/student_model.dart';
import '../models/payment_model.dart';
import '../models/expense_model.dart';
import '../models/dashboard_stats_model.dart';
import 'local_storage_service.dart';

class GasApiService {
  static final GasApiService _instance = GasApiService._internal();
  factory GasApiService() => _instance;
  GasApiService._internal();

  // In-Memory Mock Store for Demo Mode when no live Apps Script URL is set
  final Map<String, dynamic> _mockStore = {
    'users': [
      UserModel(userId: 'USR-1001', name: 'System Admin', email: 'admin@mastered.com', role: AppConstants.roleAdmin, status: 'ACTIVE', phone: '+91 9876543210', createdAt: '2026-01-01'),
      UserModel(userId: 'USR-1002', name: 'Executive Officer', email: 'ceo@mastered.com', role: AppConstants.roleCeo, status: 'ACTIVE', phone: '+91 9876543211', createdAt: '2026-01-01'),
      UserModel(userId: 'USR-1003', name: 'Rahul Sharma', email: 'saleshead@mastered.com', role: AppConstants.roleSalesHead, status: 'ACTIVE', phone: '+91 9876543212', createdAt: '2026-01-02'),
      UserModel(userId: 'USR-1004', name: 'Priya Verma', email: 'salesexec@mastered.com', role: AppConstants.roleSalesExecutive, status: 'ACTIVE', phone: '+91 9876543213', createdAt: '2026-01-05'),
      UserModel(userId: 'USR-1005', name: 'Vikram Singh', email: 'ops@mastered.com', role: AppConstants.roleOperations, status: 'ACTIVE', phone: '+91 9876543214', createdAt: '2026-01-10'),
    ],
    'leads': [
      LeadModel(leadId: 'LD-1001', date: '2026-09-01', name: 'Aarav Patel', phone: '9898989801', whatsapp: '9898989801', email: 'aarav@gmail.com', city: 'Mumbai', courseInterested: 'Full Stack Development', source: 'Google Ads', assignedTo: 'Priya Verma', status: 'Interested', nextFollowup: '2026-09-04', remarks: 'Requires weekend batch demo', createdBy: 'salesexec@mastered.com', updatedAt: '2026-09-01'),
      LeadModel(leadId: 'LD-1002', date: '2026-09-01', name: 'Ananya Roy', phone: '9898989802', whatsapp: '9898989802', email: 'ananya@gmail.com', city: 'Bangalore', courseInterested: 'Data Science & AI', source: 'Website', assignedTo: 'Priya Verma', status: 'Demo', nextFollowup: '2026-09-03', remarks: 'Attended live demo session', createdBy: 'salesexec@mastered.com', updatedAt: '2026-09-02'),
      LeadModel(leadId: 'LD-1003', date: '2026-08-28', name: 'Rohan Mehta', phone: '9898989803', whatsapp: '9898989803', email: 'rohan@gmail.com', city: 'Delhi', courseInterested: 'UI/UX Masterclass', source: 'Referral', assignedTo: 'Rahul Sharma', status: 'Converted', nextFollowup: '', remarks: 'Converted to student ADM-2026-001', createdBy: 'saleshead@mastered.com', updatedAt: '2026-08-30'),
      LeadModel(leadId: 'LD-1004', date: '2026-08-25', name: 'Sneha Kapoor', phone: '9898989804', whatsapp: '9898989804', email: 'sneha@gmail.com', city: 'Pune', courseInterested: 'Cyber Security', source: 'Social Media', assignedTo: 'Priya Verma', status: 'Follow-up', nextFollowup: '2026-09-05', remarks: 'Discussing EMI payment options', createdBy: 'salesexec@mastered.com', updatedAt: '2026-08-29'),
    ],
    'students': [
      StudentModel(studentId: 'STU-1001', admissionNo: 'ADM-2026-001', admissionDate: '2026-08-30', name: 'Rohan Mehta', phone: '9898989803', email: 'rohan@gmail.com', course: 'UI/UX Masterclass', totalFee: 45000, paidFee: 30000, balanceFee: 15000, status: 'ACTIVE', driveFolderId: 'folder_stu_1001', leadId: 'LD-1003', createdAt: '2026-08-30'),
      StudentModel(studentId: 'STU-1002', admissionNo: 'ADM-2026-002', admissionDate: '2026-08-15', name: 'Kavya Nair', phone: '9898989805', email: 'kavya@gmail.com', course: 'Full Stack Development', totalFee: 60000, paidFee: 60000, balanceFee: 0, status: 'ACTIVE', driveFolderId: 'folder_stu_1002', leadId: '', createdAt: '2026-08-15'),
      StudentModel(studentId: 'STU-1003', admissionNo: 'ADM-2026-003', admissionDate: '2026-07-10', name: 'Devendra Gupta', phone: '9898989806', email: 'devendra@gmail.com', course: 'Data Science & AI', totalFee: 75000, paidFee: 40000, balanceFee: 35000, status: 'ACTIVE', driveFolderId: 'folder_stu_1003', leadId: '', createdAt: '2026-07-10'),
    ],
    'payments': [
      PaymentModel(paymentId: 'PAY-1001', receiptNo: 'RCT-2026-101', date: '2026-09-01', studentId: 'STU-1001', studentName: 'Rohan Mehta', amount: 15000, paymentMode: 'UPI', remarks: 'Second Installment', driveFileId: 'file_rct_101', createdBy: 'ops@mastered.com', createdAt: '2026-09-01'),
      PaymentModel(paymentId: 'PAY-1002', receiptNo: 'RCT-2026-100', date: '2026-08-30', studentId: 'STU-1001', studentName: 'Rohan Mehta', amount: 15000, paymentMode: 'Bank Transfer', remarks: 'Admission Down Payment', driveFileId: 'file_rct_100', createdBy: 'ops@mastered.com', createdAt: '2026-08-30'),
      PaymentModel(paymentId: 'PAY-1003', receiptNo: 'RCT-2026-099', date: '2026-08-15', studentId: 'STU-1002', studentName: 'Kavya Nair', amount: 60000, paymentMode: 'Razorpay', remarks: 'Full Fee Payment', driveFileId: 'file_rct_099', createdBy: 'ops@mastered.com', createdAt: '2026-08-15'),
    ],
    'expenses': [
      ExpenseModel(expenseId: 'EXP-1001', date: '2026-09-01', category: 'Marketing', description: 'Google Ads Monthly Campaign', amount: 25000, paymentMode: 'Bank Transfer', billDriveFileId: 'bill_001', createdBy: 'admin@mastered.com', createdAt: '2026-09-01'),
      ExpenseModel(expenseId: 'EXP-1002', date: '2026-08-30', category: 'Rent', description: 'Main Campus Building Rent', amount: 40000, paymentMode: 'Bank Transfer', billDriveFileId: 'bill_002', createdBy: 'admin@mastered.com', createdAt: '2026-08-30'),
      ExpenseModel(expenseId: 'EXP-1003', date: '2026-08-25', category: 'Electricity', description: 'Monthly Electricity Bill', amount: 6500, paymentMode: 'UPI', billDriveFileId: 'bill_003', createdBy: 'ops@mastered.com', createdAt: '2026-08-25'),
    ]
  };

  /// Main HTTP execution router
  Future<dynamic> post(String action, Map<String, dynamic> payload) async {
    final url = LocalStorageService.getGasUrl();

    if (url.isNotEmpty && url.startsWith('http')) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'action': action, 'payload': payload}),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          if (resData['success'] == true) {
            return resData['data'];
          } else {
            throw Exception(resData['error'] ?? 'API error');
          }
        }
      } catch (e) {
        // Fallback to local mock if remote request fails or times out
      }
    }

    // Interactive In-Memory Fallback Router
    return _handleMockAction(action, payload);
  }

  dynamic _handleMockAction(String action, Map<String, dynamic> payload) {
    switch (action) {
      case 'login':
        final email = (payload['email'] ?? '').toString().trim().toLowerCase();
        final password = (payload['password'] ?? '').toString();
        final users = _mockStore['users'] as List<UserModel>;

        final user = users.firstWhere(
          (u) => u.email.toLowerCase() == email,
          orElse: () {
            // Default demo login fallback for convenient testing
            if (email.contains('admin')) {
              return users[0];
            } else if (email.contains('ceo')) {
              return users[1];
            } else if (email.contains('head')) {
              return users[2];
            } else if (email.contains('ops')) {
              return users[4];
            }
            return users[3]; // Sales executive default
          },
        );
        return {'user': user.toJson(), 'token': 'mock_token_${Date.now()}'};

      case 'getDashboard':
        final leads = _mockStore['leads'] as List<LeadModel>;
        final students = _mockStore['students'] as List<StudentModel>;
        final payments = _mockStore['payments'] as List<PaymentModel>;
        final expenses = _mockStore['expenses'] as List<ExpenseModel>;

        final totalLeads = leads.length;
        final converted = leads.where((l) => l.status == 'Converted').length;
        final todayColl = payments.fold<double>(0, (sum, p) => sum + p.amount);
        final todayExp = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        final pending = students.fold<double>(0, (sum, s) => sum + s.balanceFee);

        return {
          'todayLeads': 2,
          'totalLeads': totalLeads,
          'todayCollection': todayColl,
          'monthlyCollection': todayColl + 75000,
          'totalPendingFees': pending,
          'todayExpenses': todayExp,
          'monthlyExpenses': todayExp + 30000,
          'activeStudents': students.length,
          'newAdmissions': 1,
          'conversionPercentage': totalLeads > 0 ? (converted / totalLeads) * 100 : 0.0,
          'recentPayments': payments.map((p) => p.toJson()).toList(),
          'recentLeads': leads.map((l) => l.toJson()).toList(),
        };

      case 'getUsers':
        return (_mockStore['users'] as List<UserModel>).map((u) => u.toJson()).toList();

      case 'createUser':
        final users = _mockStore['users'] as List<UserModel>;
        final newId = 'USR-${1000 + users.length + 1}';
        final newUser = UserModel(
          userId: newId,
          name: payload['name'] ?? 'New User',
          email: payload['email'] ?? '',
          role: payload['role'] ?? AppConstants.roleSalesExecutive,
          status: 'ACTIVE',
          phone: payload['phone'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
        );
        users.add(newUser);
        return {'userId': newId, 'message': 'User created'};

      case 'getLeads':
        return (_mockStore['leads'] as List<LeadModel>).map((l) => l.toJson()).toList();

      case 'createLead':
        final leads = _mockStore['leads'] as List<LeadModel>;
        final newId = 'LD-${1000 + leads.length + 1}';
        final newLead = LeadModel(
          leadId: newId,
          date: DateTime.now().toIso8601String().substring(0, 10),
          name: payload['name'] ?? '',
          phone: payload['phone'] ?? '',
          whatsapp: payload['whatsapp'] ?? payload['phone'] ?? '',
          email: payload['email'] ?? '',
          city: payload['city'] ?? '',
          courseInterested: payload['course_interested'] ?? '',
          source: payload['source'] ?? 'Direct',
          assignedTo: payload['assigned_to'] ?? 'Unassigned',
          status: 'New',
          nextFollowup: payload['next_followup'] ?? '',
          remarks: payload['remarks'] ?? '',
          createdBy: payload['created_by'] ?? 'System',
          updatedAt: DateTime.now().toIso8601String(),
        );
        leads.insert(0, newLead);
        return {'leadId': newId, 'message': 'Lead created'};

      case 'convertLead':
        final leadId = payload['lead_id'];
        final leads = _mockStore['leads'] as List<LeadModel>;
        final idx = leads.indexWhere((l) => l.leadId == leadId);
        if (idx != -1) {
          final old = leads[idx];
          leads[idx] = LeadModel(
            leadId: old.leadId,
            date: old.date,
            name: old.name,
            phone: old.phone,
            whatsapp: old.whatsapp,
            email: old.email,
            city: old.city,
            courseInterested: old.courseInterested,
            source: old.source,
            assignedTo: old.assignedTo,
            status: 'Converted',
            nextFollowup: old.nextFollowup,
            remarks: old.remarks,
            createdBy: old.createdBy,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }
        return post('createStudent', {
          'name': payload['name'] ?? 'Converted Student',
          'phone': payload['phone'] ?? '',
          'email': payload['email'] ?? '',
          'course': payload['course'] ?? 'Master Course',
          'total_fee': payload['total_fee'] ?? 50000,
          'paid_fee': payload['paid_fee'] ?? 0,
          'lead_id': leadId,
        });

      case 'getStudents':
      case 'searchStudent':
        return (_mockStore['students'] as List<StudentModel>).map((s) => s.toJson()).toList();

      case 'createStudent':
        final students = _mockStore['students'] as List<StudentModel>;
        final newId = 'STU-${1000 + students.length + 1}';
        final admNo = 'ADM-2026-${100 + students.length + 1}';
        final totalFee = (payload['total_fee'] ?? 50000).toDouble();
        final paidFee = (payload['paid_fee'] ?? 0).toDouble();
        final newStudent = StudentModel(
          studentId: newId,
          admissionNo: admNo,
          admissionDate: DateTime.now().toIso8601String().substring(0, 10),
          name: payload['name'] ?? '',
          phone: payload['phone'] ?? '',
          email: payload['email'] ?? '',
          course: payload['course'] ?? '',
          totalFee: totalFee,
          paidFee: paidFee,
          balanceFee: totalFee - paidFee,
          status: 'ACTIVE',
          driveFolderId: 'drive_folder_$newId',
          leadId: payload['lead_id'] ?? '',
          createdAt: DateTime.now().toIso8601String(),
        );
        students.insert(0, newStudent);
        return {'studentId': newId, 'admissionNo': admNo, 'message': 'Student created'};

      case 'collectFee':
        final studentId = payload['student_id'];
        final amount = (payload['amount'] ?? 0).toDouble();
        final students = _mockStore['students'] as List<StudentModel>;
        final idx = students.indexWhere((s) => s.studentId == studentId);
        if (idx != -1) {
          final s = students[idx];
          final newPaid = s.paidFee + amount;
          students[idx] = StudentModel(
            studentId: s.studentId,
            admissionNo: s.admissionNo,
            admissionDate: s.admissionDate,
            name: s.name,
            phone: s.phone,
            email: s.email,
            course: s.course,
            totalFee: s.totalFee,
            paidFee: newPaid,
            balanceFee: s.totalFee - newPaid,
            status: s.status,
            driveFolderId: s.driveFolderId,
            leadId: s.leadId,
            createdAt: s.createdAt,
          );
        }

        final payments = _mockStore['payments'] as List<PaymentModel>;
        final payId = 'PAY-${1000 + payments.length + 1}';
        final rctNo = 'RCT-2026-${100 + payments.length + 1}';
        final newPayment = PaymentModel(
          paymentId: payId,
          receiptNo: rctNo,
          date: DateTime.now().toIso8601String().substring(0, 10),
          studentId: studentId,
          studentName: payload['student_name'] ?? '',
          amount: amount,
          paymentMode: payload['payment_mode'] ?? 'Cash',
          remarks: payload['remarks'] ?? 'Fee Payment',
          driveFileId: 'rct_file_$rctNo',
          createdBy: payload['created_by'] ?? 'Ops',
          createdAt: DateTime.now().toIso8601String(),
        );
        payments.insert(0, newPayment);
        return {'paymentId': payId, 'receiptNo': rctNo, 'message': 'Payment recorded'};

      case 'getPayments':
        return (_mockStore['payments'] as List<PaymentModel>).map((p) => p.toJson()).toList();

      case 'addExpense':
        final expenses = _mockStore['expenses'] as List<ExpenseModel>;
        final expId = 'EXP-${1000 + expenses.length + 1}';
        final newExp = ExpenseModel(
          expenseId: expId,
          date: payload['date'] ?? DateTime.now().toIso8601String().substring(0, 10),
          category: payload['category'] ?? 'Other',
          description: payload['description'] ?? '',
          amount: (payload['amount'] ?? 0).toDouble(),
          paymentMode: payload['payment_mode'] ?? 'Cash',
          billDriveFileId: 'bill_drive_$expId',
          createdBy: payload['created_by'] ?? 'Admin',
          createdAt: DateTime.now().toIso8601String(),
        );
        expenses.insert(0, newExp);
        return {'expenseId': expId, 'message': 'Expense recorded'};

      case 'getExpenses':
        return (_mockStore['expenses'] as List<ExpenseModel>).map((e) => e.toJson()).toList();

      case 'getReports':
        final payments = _mockStore['payments'] as List<PaymentModel>;
        final expenses = _mockStore['expenses'] as List<ExpenseModel>;
        final income = payments.fold<double>(0, (sum, p) => sum + p.amount);
        final expense = expenses.fold<double>(0, (sum, e) => sum + e.amount);
        return {
          'totalIncome': income,
          'totalExpense': expense,
          'netProfit': income - expense,
          'expenseByCategory': {'Marketing': 25000, 'Rent': 40000, 'Electricity': 6500},
          'leadByStatus': {'New': 5, 'Contacted': 3, 'Interested': 2, 'Converted': 4, 'Lost': 1},
        };

      default:
        return {'message': 'Action $action processed in mock mode'};
    }
  }
}
