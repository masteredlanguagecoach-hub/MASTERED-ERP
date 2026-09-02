import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class GasApiService {
  static String? _activeSessionToken;

  static void setSessionToken(String? token) {
    _activeSessionToken = token;
  }

  static String? get activeSessionToken => _activeSessionToken;

  static Future<Map<String, dynamic>> post(String action, Map<String, dynamic> payload) async {
    final url = Uri.parse(AppConstants.gasApiEndpoint);

    // Attach active session token for server-side auth validation
    final body = {
      'action': action,
      'sessionToken': _activeSessionToken,
      'payload': payload,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return {'success': false, 'error': 'Server HTTP error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
