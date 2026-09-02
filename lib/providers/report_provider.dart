import 'package:flutter/material.dart';
import '../data/services/gas_api_service.dart';

class ReportProvider extends ChangeNotifier {
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get reportData => _reportData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('getReports', {});
      if (res is Map<String, dynamic>) {
        _reportData = res;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }
}
