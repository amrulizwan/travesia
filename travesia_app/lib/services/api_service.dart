// Base API Service
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change the base URL to match your backend server
  final String _baseUrl =
      "https://v2.aisadev.id/api"; // Or your actual server URL
  String? _token;

  void setAuthToken(String token) {
    _token = token;
  }

  void clearAuthToken() {
    _token = null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      // Use the stored token from the service instead of passing it as parameter
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final String responseBody = response.body;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) {
        return null; // Or appropriate response for empty success body, like {} or true
      }
      return jsonDecode(responseBody);
    } else {
      String errorMessage = 'Error: ${response.statusCode}';
      if (responseBody.isNotEmpty) {
        try {
          final decodedError = jsonDecode(responseBody);
          if (decodedError is Map && decodedError.containsKey('message')) {
            errorMessage = decodedError['message'] is List
                ? (decodedError['message'] as List).join(', ')
                : decodedError['message'];
          } else if (decodedError is Map && decodedError.containsKey('error')) {
            // Common alternative key
            errorMessage = decodedError['error'] is List
                ? (decodedError['error'] as List).join(', ')
                : decodedError['error'];
          } else {
            // If not a map or no 'message' key, use raw body if it's not too large
            errorMessage =
                responseBody.length < 200 ? responseBody : errorMessage;
          }
        } catch (e) {
          // If decoding fails, use raw body if it's not too large, otherwise default status code error
          errorMessage = responseBody.length < 200
              ? responseBody
              : 'Error: ${response.statusCode} - Non-JSON error response';
        }
      } else {
        errorMessage = 'Error: ${response.statusCode} - Empty error response';
      }
      // Prepending with status code for clarity in service layer if needed
      throw Exception('${response.statusCode}: $errorMessage');
    }
  }

  // Assuming _handleError is a method to handle errors from Dio
  Exception _handleError(dynamic error) {
    // Implement error handling logic here
    return Exception('An error occurred: $error');
  }
}
