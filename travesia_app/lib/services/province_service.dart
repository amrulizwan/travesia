import 'package:travesia_app/models/province.dart';
import 'api_service.dart';

class ProvinceService {
  final ApiService _apiService;

  ProvinceService(this._apiService);

  Future<List<Province>> getAllProvinces() async {
    try {
      final response = await _apiService.get('provinces');

      if (response != null && response['data'] is List) {
        List<dynamic> provinceData = response['data'];
        return provinceData.map((json) => Province.fromJson(json)).toList();
      } else {
        throw Exception('Failed to parse province list or no data found');
      }
    } catch (e) {
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      throw Exception('Gagal memuat daftar provinsi: $rawMessage');
    }
  }
}
