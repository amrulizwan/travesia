// Koordinat Model
class Koordinat {
  final double latitude;
  final double longitude;

  Koordinat({
    required this.latitude,
    required this.longitude,
  });

  factory Koordinat.fromJson(Map<String, dynamic> json) {
    return Koordinat(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
