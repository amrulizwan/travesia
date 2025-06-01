// Lokasi Model
class Lokasi {
  final String id;
  final String nama;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lokasi({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id_lokasi'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lokasi': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
