import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/gas_api_service.dart';
import '../data/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    _currentUser = LocalStorageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('login', {
        'email': email,
        'password': password,
      });

      if (res != null && res['user'] != null) {
        _currentUser = UserModel.fromJson(res['user']);
        await LocalStorageService.saveUser(_currentUser!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid login credentials';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    await LocalStorageService.clearSession();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
