import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/chat_provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/screens/user/chat_screen.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class TaskerMessagesScreen extends StatefulWidget {
  const TaskerMessagesScreen({super.key});

  @override
  State<TaskerMessagesScreen> createState() => _TaskerMessagesScreenState();
}

class _TaskerMessagesScreenState extends State<TaskerMessagesScreen> {
  // Poll conversations to feel real-time
  Timer? _pollTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
      // start 1-second polling
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        context.read<ChatProvider>().fetchConversations(page: 1, limit: 20, showLoading: false);
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Geist',
                      color: Colors.white,
                    ),
                  ),
                  // Container(
                  //   width: 40,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF2A2A2A),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: IconButton(
                  //     icon: SvgPicture.asset(
                  //       'assets/icons/notification.svg',
                  //       width: 24,
                  //       height: 24,
                  //       colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                  //     ),
                  //     onPressed: () {
                  //       // Handle notification
                  //     },
                  //   ),
                  // ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Search bar
              _buildSearchBar(),
              
              const SizedBox(height: 24),
              
              // Messages list
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (_, chat, __) {
                    if (chat.conversationsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final convos = chat.conversations.whereType<Map<String, dynamic>>().toList();
                    if (convos.isEmpty) return _buildEmptyState();

                    return ListView.builder(
                      itemCount: convos.length,
                      itemBuilder: (context, index) {
                        final c = convos[index];
                        // Derive preview (supports string or map shape)
                        String preview = '';
                        if (c['lastMessage'] is String) {
                          preview = (c['lastMessage'] ?? '').toString();
                        } else if (c['lastMessage'] is Map) {
                          final last = c['lastMessage'] as Map;
                          preview = (last['text'] ?? '').toString();
                        }

                        // Time
                        dynamic timeSource = c['lastMessageAt'] ?? c['updatedAt'];
                        if (timeSource == null && c['lastMessage'] is Map) {
                          timeSource = (c['lastMessage'] as Map)['createdAt'];
                        }
                        final time = _formatTime(timeSource);

                        // Unread for TASKER side prefers unread.tasker
                        int unread = 0;
                        if (c['unread'] is Map) {
                          final u = (c['unread'] as Map)['tasker'];
                          unread = u is int ? u : int.tryParse((u ?? '0').toString()) ?? 0;
                        } else {
                          final unreadRaw = c['unreadCount'];
                          unread = unreadRaw is int ? unreadRaw : int.tryParse((unreadRaw ?? '0').toString()) ?? 0;
                        }

                        // Title/avatar should be the OTHER participant (user for tasker inbox)
                        String title = '';
                        String? avatar;
                        if (c['user'] is Map) {
                          final u = c['user'] as Map;
                          title = (u['fullName'] ?? u['name'] ?? '').toString();
                          if (title.trim().isEmpty) {
                            final fn = (u['firstName'] ?? '').toString();
                            final ln = (u['lastName'] ?? '').toString();
                            final full = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ').trim();
                            if (full.isNotEmpty) title = full;
                          }
                          avatar = (u['profilePicture'] ?? u['avatarUrl'])?.toString();
                        }

                        // Fallbacks
                        if (title.isEmpty) {
                          title = (c['title'] ?? c['taskTitle'] ?? '').toString();
                        }
                        if ((avatar == null || avatar.isEmpty)) {
                          final avatarRaw = c['avatarUrl'];
                          avatar = avatarRaw is String ? avatarRaw : null;
                        }
                        if (title.isEmpty || avatar == null || avatar.isEmpty) {
                          try {
                            final auth = context.read<AuthProvider>();
                            final ud = auth.userData;
                            final me = ud != null ? ud['user'] : null;
                            final myId = (me is Map) ? (me['_id'] ?? me['id'] ?? me['uuid'] ?? '').toString() : '';
                            final parts = c['participants'];
                            final peer = _otherFromParts(parts, myId);
                            if (title.isEmpty) {
                              title = _nameFromUser(peer) ?? 'Conversation';
                            }
                            if (avatar == null || avatar.isEmpty) {
                              avatar = _avatarFromUser(peer);
                            }
                          } catch (_) {}
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: _buildMessageItem(
                            name: title,
                            message: preview.isEmpty ? 'Tap to open conversation' : preview,
                            time: time,
                            unread: unread > 0,
                            unreadCount: unread,
                            avatarUrl: avatar,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    final idRaw = (c['_id'] ?? c['id']);
                                    final convoId = idRaw?.toString() ?? '';
                                    return ChatScreen(
                                      conversationId: convoId,
                                      title: title.isNotEmpty ? title : 'Conversation',
                                      avatarUrl: avatar,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Geist',
              ),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontFamily: 'Geist',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required String name,
    required String message,
    required String time,
    required bool unread,
    required int unreadCount,
    String? avatarUrl,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            // Avatar with safe fallback (initials or icon) and border highlight
            ProfilePictureWidget(
              profilePictureUrl: avatarUrl,
              displayName: name,
              radius: 25,
              showBorder: true,
              borderColor: unread ? primaryColor : Colors.grey.shade700,
              borderWidth: 2,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Geist',
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread ? primaryColor : Colors.grey.shade500,
                          fontFamily: 'Geist',
                          fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Optional task title could go here if needed
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            color: unread ? Colors.white : Colors.grey.shade400,
                            fontFamily: 'Geist',
                            fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.message_outlined,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start completing tasks to receive\nmessages from clients.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic createdAt) {
    try {
      final parsed = createdAt is String
          ? DateTime.tryParse(createdAt)
          : (createdAt is DateTime ? createdAt : null);
      if (parsed == null) return '';
      final dt = parsed.toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m$ampm';
    } catch (_) {
      return '';
    }
  }
} 

dynamic _otherFromParts(dynamic participants, String myId) {
  if (participants is List) {
    for (final p in participants) {
      if (p is Map) {
        final id = (p['_id'] ?? p['id'] ?? p['uuid'] ?? '').toString();
        if (id != myId) return p;
      } else if (p is String) {
        if (p != myId) return {'_id': p};
      }
    }
  }
  return null;
}

String? _nameFromUser(dynamic user) {
  if (user is Map) {
    final full = (user['fullName'] ?? user['name'])?.toString();
    if (full != null && full.trim().isNotEmpty) return full;
    final fn = (user['firstName'] ?? '').toString();
    final ln = (user['lastName'] ?? '').toString();
    final joined = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ').trim();
    if (joined.isNotEmpty) return joined;
  }
  return null;
}

String? _avatarFromUser(dynamic user) {
  if (user is Map) {
    final url = (user['profilePicture'] ?? user['avatarUrl'])?.toString();
    if (url != null && url.trim().isNotEmpty) return url;
  }
  return null;
}