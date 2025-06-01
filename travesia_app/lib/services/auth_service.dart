import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart'; // Ensure this path is correct
import '../models/user.dart'; // Ensure this path is correct

class AuthService {
  final SharedPreferences _prefs;
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token';
  final String _userKey = 'auth_user';

  // Private constructor
  AuthService._(this._prefs) : _apiService = ApiService();

  // Static init method
  static Future<AuthService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService._(prefs);
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(String nama, String email,
      String password, String telepon, String role) async {
    try {
      final response = await _apiService.post('auth/register', {
        'nama': nama,
        'email': email,
        'password': password,
        'telepon': telepon,
        'role': role,
      });

      // Assuming the API returns user and token upon successful registration
      if (response != null &&
          response['token'] != null &&
          response['user'] != null) {
        await _saveAuthData(response['token'], response['user']);
        _apiService.setAuthToken(response['token']);
        return {
          'success': true,
          'user': User.fromJson(response['user']),
          'token': response['token']
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ??
              'Registration failed: No token or user data in response'
        };
      }
    } catch (e) {
      String rawMessage = e.toString();
      // Remove "Exception: " prefix if present
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }

      // Attempt to parse status code if ApiService includes it like "STATUS_CODE: message"
      String userFriendlyMessage = 'Registrasi gagal: Terjadi kesalahan.';
      List<String> parts = rawMessage.splitN(
          ': ', 2); // Split only on the first occurrence of ': '
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];

        if (statusCode == '400') {
          // Bad Request
          userFriendlyMessage =
              'Registrasi gagal: $apiMessage'; // e.g. Email sudah terdaftar
        } else if (statusCode == '409') {
          // Conflict (custom, or could be 400)
          userFriendlyMessage =
              'Registrasi gagal: $apiMessage'; // e.g. Email already exists
        }
        // Add more specific status code handling if needed
        else {
          userFriendlyMessage = 'Registrasi gagal: $apiMessage';
        }
      } else {
        // If not in "STATUS_CODE: message" format, use the raw message (already cleaned of "Exception: ")
        userFriendlyMessage = 'Registrasi gagal: $rawMessage';
      }
      return {'success': false, 'message': userFriendlyMessage};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null &&
          response['token'] != null &&
          response['user'] != null) {
        await _saveAuthData(response['token'], response['user']);
        _apiService.setAuthToken(response['token']);
        return {
          'success': true,
          'user': User.fromJson(response['user']),
          'token': response['token']
        };
      } else {
        // Handle cases where response might be missing token/user or have an error message
        return {
          'success': false,
          'message': response['message'] ??
              'Login failed: Invalid response from server'
        };
      }
    } catch (e) {
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }

      String userFriendlyMessage = 'Login gagal: Terjadi kesalahan.';
      List<String> parts = rawMessage.splitN(': ', 2);
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];

        if (statusCode == '401') {
          // Unauthorized
          userFriendlyMessage = 'Login gagal: Email atau password salah.';
        } else if (statusCode == '400') {
          // Bad Request
          userFriendlyMessage =
              'Login gagal: $apiMessage'; // e.g. "Email is required"
        }
        // Add more specific status code handling if needed
        else {
          userFriendlyMessage = 'Login gagal: $apiMessage';
        }
      } else {
        userFriendlyMessage = 'Login gagal: $rawMessage';
      }
      return {'success': false, 'message': userFriendlyMessage};
    }
  }

  Future<void> _saveAuthData(
      String token, Map<String, dynamic> userData) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userKey, value: jsonEncode(userData));
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<User?> getUser() async {
    final userDataString = await _secureStorage.read(key: _userKey);
    if (userDataString != null) {
      try {
        return User.fromJson(jsonDecode(userDataString));
      } catch (e) {
        // If there's an error decoding user (e.g. old format), remove it.
        await _secureStorage.delete(key: _userKey);
        return null;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    _apiService.clearAuthToken();
    await _prefs.remove('token');
    // Add any other cleanup needed
  }

  Future<bool> isLoggedIn() async {
    final token = _prefs.getString('token');
    if (token != null) {
      // Optionally: verify token with a lightweight backend call if needed.
      // For now, just having a token means logged in.
      _apiService
          .setAuthToken(token); // Make sure ApiService is aware of the token.

      // Attempt to load user data. If it fails (e.g., corrupted data),
      // consider it as not properly logged in, clear storage and return false.
      User? user = await getUser();
      if (user == null) {
        // Token exists but no valid user data, likely an inconsistent state or data corruption.
        await logout(); // Log out to clear inconsistent state.
        return false;
      }
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await getToken(); // Use the getToken method we already have
      if (token == null) return null;

      _apiService.setAuthToken(token); // Set the token in ApiService
      final response = await _apiService.get('/user/profile');

      if (response != null) {
        return response;
      } else {
        await logout(); // Token expired or invalid
        return null;
      }
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }

  Future<Map<String, dynamic>> requestResetPassword(String email) async {
    try {
      final response = await _apiService.post('auth/forgot-password', {
        'email': email,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'OTP sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verifyResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('auth/reset-password', {
        'email': email,
        'otp': otp,
        'password': newPassword,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

extension StringExtensions on String {
  List<String> splitN(Pattern pattern, int n) {
    var parts = <String>[];
    var current = 0;
    for (var i = 0; i < n - 1; i++) {
      var index = indexOf(pattern, current);
      if (index == -1) {
        break;
      }
      parts.add(substring(current, index));
      current = index + pattern.matchAsPrefix(this, index)!.group(0)!.length;
    }
    parts.add(substring(current));
    return parts;
  }
}
