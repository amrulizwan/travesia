import 'api_service.dart'; // Adjust path as necessary
import '../models/user.dart'; // Adjust path as necessary

class AdminService {
  final ApiService _apiService;

  AdminService(this._apiService);

  Future<Map<String, dynamic>> listUsers({int page = 1, int limit = 10, String? role}) async {
    try {
      String endpoint = 'admin/users?page=$page&limit=$limit';
      if (role != null && role.isNotEmpty) {
        endpoint += '&role=$role';
      }
      final response = await _apiService.get(endpoint);

      // MANUAL_TEST_CASES.md suggests: "Response contains paginated list of users, totalPages, currentPage, totalUsers."
      // Assuming response structure like: {"data": {"users": [], "totalPages": ..., "currentPage": ..., "totalUsers": ...}}
      // Or: {"users": [], "totalPages": ..., "currentPage": ..., "totalUsers": ...} if not nested under 'data'
      if (response != null && response['data'] is Map) {
        final dataMap = response['data'] as Map<String, dynamic>;
        if (dataMap['users'] is List) {
           // To ensure User.fromJson works, we might need to ensure the items in dataMap['users'] are correctly formatted.
           // For now, assuming User.fromJson can handle the map.
          return dataMap; // Contains 'users' list and pagination fields
        }
      } else if (response != null && response['users'] is List) {
         // Fallback if not nested under 'data'
         return response as Map<String, dynamic>;
      }
      throw Exception('Failed to parse user list or no data found');
    } catch (e) {
      print('Error in listUsers: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat daftar pengguna: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memuat daftar pengguna: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get('admin/users/$userId');
      // Assuming the API returns the user object directly or under a 'data' key
      if (response != null && response['data'] != null && response['data']['_id'] != null) {
        return User.fromJson(response['data']);
      } else if (response != null && response['_id'] != null) {
        return User.fromJson(response);
      } else {
        throw Exception('Failed to parse user data or no data found for ID: $userId');
      }
    } catch (e) {
      print('Error in getUserById for $userId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat detail pengguna: $rawMessage';
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];
        if (statusCode == '404') {
          userFriendlyMessage = 'Gagal memuat detail pengguna: Pengguna tidak ditemukan.';
        } else {
          userFriendlyMessage = 'Gagal memuat detail pengguna: $apiMessage';
        }
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<User> updateUserRole(String userId, String role) async {
    try {
      final response = await _apiService.put('admin/users/$userId/role', {'role': role});
      // Assuming the API returns the updated user object directly or under 'data'
      if (response != null && response['data'] != null && response['data']['_id'] != null) {
        return User.fromJson(response['data']);
      } else if (response != null && response['_id'] != null) {
        return User.fromJson(response);
      } else {
        throw Exception('Failed to parse updated user data or no data returned');
      }
    } catch (e) {
      print('Error in updateUserRole for $userId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memperbarui peran pengguna: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memperbarui peran pengguna: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<User> updateUserStatus(String userId, String statusAkun) async {
    try {
      final response = await _apiService.put('admin/users/$userId/status', {'statusAkun': statusAkun});
      // Assuming the API returns the updated user object directly or under 'data'
      if (response != null && response['data'] != null && response['data']['_id'] != null) {
        return User.fromJson(response['data']);
      } else if (response != null && response['_id'] != null) {
        return User.fromJson(response);
      } else {
        throw Exception('Failed to parse updated user status data or no data returned');
      }
    } catch (e) {
      print('Error in updateUserStatus for $userId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memperbarui status pengguna: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memperbarui status pengguna: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }
}

// Helper extension for String.splitN (if not globally available)
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
