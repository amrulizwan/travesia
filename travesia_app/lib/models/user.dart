// User Model
class User {
  final String id;
  final String nama;
  final String email;
  final String? fotoProfil;
  final String role;

  User({
    required this.id,
    required this.nama,
    required this.email,
    this.fotoProfil,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fotoProfil: json['fotoProfil']?.toString(),
      role: json['role']?.toString() ?? 'pengunjung',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'fotoProfil': fotoProfil,
      'role': role,
    };
  }
}
