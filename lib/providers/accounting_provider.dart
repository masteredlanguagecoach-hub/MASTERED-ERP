import 'package:flutter/material.dart';
import '../data/models/expense_model.dart';
import '../data/models/payment_model.dart';
import '../data/models/user_model.dart';
import '../data/services/gas_api_service.dart';

class AccountingProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get todayIncome {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _payments
        .where((p) => p.date.startsWith(today))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get monthlyIncome {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _payments
        .where((p) => p.date.startsWith(month))
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  double get todayExpense {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return _expenses
        .where((e) => e.date.startsWith(today))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get monthlyExpense {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _expenses
        .where((e) => e.date.startsWith(month))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get netProfit {
    return monthlyIncome - monthlyExpense;
  }

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (final exp in _expenses) {
      map[exp.category] = (map[exp.category] ?? 0) + exp.amount;
    }
    return map;
  }

  Future<void> fetchAccountingData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final resExp = await GasApiService().post('getExpenses', {});
      final resPay = await GasApiService().post('getPayments', {});

      if (resExp is List) {
        _expenses = resExp.map((e) => ExpenseModel.fromJson(e)).toList();
      }
      if (resPay is List) {
        _payments = resPay.map((p) => PaymentModel.fromJson(p)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExpense({
    required String category,
    required String description,
    required double amount,
    required String paymentMode,
    required UserModel currentUser,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await GasApiService().post('addExpense', {
        'category': category,
        'description': description,
        'amount': amount,
        'payment_mode': paymentMode,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'created_by': currentUser.email,
      });

      await fetchAccountingData();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
