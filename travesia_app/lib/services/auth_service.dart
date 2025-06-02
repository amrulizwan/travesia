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

      if (response == null || response is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Login gagal: Tidak ada respons dari server'
        };
      }

      // Type-safe conversion of response data
      final token = response['token'] as String?;
      final user = response['user'] as Map<String, dynamic>?;
      final refreshToken = response['refreshToken'] as String?;

      if (token != null && user != null) {
        // Save both main token and refresh token
        await _saveAuthData(token, user);
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        _apiService.setAuthToken(token);

        return {
          'success': true,
          'user': User.fromJson(user),
          'token': token,
          'refreshToken': refreshToken,
        };
      } else {
        return {
          'success': false,
          'message': (response['message'] as String?) ??
              'Login gagal: Data tidak lengkap'
        };
      }
    } catch (e) {
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }

      String userFriendlyMessage = 'Login gagal: Terjadi kesalahan.';
      List<String> parts = rawMessage.split(': ');
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];

        switch (statusCode) {
          case '401':
            userFriendlyMessage = 'Login gagal: Email atau password salah.';
            break;
          case '403':
            userFriendlyMessage = 'Login gagal: Akun Anda telah diblokir.';
            break;
          case '404':
            userFriendlyMessage = 'Login gagal: Email tidak ditemukan.';
            break;
          default:
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
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userKey, value: jsonEncode(userData));
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
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
      _apiService.setAuthToken(token);
      User? user = await getUser();
      if (user == null) {
        await logout();
        return false;
      }
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      _apiService.setAuthToken(token);
      final response = await _apiService.get('user/profile');

      if (response != null) {
        return response;
      } else {
        await logout();
        return null;
      }
    } catch (e) {
      throw Exception('Error getting user info: $e');
    }
  }

  Future<Map<String, dynamic>> requestResetPassword(String email) async {
    try {
      final response = await _apiService.post('auth/request-reset-password', {
        'email': email,
      });

      return {
        'success': true,
        'message':
            response['message'] ?? 'Reset password code sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> verifyAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post('auth/verify-reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('500')) {
        return {
          'success': false,
          'message': 'Server error: Please try again later',
        };
      }
      if (errorMessage.contains('undefined number')) {
        return {
          'success': false,
          'message': 'Invalid OTP code. Please check and try again.',
        };
      }
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
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
