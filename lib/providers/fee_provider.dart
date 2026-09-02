import 'package:flutter/material.dart';
import '../data/models/student_model.dart';
import '../data/models/payment_model.dart';
import '../data/models/user_model.dart';
import '../data/services/gas_api_service.dart';

class FeeProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<StudentModel> get students => _filteredStudents();
  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  double get todayCollection {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _payments
        .where((p) => p.date.startsWith(today))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get monthlyCollection {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _payments
        .where((p) => p.date.startsWith(month))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get totalPendingFees {
    return _students.fold(0.0, (sum, s) => sum + s.balanceFee);
  }

  List<StudentModel> _filteredStudents() {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          s.admissionNo.toLowerCase().contains(q) ||
          s.studentId.toLowerCase().contains(q);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchStudentsAndPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resStudents = await GasApiService().post('getStudents', {});
      final resPayments = await GasApiService().post('getPayments', {});

      if (resStudents is List) {
        _students = resStudents.map((s) => StudentModel.fromJson(s)).toList();
      }
      if (resPayments is List) {
        _payments = resPayments.map((p) => PaymentModel.fromJson(p)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<PaymentModel?> collectFee({
    required StudentModel student,
    required double amount,
    required String paymentMode,
    required String remarks,
    required UserModel currentUser,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('collectFee', {
        'student_id': student.studentId,
        'student_name': student.name,
        'amount': amount,
        'payment_mode': paymentMode,
        'remarks': remarks,
        'created_by': currentUser.email,
      });

      await fetchStudentsAndPayments();

      if (res != null && res['receiptNo'] != null) {
        return _payments.firstWhere(
          (p) => p.receiptNo == res['receiptNo'],
          orElse: () => PaymentModel(
            paymentId: res['paymentId'] ?? 'PAY-00',
            receiptNo: res['receiptNo'] ?? 'RCT-00',
            date: DateTime.now().toIso8601String().substring(0, 10),
            studentId: student.studentId,
            studentName: student.name,
            amount: amount,
            paymentMode: paymentMode,
            remarks: remarks,
            driveFileId: '',
            createdBy: currentUser.email,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
