import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskhub/theme/const_value.dart';

class TaskerHistoryScreen extends StatefulWidget {
  const TaskerHistoryScreen({super.key});

  @override
  State<TaskerHistoryScreen> createState() => _TaskerHistoryScreenState();
}

class _TaskerHistoryScreenState extends State<TaskerHistoryScreen> {
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
                    'Task History',
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
              
              // Filter tabs
              _buildFilterTabs(),
              
              const SizedBox(height: 24),
              
              // History list
              Expanded(
                child: _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _buildFilterTab('All', true),
        const SizedBox(width: 12),
        _buildFilterTab('Completed', false),
        const SizedBox(width: 12),
        _buildFilterTab('In Progress', false),
      ],
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade700,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade400,
          fontFamily: 'Geist',
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final demoTasks = [
      {
        'title': 'House Cleaning',
        'client': 'John Doe',
        'amount': '₦5,000',
        'date': '2 days ago',
        'status': 'Completed',
        'rating': 5,
      },
      {
        'title': 'Grocery Shopping',
        'client': 'Jane Smith',
        'amount': '₦3,500',
        'date': '1 week ago',
        'status': 'Completed',
        'rating': 4,
      },
      {
        'title': 'Garden Maintenance',
        'client': 'Mike Johnson',
        'amount': '₦8,000',
        'date': '2 weeks ago',
        'status': 'Completed',
        'rating': 5,
      },
    ];

    if (demoTasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: demoTasks.length,
      itemBuilder: (context, index) {
        final task = demoTasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: _buildHistoryItem(task),
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> task) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Geist',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${task['client']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    task['amount'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      fontFamily: 'Geist',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task['status'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                        fontFamily: 'Geist',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task['date'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontFamily: 'Geist',
                ),
              ),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 16,
                      color: index < task['rating']
                          ? Colors.amber
                          : Colors.grey.shade600,
                    );
                  }),
                  const SizedBox(width: 4),
                  Text(
                    '(${task['rating']})',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontFamily: 'Geist',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
              Icons.history,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Task History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your first task to see\nyour history here.',
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