import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/gas_api_service.dart';

class UserProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('getUsers', {});
      if (res is List) {
        _users = res.map((u) => UserModel.fromJson(u)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await GasApiService().post('createUser', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'status': 'ACTIVE',
      });
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await GasApiService().post('updateUser', userData);
      await fetchUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(UserModel user) async {
    final newStatus = user.status == 'ACTIVE' ? 'DISABLED' : 'ACTIVE';
    return updateUser({'user_id': user.userId, 'status': newStatus});
  }

  Future<bool> resetPassword(String userId, String newPassword) async {
    return updateUser({'user_id': userId, 'password': newPassword});
  }
}
