import 'package:flutter/material.dart';
import '../data/services/gas_api_service.dart';
import '../data/services/local_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  String _gasUrl = '';
  bool _isTestingConnection = false;
  String? _connectionStatus;

  String get gasUrl => _gasUrl;
  bool get isTestingConnection => _isTestingConnection;
  String? get connectionStatus => _connectionStatus;

  SettingsProvider() {
    _gasUrl = LocalStorageService.getGasUrl();
  }

  Future<void> saveGasUrl(String url) async {
    _gasUrl = url.trim();
    await LocalStorageService.saveGasUrl(_gasUrl);
    notifyListeners();
  }

  Future<bool> testConnection() async {
    _isTestingConnection = true;
    _connectionStatus = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('ping', {});
      if (res != null) {
        _connectionStatus = 'Successfully connected to Google Apps Script Web API!';
        _isTestingConnection = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _connectionStatus = 'Connection failed: ${e.toString()}';
    }

    _isTestingConnection = false;
    notifyListeners();
    return false;
  }
}
