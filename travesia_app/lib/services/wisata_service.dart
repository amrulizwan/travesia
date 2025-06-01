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
