import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/user/chat_screen.dart';
import 'package:taskhub/theme/const_value.dart';

class TaskerMessagesScreen extends StatefulWidget {
  const TaskerMessagesScreen({super.key});

  @override
  State<TaskerMessagesScreen> createState() => _TaskerMessagesScreenState();
}

class _TaskerMessagesScreenState extends State<TaskerMessagesScreen> {
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: SvgPicture.asset(
                        'assets/icons/notification.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
                      ),
                      onPressed: () {
                        // Handle notification
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Search bar
              _buildSearchBar(),
              
              const SizedBox(height: 24),
              
              // Messages list
              Expanded(
                child: _buildMessagesList(),
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

  Widget _buildMessagesList() {
    final demoMessages = [
      {
        'name': 'John Doe',
        'message': 'Thank you for the excellent cleaning service!',
        'time': '2 min ago',
        'avatar': 'assets/images/profile-picture.png',
        'unread': true,
        'task': 'House Cleaning',
      },
      {
        'name': 'Jane Smith',
        'message': 'The groceries have been delivered safely.',
        'time': '1 hour ago',
        'avatar': 'assets/images/profile-picture.png',
        'unread': false,
        'task': 'Grocery Shopping',
      },
      {
        'name': 'Mike Johnson',
        'message': 'Great job on the garden maintenance!',
        'time': '2 days ago',
        'avatar': 'assets/images/profile-picture.png',
        'unread': false,
        'task': 'Garden Maintenance',
      },
    ];

    if (demoMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: demoMessages.length,
      itemBuilder: (context, index) {
        final message = demoMessages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildMessageItem(message),
        );
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              contactName: message['name'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: message['unread'] ? primaryColor : Colors.grey.shade700,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  message['avatar'],
                  fit: BoxFit.cover,
                ),
              ),
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
                        message['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: message['unread'] ? FontWeight.w600 : FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Geist',
                        ),
                      ),
                      Text(
                        message['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: message['unread'] ? primaryColor : Colors.grey.shade500,
                          fontFamily: 'Geist',
                          fontWeight: message['unread'] ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Task: ${message['task']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor.withOpacity(0.8),
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            fontSize: 14,
                            color: message['unread'] ? Colors.white : Colors.grey.shade400,
                            fontFamily: 'Geist',
                            fontWeight: message['unread'] ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (message['unread'])
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
} 