import 'package:flutter/material.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/user/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/chat_provider.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _activeTab = 'All'; // Track active filter tab

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with user profile info
            _buildUserProfileHeader(),
            
            // Divider
            Divider(
              color: Colors.black.withOpacity(0.09),
              height: 1,
            ),
            
            // Filters and Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black.withOpacity(0.3),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Search Messages',
                          style: TextStyle(
                            fontFamily: 'Geist',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter tabs
                  Row(
                    children: [
                      _buildFilterTab('All'),
                      const SizedBox(width: 12),
                      _buildFilterTab('Unread'),
                      const SizedBox(width: 12),
                      _buildFilterTab('Read'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Message list
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (_, chat, __) {
                  if (chat.conversationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (chat.conversations.isEmpty) {
                    return _buildEmptyState();
                  }

                  final items = _filtered(
                    chat.conversations.whereType<Map<String, dynamic>>().toList(),
                  );
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(color: Colors.black.withOpacity(0.05), height: 1),
                    itemBuilder: (context, index) {
                      final c = items[index];
                      // Derive preview (supports string or map shape)
                      String preview = '';
                      if (c['lastMessage'] is String) {
                        preview = (c['lastMessage'] ?? '').toString();
                      } else if (c['lastMessage'] is Map) {
                        final last = c['lastMessage'] as Map;
                        preview = (last['text'] ?? '').toString();
                      }

                      // Derive time from lastMessageAt, updatedAt, or last.createdAt
                      dynamic timeSource = c['lastMessageAt'] ?? c['updatedAt'];
                      if (timeSource == null && c['lastMessage'] is Map) {
                        timeSource = (c['lastMessage'] as Map)['createdAt'];
                      }
                      final time = _formatTime(timeSource);

                      // Unread count for USER side prefers unread.user when available
                      int unread = 0;
                      if (c['unread'] is Map) {
                        final u = (c['unread'] as Map)['user'];
                        unread = u is int ? u : int.tryParse((u ?? '0').toString()) ?? 0;
                      } else {
                        final unreadRaw = c['unreadCount'];
                        unread = unreadRaw is int ? unreadRaw : int.tryParse((unreadRaw ?? '0').toString()) ?? 0;
                      }

                      // Title/avatar should be the OTHER participant (tasker for user inbox)
                      String title = '';
                      String? avatar;
                      if (c['tasker'] is Map) {
                        final t = c['tasker'] as Map;
                        final fn = (t['firstName'] ?? '').toString();
                        final ln = (t['lastName'] ?? '').toString();
                        final full = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ').trim();
                        title = full.isNotEmpty ? full : (t['fullName'] ?? t['name'] ?? '').toString();
                        avatar = (t['profilePicture'] ?? t['avatarUrl'])?.toString();
                      }

                      // Fallbacks: explicit fields or participants array
                      if (title.isEmpty) {
                        title = (c['title'] ?? c['taskTitle'] ?? '').toString();
                      }
                      if ((avatar == null || avatar.isEmpty)) {
                        final avatarRaw = c['avatarUrl'];
                        avatar = avatarRaw is String ? avatarRaw : null;
                      }
                      if (title.isEmpty || avatar == null || avatar.isEmpty) {
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
                      }

                      return _buildMessageItem(
                        name: title,
                        message: preview.isEmpty ? 'Tap to open conversation' : preview,
                        time: time,
                        isRead: unread == 0,
                        unreadCount: unread,
                        profilePictureUrl: avatar,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserProfileHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userData = authProvider.userData;
        final dynamic user = userData != null ? userData['user'] : null;
        String? profilePictureUrl;
        String displayName = 'Loading...';
        if (user is Map) {
          profilePictureUrl = (user['profilePicture'] ?? user['avatarUrl']) as String?;
          displayName = (user['fullName'] ?? user['name'] ?? '')?.toString() ?? '';
          if (displayName.isEmpty) {
            final fn = (user['firstName'] ?? '').toString();
            final ln = (user['lastName'] ?? '').toString();
            displayName = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ');
          }
          if (displayName.isEmpty) displayName = 'User';
        } else if (user == null) {
          displayName = 'Loading...';
        } else {
          // user is likely an ID string
          displayName = 'User';
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info with avatar
              Row(
                children: [
                  ProfilePictureWidget(
                    profilePictureUrl: profilePictureUrl, // ignored
                    displayName: displayName,
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF606060),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'User',
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryColor.withOpacity(0.9),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Notification and settings icons
              // Row(
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         color: const Color(0xFFF7F5FB),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: SvgPicture.asset(
              //         'assets/icons/notification.svg',
              //         width: 24,
              //         height: 24,
              //         colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterTab(String title) {
    final bool isActive = _activeTab == title;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? primaryColor.withOpacity(0.1) 
              : const Color(0xFF606060).withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: isActive 
              ? null 
              : Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? primaryColor : Colors.black.withOpacity(0.6),
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageItem({
    required String name,
    required String message,
    required String time,
    required bool isRead,
    required int unreadCount,
    String? profilePictureUrl,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Profile avatar
            ProfilePictureWidget(
              profilePictureUrl: profilePictureUrl, // ignored
              displayName: name,
              radius: 25,
            ),
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      unreadCount > 0
                          ? Row(
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Geist',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              time,
                              style: TextStyle(
                                fontFamily: 'Geist',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Message preview
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.message_outlined,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF606060),
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start posting tasks and connecting\nwith taskers to begin conversations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> items) {
    if (_activeTab == 'Unread') {
      return items.where((c) => (c['unreadCount'] ?? 0) > 0).toList();
    }
    if (_activeTab == 'Read') {
      return items.where((c) => (c['unreadCount'] ?? 0) == 0).toList();
    }
    return items;
  }
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

