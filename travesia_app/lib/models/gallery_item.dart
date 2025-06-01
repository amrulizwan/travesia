// GalleryItem Model
class GalleryItem {
  final String id;
  final String urlGambar;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalleryItem({
    required this.id,
    required this.urlGambar,
    required this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id_gallery_item'] as String,
      urlGambar: json['url_gambar'] as String,
      deskripsi: json['deskripsi'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_gallery_item': id,
      'url_gambar': urlGambar,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
