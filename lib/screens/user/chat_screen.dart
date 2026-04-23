import 'package:flutter/material.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/chat_provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String title;
  final String? avatarUrl;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.avatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _headerTitle;
  String? _headerAvatar;

  // Regex patterns for validation
  static final _emailRegex = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    caseSensitive: false,
  );
  
  static final _nigerianPhoneRegex = RegExp(
    r'(\+234|234|0)?[7-9][0-1]\d{8}|(\+234|234|0)?[8][0-1]\d{8}',
  );
  
  // Common curse words and inappropriate content
  static final List<String> _curseWords = [
    'damn', 'hell', 'stupid', 'idiot', 'fool', 'bastard', 'bitch', 'asshole',
    'shit', 'fuck', 'fucking', 'motherfucker', 'crap', 'piss', 'dickhead',
    'dumbass', 'retard', 'moron', 'imbecile', 'jackass', 'twat', 'slut',
    'whore', 'cock', 'dick', 'pussy', 'tits', 'ass', 'nigga', 'niger',
    'faggot', 'gay', 'lesbian', 'homo', 'dyke', 'tranny', 'chink', 'spic',
    'wetback', 'kike', 'raghead', 'towelhead', 'paki', 'wop', 'guinea',
    'kraut', 'limey', 'frog', 'polack', 'gook', 'slope', 'nip', 'jap',
    'beaner', 'spade', 'coon', 'honky', 'cracker', 'redneck', 'hillbilly',
    'porn', 'sex', 'naked', 'nude', 'drugs', 'weed', 'marijuana', 'cocaine',
    'heroin', 'kill', 'murder', 'suicide', 'bomb', 'terrorist', 'weapon',
    'gun', 'knife', 'violence', 'rape', 'abuse', 'hate', 'scam', 'fraud'
  ];

  static final _curseWordsRegex = RegExp(
    '\\b(${_curseWords.join('|')})\\b',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    // Load latest messages and mark as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chat = context.read<ChatProvider>();
      chat.fetchMessages(widget.conversationId, refresh: true).then((_) {
        // After loading, scroll to bottom
        _scrollToBottom();
      });
      chat.markRead(widget.conversationId);
      _loadConversationHeader();
    });
  }

  Future<void> _loadConversationHeader() async {
    try {
      final auth = context.read<AuthProvider>();
      final userData = auth.userData;
      final user = userData != null ? userData['user'] : null;
      final uid = (user is Map) ? (user['_id'] ?? user['id'] ?? user['uuid'] ?? '').toString() : '';
      final conv = await ChatService().getConversation(widget.conversationId);
      final peer = _otherParticipant(conv['participants'], uid);
      final name = _displayName(peer);
      final avatar = _avatarUrl(peer);
      if (mounted) {
        setState(() {
          _headerTitle = (name?.isNotEmpty ?? false) ? name : widget.title;
          _headerAvatar = (avatar?.isNotEmpty ?? false) ? avatar : widget.avatarUrl;
        });
      }
    } catch (_) {
      // ignore, keep provided title/avatar
    }
  }

  // Validate message content
  String? _validateMessage(String message) {
    final trimmedMessage = message.trim();
    
    if (trimmedMessage.isEmpty) {
      return null; // Empty messages are handled elsewhere
    }
    
    // Check for emails
    if (_emailRegex.hasMatch(trimmedMessage)) {
      return 'Messages containing email addresses are not allowed for your safety.';
    }
    
    // Check for Nigerian phone numbers
    if (_nigerianPhoneRegex.hasMatch(trimmedMessage)) {
      return 'Messages containing phone numbers are not allowed for your safety.';
    }
    
    // Check for curse words
    if (_curseWordsRegex.hasMatch(trimmedMessage)) {
      return 'Please keep the conversation respectful and avoid inappropriate language.';
    }
    
    return null; // Message is valid
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    // Validate message content
    final validationError = _validateMessage(text);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return; // Don't send the message
    }
    
    final chat = context.read<ChatProvider>();
    final auth = context.read<AuthProvider>();

    // Build optimistic local message
    String uid = '';
    try {
      final ud = auth.userData;
      final u = ud != null ? ud['user'] : null;
      uid = (u?['_id'] ?? u['id'] ?? u['uuid'] ?? '').toString();
    } catch (_) {}
    final isTasker = auth.isTasker;
    final localMsg = {
      '_local': true,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'isMine': true,
      'senderType': isTasker ? 'tasker' : 'user',
      if (isTasker) 'senderTasker': uid else 'senderUser': uid,
      'sender': {'_id': uid},
    };
    chat.appendLocalMessage(widget.conversationId, localMsg);
    _messageController.clear();
    _scrollToBottom();

    // Send to server
    final created = await chat.sendMessage(widget.conversationId, text: text);
    if (created != null) {
      chat.replaceLastLocalMessage(widget.conversationId, created);
      _scrollToBottom();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final raw = chat.messagesFor(widget.conversationId);
    final messages = List<Map<String, dynamic>>.from(raw);
    messages.sort((a, b) {
      final ta = DateTime.tryParse((a['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = DateTime.tryParse((b['createdAt'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ta.compareTo(tb);
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildChatAppBar(),
            
            // Date divider
            if (messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            
            // Chat messages
            Expanded(
              child: chat.messagesLoading(widget.conversationId)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        // System messages are centered
                        final senderType = (msg['senderType'] ?? '').toString();
                        if (senderType == 'system') {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (msg['text'] ?? '').toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Geist',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF606060),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }
                        var isMe = _isMe(auth, msg);
                        if (!isMe) {
                          // Handle special self marker
                          final sid = _extractMessageSenderId(msg);
                          if (sid == '__SELF__') isMe = true;
                        }
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildMessageBubble(
                              text: (msg['text'] ?? '').toString(),
                              isMe: isMe,
                              time: _formatTime(msg['createdAt']),
                              imageUrl: null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.09),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and contact info
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/chat/back_arrow.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF606060),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Contact avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: (() {
                  final url = _headerAvatar ?? widget.avatarUrl;
                  if (url != null && url.isNotEmpty) {
                    return NetworkImage(url);
                  }
                  return const AssetImage('assets/images/church_profile.jpg') as ImageProvider;
                })(),
              ),
              const SizedBox(width: 12),
              
              // Contact name and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (_headerTitle != null && _headerTitle!.isNotEmpty) ? _headerTitle! : widget.title,
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF606060),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'active 2 mins ago',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF606060).withOpacity(0.4),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Call button
          SvgPicture.asset(
            'assets/icons/chat/call_icon.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Color(0xFF292D32),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
    String? imageUrl,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe 
            ? primaryColor 
            : const Color(0xFFF7F5FB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message text
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isMe 
                  ? Colors.white.withOpacity(0.9) 
                  : Colors.black.withOpacity(0.6),
            ),
          ),
          
          // Image if present
          if (imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Message timestamp and read receipt
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isMe 
                      ? Colors.white.withOpacity(0.9) 
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/chat/checkmark_1.svg',
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message input field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7FC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Your message',
                        hintStyle: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  
                  // Attachment button
                  // IconButton(
                  //   onPressed: () {
                  //     // Handle attachment functionality
                  //   },
                  //   icon: Icon(Icons.add_circle),
                  //   padding: EdgeInsets.zero,
                  //   constraints: const BoxConstraints(),
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.send, color: Colors.white,)
            ),
          ),
        ],
      ),
    );
  }
}
  
