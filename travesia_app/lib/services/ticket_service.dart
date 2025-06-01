import '../models/ticket.dart'; // Adjust path as necessary
import 'api_service.dart';   // Adjust path as necessary
import 'dart:convert'; // For jsonEncode if directly constructing complex bodies

class TicketService {
  final ApiService _apiService;

  TicketService(this._apiService);

  Future<Map<String, dynamic>> purchaseTicket(
      String wisataId, List<Map<String, dynamic>> itemsToPurchase) async {
    try {
      final response = await _apiService.post('tickets/purchase', {
        'wisataId': wisataId,
        'itemsToPurchase': itemsToPurchase,
      });
      // Assuming the response structure includes orderId, snapToken, etc. directly
      // For example: {"success": true, "data": {"orderId": "...", "snapToken": "...", "ticketId": "..."}}
      if (response != null && response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else if (response != null && response['message'] != null) {
        throw Exception('Failed to purchase ticket: ${response['message']}');
      } else {
        throw Exception('Failed to purchase ticket: Unknown server response');
      }
    } catch (e) {
      print('Error in purchaseTicket: $e');
      print('Error in purchaseTicket: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }

      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal melakukan pemesanan tiket: $rawMessage';
      if (parts.length == 2) {
        String statusCode = parts[0];
        String apiMessage = parts[1];
        if (statusCode == '400') { // Bad Request (e.g. validation error, tickets not available)
          userFriendlyMessage = 'Gagal melakukan pemesanan tiket: $apiMessage';
        } else if (statusCode == '401') { // Unauthorized
          userFriendlyMessage = 'Gagal melakukan pemesanan tiket: Anda tidak terautentikasi. Silakan login kembali.';
        } else if (statusCode == '404') { // Not found (e.g. wisata or ticket type not found)
            userFriendlyMessage = 'Gagal melakukan pemesanan tiket: $apiMessage';
        }
        // Add more specific status code handling if needed
        else {
           userFriendlyMessage = 'Gagal melakukan pemesanan tiket: $apiMessage';
        }
      }
      throw Exception(userFriendlyMessage);
    }
  }

  Future<List<Ticket>> getMyTickets() async {
    try {
      final response = await _apiService.get('tickets/my-tickets');
      if (response != null && response['data'] is List) {
        List<dynamic> ticketData = response['data'];
        return ticketData.map((json) => Ticket.fromJson(json)).toList();
      } else if (response != null && response['message'] != null) {
        throw Exception('Failed to get tickets: ${response['message']}');
      }
      else {
        throw Exception('Failed to parse my tickets list or no data found');
      }
    } catch (e) {
      print('Error in getMyTickets: $e');
      String rawMessage = e.toString();
      if (rawMessage.startsWith("Exception: ")) {
        rawMessage = rawMessage.substring("Exception: ".length);
      }
      List<String> parts = rawMessage.splitN(': ', 2);
      String userFriendlyMessage = 'Gagal memuat tiket Anda: $rawMessage';
      if (parts.length == 2) {
        // String statusCode = parts[0];
        String apiMessage = parts[1];
         userFriendlyMessage = 'Gagal memuat tiket Anda: $apiMessage';
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
