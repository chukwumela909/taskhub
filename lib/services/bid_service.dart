import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BidService {
  final String _baseUrl = "https://taskhub-server1.onrender.com/api";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createBid({
    required String taskId,
    double? amount,
    String? message,
  }) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final body = <String, dynamic>{
      'taskId': taskId,
      if (amount != null) 'amount': amount,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    };

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/bids'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return data;
      }
      throw data['message'] ?? 'Failed to create bid';
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBid({
    required String bidId,
    double? amount,
    String? message,
  }) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final body = <String, dynamic>{
      if (amount != null) 'amount': amount,
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    };

    try {
      final resp = await http.put(
        Uri.parse('$_baseUrl/bids/$bidId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return data;
      }
      throw data['message'] ?? 'Failed to update bid';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBid({required String bidId}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    try {
      final resp = await http.delete(
        Uri.parse('$_baseUrl/bids/$bidId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (resp.statusCode == 200 || resp.statusCode == 204) return true;
      final data = jsonDecode(resp.body);
      throw data['message'] ?? 'Failed to delete bid';
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptBid({required String bidId}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/bids/$bidId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        // Expecting { status:'success', bid, task }
        return data is Map<String, dynamic> ? data : <String, dynamic>{'status': 'success'};
      }
      if (resp.statusCode == 402) {
        throw data['message'] ?? 'Insufficient wallet balance to accept bid';
      }
      throw data['message'] ?? 'Failed to accept bid';
    } catch (e) {
      rethrow;
    }
  }
}
