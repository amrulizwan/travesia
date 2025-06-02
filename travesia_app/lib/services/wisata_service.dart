import '../models/wisata.dart'; // Adjust path as necessary
import 'api_service.dart'; // Adjust path as necessary

class WisataService {
  final ApiService _apiService;

  WisataService(this._apiService);

  Future<List<Wisata>> getAllWisata() async {
    try {
      final response = await _apiService.get('wisata');
      if (response != null && response['data'] is List) {
        List<dynamic> wisataData = response['data'];
        return wisataData.map((json) => Wisata.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse wisata list or no data found');
      }
    } catch (e) {
      // Log error or handle more gracefully
      print('Error in getAllWisata: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      // Example of trying to make it more user-friendly, could be expanded
      // For WisataService, the API responses are usually lists or objects,
      // so errors might often be 404s or 500s.
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat daftar wisata: $rawMessage';
      if (parts.length == 2) {
        // String statusCode = parts[0];
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memuat daftar wisata: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> addGalleryImage(String wisataId, String imagePath) async {
    try {
      final response = await _apiService.postMultipart(
          'wisata/$wisataId/gallery', imagePath);
      if (response != null && response['data'] != null) {
        return Wisata.fromJson(response['data']);
      } else {
        throw Exception(
            'Failed to parse add gallery image response or no data returned');
      }
    } catch (e) {
      print('Error in addGalleryImage for wisata $wisataId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal menambah gambar galeri: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal menambah gambar galeri: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> createWisata(Map<String, dynamic> wisataData) async {
    try {
      final response = await _apiService.post('wisata', wisataData);
      if (response != null && response['data'] != null) {
        return Wisata.fromJson(response['data']);
      } else {
        throw Exception('Failed to parse created wisata or no data returned');
      }
    } catch (e) {
      print('Error in createWisata: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal membuat wisata: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal membuat wisata: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> updateWisata(
      String wisataId, Map<String, dynamic> wisataData) async {
    try {
      final response = await _apiService.put('wisata/$wisataId', wisataData);
      if (response != null && response['data'] != null) {
        return Wisata.fromJson(response['data']);
      } else {
        throw Exception('Failed to parse updated wisata or no data returned');
      }
    } catch (e) {
      print('Error in updateWisata for $wisataId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memperbarui wisata: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memperbarui wisata: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> verifyGalleryImage(
      String wisataId, String gambarId, String status) async {
    try {
      final response = await _apiService
          .put('wisata/$wisataId/gallery/$gambarId/verify', {'status': status});
      if (response != null &&
          response['data'] != null &&
          response['data'] is Map<String, dynamic>) {
        // Assuming the API returns the updated Wisata object in 'data'
        return Wisata.fromJson(response['data']);
      } else if (response != null && response['message'] != null) {
        // If only a message is returned, we might need to fetch Wisata separately or handle differently
        // For now, let's assume 'data' contains the Wisata object as per common pattern.
        // If not, this will throw an error, or we can adjust based on actual API behavior.
        throw Exception(
            'Verification successful but no updated wisata data returned: ${response['message']}');
      } else {
        throw Exception(
            'Failed to parse gallery verification response or no data returned');
      }
    } catch (e) {
      print(
          'Error in verifyGalleryImage for wisata $wisataId, image $gambarId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage =
          'Gagal verifikasi gambar galeri: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal verifikasi gambar galeri: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> assignPengelola(String wisataId, String newPengelolaId) async {
    try {
      final response = await _apiService.put(
          'wisata/$wisataId/assign-pengelola',
          {'newPengelolaId': newPengelolaId});
      if (response != null && response['data'] != null) {
        return Wisata.fromJson(response['data']);
      } else {
        throw Exception(
            'Failed to parse assign pengelola response or no data returned');
      }
    } catch (e) {
      print('Error in assignPengelola for wisata $wisataId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal menetapkan pengelola: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal menetapkan pengelola: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<void> deleteWisata(String wisataId) async {
    try {
      // Delete usually returns 200 with a message or 204 No Content.
      // ApiService._handleResponse will return null for empty success (like 204).
      // If there's a JSON body with a message, it will be decoded.
      final response = await _apiService.delete('wisata/$wisataId');
      // If _handleResponse didn't throw an error for non-2xx status, it's a success.
      // No specific data parsing needed here, just ensuring no error was thrown.
      if (response != null && response['message'] != null) {
        print('Wisata $wisataId deleted successfully: ${response['message']}');
      } else {
        print('Wisata $wisataId deleted successfully.');
      }
      return; // Explicitly return nothing for Future<void>
    } catch (e) {
      print('Error in deleteWisata for $wisataId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal menghapus wisata: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal menghapus wisata: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Wisata> getWisataById(String wisataId) async {
    try {
      final response = await _apiService.get('wisata/$wisataId');
      if (response != null && response['data'] != null) {
        return Wisata.fromJson(response['data']);
      } else {
        throw Exception(
            'Failed to parse wisata details or no data found for ID: $wisataId');
      }
    } catch (e) {
      // Log error or handle more gracefully
      print('Error in getWisataById for $wisataId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat detail wisata: $rawMessage';
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];
        if (statusCode == '404') {
          userFriendlyMessage =
              'Gagal memuat detail wisata: Wisata tidak ditemukan.';
        } else {
          userFriendlyMessage = 'Gagal memuat detail wisata: $apiMessage';
        }
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<List<Wisata>> getWisataByProvince(String provinceId) async {
    try {
      final response = await _apiService.get('wisata?province=$provinceId');
      if (response != null && response['data'] is List) {
        List<dynamic> wisataData = response['data'];
        return wisataData.map((json) => Wisata.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse wisata list or no data found');
      }
    } catch (e) {
      // Log error or handle more gracefully
      print('Error in getWisataByProvince: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      // Example of trying to make it more user-friendly, could be expanded
      // For WisataService, the API responses are usually lists or objects,
      // so errors might often be 404s or 500s.
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat daftar wisata: $rawMessage';
      if (parts.length == 2) {
        // String statusCode = parts[0];
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memuat daftar wisata: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }
}

// Helper extension from AuthService, assuming it's accessible project-wide or defined in a common utility file.
// If not, it needs to be redefined here or imported.
// For this exercise, we'll assume it's available. If this were a real project,
// this would be in a shared utility file.
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
