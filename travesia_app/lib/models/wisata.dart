// Wisata Model
import 'lokasi.dart';
import 'koordinat.dart';
import 'jam_operasional.dart';
import 'gallery_item.dart';
import 'ticket_type.dart';
import 'review.dart';

class Wisata {
  final String id;
  final String nama;
  final String deskripsi;
  final String idLokasi;
  final Lokasi? lokasi;
  final Koordinat koordinat;
  final String alamat;
  final String kontak;
  final String website;
  final List<JamOperasional> jamOperasional;
  final List<GalleryItem> gallery;
  final List<TicketType> jenisTiket;
  final List<Review> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? averageRating;

  Wisata({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.idLokasi,
    this.lokasi,
    required this.koordinat,
    required this.alamat,
    required this.kontak,
    required this.website,
    required this.jamOperasional,
    required this.gallery,
    required this.jenisTiket,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
    this.averageRating,
  });

  factory Wisata.fromJson(Map<String, dynamic> json) {
    return Wisata(
      id: json['id_wisata'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      idLokasi: json['id_lokasi'] as String,
      lokasi: json['lokasi'] != null ? Lokasi.fromJson(json['lokasi'] as Map<String, dynamic>) : null,
      koordinat: Koordinat.fromJson(json['koordinat'] as Map<String, dynamic>),
      alamat: json['alamat'] as String,
      kontak: json['kontak'] as String,
      website: json['website'] as String,
      jamOperasional: (json['jam_operasional'] as List<dynamic>)
          .map((e) => JamOperasional.fromJson(e as Map<String, dynamic>))
          .toList(),
      gallery: (json['gallery'] as List<dynamic>)
          .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      jenisTiket: (json['jenis_tiket'] as List<dynamic>)
          .map((e) => TicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_wisata': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'id_lokasi': idLokasi,
      'lokasi': lokasi?.toJson(),
      'koordinat': koordinat.toJson(),
      'alamat': alamat,
      'kontak': kontak,
      'website': website,
      'jam_operasional': jamOperasional.map((e) => e.toJson()).toList(),
      'gallery': gallery.map((e) => e.toJson()).toList(),
      'jenis_tiket': jenisTiket.map((e) => e.toJson()).toList(),
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'average_rating': averageRating,
    };
  }
}
