import 'dart:convert';
import '../models/review.dart'; // Adjust path as necessary
import 'api_service.dart'; // Adjust path as necessary

class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

  Future<Map<String, dynamic>> createReview(
    String wisataId,
    int rating,
    String comment, {
    String? ticketId, // Optional ticketId
  }) async {
    try {
      final response = await _apiService.post('reviews', {
        'id_wisata': wisataId,
        'rating': rating,
        'komentar': comment,
        if (ticketId != null) 'id_tiket': ticketId,
      });

      // Assuming a successful response might look like:
      // {"success": true, "message": "Review created successfully", "data": reviewObject}
      // or just {"success": true, "message": "Review created successfully"}
      if (response != null && response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Review submitted successfully!',
          'data': response['data'] != null
              ? Review.fromJson(response['data'])
              : null,
        };
      } else {
        throw Exception(response['message'] ??
            'Failed to submit review: Unknown server response');
      }
    } catch (e) {
      print('Error in createReview: $e');
      print('Error in createReview: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }

      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal mengirim ulasan: $rawMessage';
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];
        if (statusCode == '400') {
          // Bad Request (e.g. validation error)
          userFriendlyMessage = 'Gagal mengirim ulasan: $apiMessage';
        } else if (statusCode == '401') {
          // Unauthorized
          userFriendlyMessage =
              'Gagal mengirim ulasan: Anda tidak terautentikasi. Silakan login kembali.';
        } else if (statusCode == '403') {
          // Forbidden (e.g. user hasn't purchased ticket for this wisata)
          userFriendlyMessage =
              'Gagal mengirim ulasan: $apiMessage (Anda mungkin perlu membeli tiket terlebih dahulu).';
        } else if (statusCode == '404') {
          // Not found (e.g. wisata not found)
          userFriendlyMessage = 'Gagal mengirim ulasan: $apiMessage';
        }
        // Add more specific status code handling if needed
        else {
          userFriendlyMessage = 'Gagal mengirim ulasan: $apiMessage';
        }
      }
      // createReview returns a map, so we reformat the exception into that structure for consistency in UI handling.
      // However, the original implementation of createReview in WisataDetailPage expects an Exception for its catch block.
      // So, we will throw an Exception here.
      throw Exception(userFriendlyMessage);
    }
  }

  Future<List<Review>> getReviewsForWisata(
    String wisataId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService
          .get('reviews/wisata/$wisataId?page=$page&limit=$limit');

      // Assuming response structure: {"success": true, "data": {"reviews": [], "currentPage": 1, "totalPages": 1, "totalReviews": 0}}
      // Or simpler: {"data": []} if not paginated from backend in this way
      if (response != null && response['data'] != null) {
        List<dynamic> reviewData;
        if (response['data'] is List) {
          // Simpler structure
          reviewData = response['data'];
        } else if (response['data'] is Map &&
            response['data']['reviews'] is List) {
          // Paginated structure
          reviewData = response['data']['reviews'];
          // Potentially, you could return the whole map if you need pagination info in UI
          // For now, just returning the list of reviews
        } else {
          throw Exception('Unexpected data format for reviews');
        }
        return reviewData.map((json) => Review.fromJson(json)).toList();
      } else if (response != null && response['message'] != null) {
        throw Exception('Failed to get reviews: ${response['message']}');
      } else {
        throw Exception('Failed to parse reviews list or no data found');
      }
    } catch (e) {
      print('Error in getReviewsForWisata: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat ulasan: $rawMessage';
      if (parts.length == 2) {
        // String statusCode = parts[0];
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memuat ulasan: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  // Optional: getMyReviews (can be implemented later if needed)
  // Future<List<Review>> getMyReviews({int page = 1, int limit = 10}) async { ... }
}

// Helper extension from AuthService, assuming it's accessible project-wide or defined in a common utility file.
extension StringExtensions on String {
  List<String> splitN(Pattern pattern, int n) {
    var parts = <String>[];
    var current = 0;
    for (var i = 0; i < n - 1; i++) {
      var index = indexOf(pattern, current);
      if (index == -1) {
        break;
      }
      parts.add(substring(current, index));
      current = index + pattern.matchAsPrefix(this, index)!.group(0)!.length;
    }
    parts.add(substring(current));
    return parts;
  }
}