bool _isMe(AuthProvider auth, Map<String, dynamic> msg) {
  try {
    final myId = _extractCurrentUserId(auth.userData);
    if (myId.isEmpty) return false;
    // Prefer senderType-specific ids for exact match
    final st = (msg['senderType'] ?? '').toString();
    if (st.isNotEmpty) {
      if (auth.isTasker && st == 'tasker') {
        final sid = (msg['senderTasker'] ?? '').toString();
        if (sid.isNotEmpty) return sid == myId;
      } else if (!auth.isTasker && st == 'user') {
        final sid = (msg['senderUser'] ?? '').toString();
        if (sid.isNotEmpty) return sid == myId;
      }
    }
    final senderId = _extractMessageSenderId(msg);
    if (senderId.isEmpty) return false;
    if (senderId == '__SELF__') return true;
    return senderId == myId;
  } catch (_) {
    return false;
  }
}

String _extractCurrentUserId(dynamic userData) {
  try {
    if (userData == null) return '';
    if (userData is Map) {
      final u = userData['user'] ?? userData['tasker'] ?? userData;
      if (u is Map) {
        final id = (u['_id'] ?? u['id'] ?? u['uuid'] ?? '').toString();
        return id;
      }
      if (u is String) return u;
    }
  } catch (_) {}
  return '';
}

String _extractId(dynamic v) {
  if (v is Map) return (v['_id'] ?? v['id'] ?? v['uuid'] ?? '').toString();
  if (v is String) return v;
  return '';
}

String _extractMessageSenderId(Map<String, dynamic> msg) {
  // Prefer explicit boolean if server provides
  if (msg['isMine'] == true || msg['fromSelf'] == true) {
    return '__SELF__';
  }
  // Handle senderType + senderUser/senderTasker pattern
  final st = (msg['senderType'] ?? '').toString();
  if (st == 'user' && msg['senderUser'] != null) {
    return (msg['senderUser'] ?? '').toString();
  }
  if (st == 'tasker' && msg['senderTasker'] != null) {
    return (msg['senderTasker'] ?? '').toString();
  }
  final candidatesNested = ['sender', 'from', 'user', 'author', 'createdBy', 'owner', 'tasker', 'by'];
  for (final k in candidatesNested) {
    if (msg.containsKey(k)) {
      final id = _extractId(msg[k]);
      if (id.isNotEmpty) return id;
    }
  }
  final candidatesFlat = ['senderId', 'fromId', 'userId', 'authorId', 'createdById', 'ownerId', 'taskerId', 'byId'];
  for (final k in candidatesFlat) {
    if (msg.containsKey(k)) {
      final id = (msg[k] ?? '').toString();
      if (id.isNotEmpty) return id;
    }
  }
  return '';
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

dynamic _otherParticipant(dynamic participants, String myId) {
  if (participants is List) {
    for (final p in participants) {
      if (p is Map) {
        final id = (p['_id'] ?? p['id'] ?? p['uuid'] ?? '').toString();
        if (id.isEmpty || myId.isEmpty) return p;
        if (id != myId) return p;
      } else if (p is String) {
        if (p != myId) return {'_id': p};
      }
    }
  }
  return null;
}

String? _displayName(dynamic user) {
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

String? _avatarUrl(dynamic user) {
  if (user is Map) {
    final url = (user['profilePicture'] ?? user['avatarUrl'])?.toString();
    if (url != null && url.trim().isNotEmpty) return url;
  }
  return null;
}