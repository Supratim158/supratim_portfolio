import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Service class for communicating with the contact endpoint in the backend.
class ContactService {
  final String _baseUrl = AppConstants.apiBaseUrl;

  /// POST /api/contact
  /// Sends name, email, and message to backend for email dispatching.
  Future<void> sendMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${AppConstants.contactEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      final Map<String, dynamic> errorBody;
      try {
        errorBody = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Failed to send message: Server returned code ${response.statusCode}');
      }
      // The error field can be a string or a nested object (e.g. from Brevo),
      // so we safely convert it to a readable string.
      final dynamic rawError = errorBody['error'];
      final String errorMessage;
      if (rawError is String) {
        errorMessage = rawError;
      } else if (rawError is Map) {
        errorMessage = rawError['message']?.toString() ?? 'Failed to send message';
      } else {
        errorMessage = 'Failed to send message: Unknown error';
      }
      throw Exception(errorMessage);
    }
  }
}
