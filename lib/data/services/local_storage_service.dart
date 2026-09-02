import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUser(UserModel user) async {
    if (_prefs == null) await init();
    await _prefs!.setString(AppConstants.prefsUserKey, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    if (_prefs == null) return null;
    final str = _prefs!.getString(AppConstants.prefsUserKey);
    if (str == null || str.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(str));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    if (_prefs == null) await init();
    await _prefs!.remove(AppConstants.prefsUserKey);
    await _prefs!.remove(AppConstants.prefsTokenKey);
  }

  static Future<void> saveGasUrl(String url) async {
    if (_prefs == null) await init();
    await _prefs!.setString(AppConstants.prefsGasUrlKey, url);
  }

  static String getGasUrl() {
    if (_prefs == null) return AppConstants.defaultGasApiUrl;
    return _prefs!.getString(AppConstants.prefsGasUrlKey) ?? AppConstants.defaultGasApiUrl;
  }
}
