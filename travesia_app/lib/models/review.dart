// Review Model
import 'user.dart';

class Review {
  final String id;
  final String userId;
  final int rating;
  final String komentar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.komentar,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id_review'] as String,
      userId: json['id_user'] as String,
      rating: json['rating'] as int,
      komentar: json['komentar'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_review': id,
      'id_user': userId,
      'rating': rating,
      'komentar': komentar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}
