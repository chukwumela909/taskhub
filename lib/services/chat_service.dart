import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatService {
  final String _baseUrl = "https://taskhub-server1.onrender.com/api/chat";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // POST /api/chat/conversations
  Future<Map<String, dynamic>> createOrGetConversation({
    required String taskId,
    String? bidId,
    String? taskerId,
  }) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final body = {
      'taskId': taskId,
      if (bidId != null) 'bidId': bidId,
      if (taskerId != null) 'taskerId': taskerId,
    };

    final res = await http.post(
      Uri.parse('$_baseUrl/conversations'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      return Map<String, dynamic>.from(data['conversation']);
    }
    throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to open conversation';
  }

  // GET /api/chat/conversations
  Future<Map<String, dynamic>> listConversations({int page = 1, int limit = 20}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final uri = Uri.parse('$_baseUrl/conversations').replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final res = await http.get(uri, headers: _headers(token));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      return {
        'conversations': List<Map<String, dynamic>>.from(data['conversations'] ?? []),
        'currentPage': data['currentPage'] ?? page,
        'totalPages': data['totalPages'] ?? 1,
      };
    }
    throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to fetch conversations';
  }

  // GET /api/chat/conversations/:id
  Future<Map<String, dynamic>> getConversation(String id) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final res = await http.get(Uri.parse('$_baseUrl/conversations/$id'), headers: _headers(token));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      return Map<String, dynamic>.from(data['conversation']);
    }
    throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to fetch conversation';
  }

  // GET /api/chat/conversations/:id/messages?before=&limit=
  Future<List<Map<String, dynamic>>> listMessages(String conversationId, {String? before, int limit = 20}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final qp = <String, String>{'limit': limit.toString()};
    if (before != null) qp['before'] = before;
    final uri = Uri.parse('$_baseUrl/conversations/$conversationId/messages').replace(queryParameters: qp);
    final res = await http.get(uri, headers: _headers(token));
    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['status'] == 'success') {
      return List<Map<String, dynamic>>.from(data['messages'] ?? []);
    }
    throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to fetch messages';
  }

  // POST /api/chat/conversations/:id/messages
  Future<Map<String, dynamic>> sendMessage(String conversationId, {String? text, List<Map<String, dynamic>>? attachments}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final body = {
      if (text != null) 'text': text,
      if (attachments != null) 'attachments': attachments,
    };
    final res = await http.post(
      Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode == 201 && data['status'] == 'success') {
      return Map<String, dynamic>.from(data['message']);
    }
    throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to send message';
  }

  // POST /api/chat/conversations/:id/read
  Future<void> markRead(String conversationId, {String? upTo}) async {
    final token = await _getToken();
    if (token == null) throw 'Authentication token not found. Please login first.';

    final body = {if (upTo != null) 'upTo': upTo};
    final res = await http.post(
      Uri.parse('$_baseUrl/conversations/$conversationId/read'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      try {
        final data = jsonDecode(res.body);
        throw (data is Map && data['message'] is String) ? data['message'] : 'Failed to mark read';
      } catch (_) {
        throw 'Failed to mark read';
      }
    }
  }
}
