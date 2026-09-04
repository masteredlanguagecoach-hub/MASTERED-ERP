import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String appsScriptUrl = 'https://script.google.com/macros/s/AKfycbyGgVKXlTALRo9WMIPVpEXd7d6es9hhCG6XnTbZw_i1cx29yZQM_ulY-C8rbX8pL2zvdQ/exec';

  static Future<Map<String, dynamic>> postAction({
    required String action,
    required String sessionToken,
    required Map<String, dynamic> payload,
  }) async {
    final String requestId = 'REQ-${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> body = {
      'action': action,
      'sessionToken': sessionToken,
      'requestId': requestId,
      'payload': payload,
    };

    try {
      final response = await http.post(
        Uri.parse(appsScriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'errorCode': 'HTTP_${response.statusCode}',
          'message': 'Server responded with status code ${response.statusCode}',
          'requestId': requestId,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'errorCode': 'NETWORK_ERROR',
        'message': e.toString(),
        'requestId': requestId,
      };
    }
  }
}
