// User Model
class User {
  final String id;
  final String nama;
  final String email;
  final String role;
  final String? fotoProfil;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.fotoProfil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_user'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      fotoProfil: json['foto_profil'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': id,
      'nama': nama,
      'email': email,
      'role': role,
      'foto_profil': fotoProfil,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
