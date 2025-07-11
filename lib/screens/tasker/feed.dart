import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/theme/const_value.dart';

class TaskerFeedScreen extends StatefulWidget {
  const TaskerFeedScreen({super.key});

  @override
  State<TaskerFeedScreen> createState() => _TaskerFeedScreenState();
}

class _TaskerFeedScreenState extends State<TaskerFeedScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Cleaning',
    'Delivery',
    'Handyman',
    'Moving',
    'Gardening',
    'Tech Support',
    'Tutoring',
    'Beauty',
    'Catering'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore Tasks',
          style: TextStyle(
            fontFamily: 'Geist',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement filter functionality
            },
            icon: SvgPicture.asset(
              'assets/icons/arrange-square.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          _buildCategoryFilter(),
          
          // Task list
          Expanded(
            child: _buildTaskList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade700,
                  width: 1,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    // Mock task data - in real app this would come from API
    final tasks = _getMockTasks();
    
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/activity-icon.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks available',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new opportunities',
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task['category'],
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₦${task['budget']}',
                style: const TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Task title
          Text(
            task['title'],
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Task description
          Text(
            task['description'],
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Task details
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                task['location'],
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                task['timeAgo'],
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockTasks() {
    // Filter tasks based on selected category
    final allTasks = [
      {
        'title': 'Deep House Cleaning',
        'description': 'Need thorough cleaning of 3-bedroom apartment including kitchen and bathrooms',
        'category': 'Cleaning',
        'budget': '15,000',
        'location': 'Victoria Island, Lagos',
        'timeAgo': '2 hours ago',
      },
      {
        'title': 'Grocery Delivery',
        'description': 'Pick up groceries from Shoprite and deliver to my home',
        'category': 'Delivery',
        'budget': '3,500',
        'location': 'Ikeja, Lagos',
        'timeAgo': '4 hours ago',
      },
      {
        'title': 'Fix Leaking Faucet',
        'description': 'Kitchen faucet is leaking and needs immediate repair',
        'category': 'Handyman',
        'budget': '8,000',
        'location': 'Lekki, Lagos',
        'timeAgo': '6 hours ago',
      },
      {
        'title': 'Moving Assistance',
        'description': 'Help with packing and moving from 2-bedroom apartment',
        'category': 'Moving',
        'budget': '25,000',
        'location': 'Surulere, Lagos',
        'timeAgo': '1 day ago',
      },
      {
        'title': 'Garden Maintenance',
        'description': 'Weekly garden maintenance including watering and pruning',
        'category': 'Gardening',
        'budget': '12,000',
        'location': 'Ikoyi, Lagos',
        'timeAgo': '1 day ago',
      },
      {
        'title': 'Computer Setup',
        'description': 'Set up new laptop and install necessary software',
        'category': 'Tech Support',
        'budget': '7,500',
        'location': 'Yaba, Lagos',
        'timeAgo': '2 days ago',
      },
    ];

    if (selectedCategory == 'All') {
      return allTasks;
    }
    
    return allTasks.where((task) => task['category'] == selectedCategory).toList();
  }
} 