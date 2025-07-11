import 'package:flutter/material.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  
  const ChatScreen({
    super.key, 
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Sample messages data - in a real app this would come from a database
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "I'll send you the cash soon",
      isMe: false,
      time: "12:35PM",
    ),
    ChatMessage(
      text: "Hey let's work alright, hmu",
      isMe: false,
      time: "12:35PM",
    ),
    ChatMessage(
      text: "I'll send you the cash soon",
      isMe: false,
      time: "12:35PM",
    ),
    ChatMessage(
      text: "Okay I'm waiting on you, the dishwasher is behind the fridge",
      isMe: true,
      time: "12:35PM",
    ),
    ChatMessage(
      text: "Have you seen the industrial setup we need to work on? It looks complex.",
      isMe: true,
      time: "12:35PM",
      imagePath: "assets/images/industrial_setup.jpg",
    ),
    ChatMessage(
      text: "I'm home. i'll find where to keep the key",
      isMe: true,
      time: "12:35PM",
    ),
    ChatMessage(
      text: "I kept it on the Table",
      isMe: true,
      time: "12:35PM",
    ),
  ];
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isMe: true,
          time: "${DateTime.now().hour}:${DateTime.now().minute}",
        ),
      );
      
      _messageController.clear();
    });
    
    // Scroll to the bottom after sending a message
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildChatAppBar(),
            
            // Date divider
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  
                  return Align(
                    alignment: message.isMe 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildMessageBubble(message),
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
                backgroundImage: const AssetImage('assets/images/church_profile.jpg'),
              ),
              const SizedBox(width: 12),
              
              // Contact name and status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
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
  
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.isMe 
            ? primaryColor 
            : const Color(0xFFF7F5FB).withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message text
          Text(
            message.text,
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: message.isMe 
                  ? Colors.white.withOpacity(0.9) 
                  : Colors.black.withOpacity(0.6),
            ),
          ),
          
          // Image if present
          if (message.imagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  message.imagePath!,
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
                message.time,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: message.isMe 
                      ? Colors.white.withOpacity(0.9) 
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              if (message.isMe) ...[
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
                  IconButton(
                    onPressed: () {
                      // Handle attachment functionality
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/chat/add_circle.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF292D32).withOpacity(0.5),
                        BlendMode.srcIn,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
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
              child: SvgPicture.asset(
                'assets/icons/chat/send_icon.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final String? imagePath;
  
  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.imagePath,
  });
} 