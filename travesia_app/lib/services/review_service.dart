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
      final Map<String, dynamic> requestBody = {
        'wisataId': wisataId,
        'rating': rating,
        'comment': comment,
      };
      if (ticketId != null) {
        requestBody['ticketId'] = ticketId;
      }
      final response = await _apiService.post('reviews', requestBody);

      // MANUAL_TEST_CASES.md suggests the created review object is returned directly.
      // _handleResponse in ApiService should decode the JSON.
      // We assume if '_id' (a common field for MongoDB documents) is present, it's the review object.
      if (response != null && response['_id'] != null) {
        return {
          'success': true,
          'message': 'Review submitted successfully!',
          'data': Review.fromJson(response), // Parse the whole response as Review
        };
      } else if (response != null && response['message'] != null) {
        // This case might occur if the backend sends a specific error message
        // even with a 2xx status, or if _handleResponse is modified to return non-error messages.
        // However, _handleResponse typically throws an Exception for non-2xx statuses.
        throw Exception(response['message']);
      } else {
        // Fallback for unexpected successful responses that are not review objects.
        // This also covers cases where _apiService.post might return null or an empty map
        // from _handleResponse if the response body was empty (e.g. 204 No Content, though unlikely for POST).
         return {
            'success': true, // Or false, depending on how strict we want to be
            'message': 'Review submitted, but response format was unexpected.',
            'data': null
        };
      }
    } catch (e) {
      print('Error in createReview: $e');
      // The duplicate print was likely a copy-paste error, removing one.
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

  Future<List<Review>> getMyReviews({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get('reviews/my-reviews?page=$page&limit=$limit');
      // Assuming response structure similar to getReviewsForWisata
      if (response != null && response['data'] != null) {
        List<dynamic> reviewData;
        if (response['data'] is List) {
          reviewData = response['data'];
        } else if (response['data'] is Map && response['data']['reviews'] is List) {
          reviewData = response['data']['reviews'];
          // Potentially return Map<String, dynamic> for pagination info
        } else {
          throw Exception('Unexpected data format for my reviews');
        }
        return reviewData.map((json) => Review.fromJson(json)).toList();
      } else if (response != null && response['message'] != null) {
        throw Exception('Failed to get my reviews: ${response['message']}');
      } else {
        throw Exception('Failed to parse my reviews list or no data found');
      }
    } catch (e) {
      print('Error in getMyReviews: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat ulasan Anda: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memuat ulasan Anda: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Review> updateMyReview(String reviewId, int rating, String comment) async {
    try {
      final response = await _apiService.put('reviews/$reviewId', {
        'rating': rating,
        'comment': comment,
      });
      if (response != null && response['_id'] != null) { // Assuming API returns updated review
        return Review.fromJson(response);
      } else {
        throw Exception('Failed to parse updated review or no data returned');
      }
    } catch (e) {
      print('Error in updateMyReview for $reviewId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memperbarui ulasan: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal memperbarui ulasan: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Review> respondToReview(String reviewId, String responseText) async {
    try {
      final response = await _apiService.put('reviews/$reviewId/respond', {
        'responseText': responseText,
      });
      if (response != null && response['_id'] != null) { // Assuming API returns updated review
        return Review.fromJson(response);
      } else {
        throw Exception('Failed to parse review response or no data returned');
      }
    } catch (e) {
      print('Error in respondToReview for $reviewId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal menanggapi ulasan: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal menanggapi ulasan: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<Review> setReviewStatus(String reviewId, String status) async {
    try {
      final response = await _apiService.put('reviews/$reviewId/status', {
        'status': status,
      });
      if (response != null && response['_id'] != null) { // Assuming API returns updated review
        return Review.fromJson(response);
      } else {
        throw Exception('Failed to parse set review status response or no data returned');
      }
    } catch (e) {
      print('Error in setReviewStatus for $reviewId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal mengatur status ulasan: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal mengatur status ulasan: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiService.delete('reviews/$reviewId');
      // If _apiService.delete throws an error, it will be caught by the catch block.
      // If it completes without error, the deletion was successful.
      print('Review $reviewId deleted successfully.');
      return;
    } catch (e) {
      print('Error in deleteReview for $reviewId: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal menghapus ulasan: $rawMessage';
      if (parts.length == 2) {
        String apiMessage = parts[1];
        userFriendlyMessage = 'Gagal menghapus ulasan: $apiMessage';
      }
      throw Exception(userFriendlyMessage);
    }
  }
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
