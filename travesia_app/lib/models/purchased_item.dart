// PurchasedItem Model
import 'ticket_type.dart';
import 'wisata.dart';

class PurchasedItem {
  final String id;
  final String idJenisTiket;
  final String idWisata;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketType? jenisTiket;
  final Wisata? wisata;

  PurchasedItem({
    required this.id,
    required this.idJenisTiket,
    required this.idWisata,
    required this.jumlah,
    required this.hargaSatuan,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    this.jenisTiket,
    this.wisata,
  });

  factory PurchasedItem.fromJson(Map<String, dynamic> json) {
    return PurchasedItem(
      id: json['id_item_pembelian'] as String,
      idJenisTiket: json['id_jenis_tiket'] as String,
      idWisata: json['id_wisata'] as String,
      jumlah: json['jumlah'] as int,
      hargaSatuan: (json['harga_satuan'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      jenisTiket: json['jenis_tiket'] != null ? TicketType.fromJson(json['jenis_tiket'] as Map<String, dynamic>) : null,
      wisata: json['wisata'] != null ? Wisata.fromJson(json['wisata'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_item_pembelian': id,
      'id_jenis_tiket': idJenisTiket,
      'id_wisata': idWisata,
      'jumlah': jumlah,
      'harga_satuan': hargaSatuan,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'jenis_tiket': jenisTiket?.toJson(),
      'wisata': wisata?.toJson(),
    };
  }
}
