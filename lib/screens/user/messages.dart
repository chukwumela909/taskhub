import 'package:flutter/material.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/screens/user/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _activeTab = 'All'; // Track active filter tab

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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildMessageItem(
                    name: 'Mazikeen O\'Keen',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Lucifer Morningstar',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Jon Snow',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Mike Ross',
                    message: 'Are you sure he left the house...',
                    time: '12:35PM',
                    isRead: false,
                    unreadCount: 1,
                  ),
                  _buildMessageItem(
                    name: 'Walter White',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Gus Fring',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Bryan Cranston',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                  _buildMessageItem(
                    name: 'Eren Jaeger',
                    message: 'You: I kept it on the Table',
                    time: '12:35PM',
                    isRead: true,
                    unreadCount: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User info with avatar
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const AssetImage('assets/images/church_profile.jpg'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Samson Richfield',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF606060),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Taskhub User',
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/notification.svg',
                  width: 24,
                  height: 24,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/setting.svg',
                  width: 24,
                  height: 24,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
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
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(contactName: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundImage: const AssetImage('assets/images/church_profile.jpg'),
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
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
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
}

