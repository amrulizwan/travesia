// TicketType Model
class TicketType {
  final String id;
  final String nama;
  final String deskripsi;
  final double harga;
  final int stok;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketType({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id_jenis_tiket'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      harga: (json['harga'] as num).toDouble(),
      stok: json['stok'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jenis_tiket': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'stok': stok,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
