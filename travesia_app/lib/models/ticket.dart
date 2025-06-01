// Ticket Model
import 'user.dart';
import 'purchased_item.dart';

class Ticket {
  final String id;
  final String idUser;
  final DateTime tanggalPembelian;
  final double totalHarga;
  final String statusPembayaran;
  final String? kodePembayaran;
  final DateTime? tanggalKedaluwarsaPembayaran;
  final List<PurchasedItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Ticket({
    required this.id,
    required this.idUser,
    required this.tanggalPembelian,
    required this.totalHarga,
    required this.statusPembayaran,
    this.kodePembayaran,
    this.tanggalKedaluwarsaPembayaran,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id_tiket'] as String,
      idUser: json['id_user'] as String,
      tanggalPembelian: DateTime.parse(json['tanggal_pembelian'] as String),
      totalHarga: (json['total_harga'] as num).toDouble(),
      statusPembayaran: json['status_pembayaran'] as String,
      kodePembayaran: json['kode_pembayaran'] as String?,
      tanggalKedaluwarsaPembayaran: json['tanggal_kedaluwarsa_pembayaran'] != null
          ? DateTime.parse(json['tanggal_kedaluwarsa_pembayaran'] as String)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((item) => PurchasedItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tiket': id,
      'id_user': idUser,
      'tanggal_pembelian': tanggalPembelian.toIso8601String(),
      'total_harga': totalHarga,
      'status_pembayaran': statusPembayaran,
      'kode_pembayaran': kodePembayaran,
      'tanggal_kedaluwarsa_pembayaran': tanggalKedaluwarsaPembayaran?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
