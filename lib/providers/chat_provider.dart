import 'package:flutter/material.dart';
import 'package:taskhub/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Conversations inbox
  bool _conversationsLoading = false;
  String? _conversationsError;
  List<Map<String, dynamic>> _conversations = [];
  int _currentPage = 1;
  int _totalPages = 1;

  // Messages per conversation
  final Map<String, List<Map<String, dynamic>>> _messages = {};
  final Map<String, bool> _messagesLoading = {};
  final Map<String, String?> _messagesError = {};
  final Map<String, bool> _hasMore = {};

  bool get conversationsLoading => _conversationsLoading;
  String? get conversationsError => _conversationsError;
  List<Map<String, dynamic>> get conversations => _conversations;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  List<Map<String, dynamic>> messagesFor(String conversationId) => _messages[conversationId] ?? const [];
  bool messagesLoading(String conversationId) => _messagesLoading[conversationId] ?? false;
  String? messagesError(String conversationId) => _messagesError[conversationId];
  bool hasMore(String conversationId) => _hasMore[conversationId] ?? false;

  Future<bool> fetchConversations({int page = 1, int limit = 20, bool showLoading = true}) async {
    if (showLoading) {
      _conversationsLoading = true;
      _conversationsError = null;
      notifyListeners();
    }
    try {
      final res = await _chatService.listConversations(page: page, limit: limit);
      _conversations = List<Map<String, dynamic>>.from(res['conversations'] ?? []);
      _currentPage = res['currentPage'] ?? page;
      _totalPages = res['totalPages'] ?? 1;
      if (showLoading) {
        _conversationsLoading = false;
      }
      notifyListeners();
      return true;
    } catch (e) {
      if (showLoading) {
        _conversationsLoading = false;
      }
      _conversationsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> openConversation({
    required String taskId,
    String? bidId,
    String? taskerId,
  }) async {
    try {
      final convo = await _chatService.createOrGetConversation(taskId: taskId, bidId: bidId, taskerId: taskerId);
      return convo;
    } catch (e) {
      _conversationsError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchMessages(String conversationId, {bool refresh = false, int limit = 20}) async {
    if (messagesLoading(conversationId)) return;
    _messagesLoading[conversationId] = true;
    _messagesError[conversationId] = null;
    notifyListeners();

    try {
      String? before;
      if (!refresh) {
        final existing = _messages[conversationId];
        if (existing != null && existing.isNotEmpty) {
          // paginate older by using the first message's createdAt
          before = existing.first['createdAt'];
        }
      }
      final list = await _chatService.listMessages(conversationId, before: before, limit: limit);
      if (refresh || (_messages[conversationId] == null)) {
        _messages[conversationId] = list;
      } else {
        // Prepend older messages
        final existing = _messages[conversationId]!;
        _messages[conversationId] = [...list, ...existing];
      }
      // hasMore: if we requested with before, server returns hasMore but ChatService didn't return; infer by page size
      _hasMore[conversationId] = list.length >= limit;
      _messagesLoading[conversationId] = false;
      notifyListeners();
    } catch (e) {
      _messagesLoading[conversationId] = false;
      _messagesError[conversationId] = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String conversationId, {required String text}) async {
    try {
  final created = await _chatService.sendMessage(conversationId, text: text);
  // Do not auto-append here to allow caller to handle optimistic UI replacement
  return created;
    } catch (e) {
      _messagesError[conversationId] = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> markRead(String conversationId) async {
    try {
      await _chatService.markRead(conversationId);
      // Optionally sync inbox unread by refetching later
    } catch (_) {}
  }

  void clearAll() {
    _conversationsLoading = false;
    _conversationsError = null;
    _conversations = [];
    _currentPage = 1;
    _totalPages = 1;
    _messages.clear();
    _messagesLoading.clear();
    _messagesError.clear();
    _hasMore.clear();
    notifyListeners();
  }

  // Optimistic UI helpers
  void appendLocalMessage(String conversationId, Map<String, dynamic> msg) {
    final list = _messages[conversationId] ?? [];
    _messages[conversationId] = [...list, msg];
    notifyListeners();
  }

  void replaceLastLocalMessage(String conversationId, Map<String, dynamic> msg) {
    final list = _messages[conversationId] ?? [];
    if (list.isEmpty) {
      _messages[conversationId] = [msg];
    } else {
      final newList = List<Map<String, dynamic>>.from(list);
      newList[newList.length - 1] = msg;
      _messages[conversationId] = newList;
    }
    notifyListeners();
  }
}
