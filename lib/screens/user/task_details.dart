import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:intl/intl.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;
  
  const TaskDetailsScreen({
    super.key, 
    required this.taskId,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch task details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTaskById(widget.taskId);
    });
  }
  
  @override
  void dispose() {
    // Clear current task when leaving screen
    Provider.of<TaskProvider>(context, listen: false).clearCurrentTask();
    super.dispose();
  }
  
  // Format date from ISO string
  String _formatDate(String? dateString) {
    if (dateString == null) return 'No deadline';
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, _) {
            final taskStatus = taskProvider.status;
            final task = taskProvider.currentTask;
            
            // Show loading indicator while fetching data
            if (taskStatus == TaskStatus.loading || task == null) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Show error message if fetch failed
            if (taskStatus == TaskStatus.error) {
              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load task details',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (taskProvider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                taskProvider.errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontFamily: 'Geist',
                                ),
                              ),
                            ),
                          MaterialButton(
                            onPressed: () {
                              taskProvider.fetchTaskById(widget.taskId);
                            },
                            color: primaryColor,
                            textColor: Colors.white,
                            child: Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            
            // Extract task data
            final title = task['title'] ?? 'Untitled Task';
            final description = task['description'] ?? 'No description provided.';
            final deadline = _formatDate(task['deadline']);
            final categories = task['categories'] as List<dynamic>? ?? [];
            final category = categories.isNotEmpty 
                ? (categories[0]['displayName'] ?? categories[0]['name'] ?? 'Uncategorized')
                : 'Uncategorized';
            final budget = task['budget']?.toString() ?? '0';
            final images = task['images'] as List<dynamic>? ?? [];
            
            return Column(
              children: [
                _buildHeader(context),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 17),
                          
                          // Main task details card
                          Container(
                            width: 388,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromRGBO(96, 96, 96, 0.1),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Task details content
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 23,
                                    top: 53.63,
                                    right: 23,
                                    bottom: 23,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Task Title
                                      SizedBox(
                                        width: 116,
                                        height: 46.25,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Task Title',
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.4),
                                                fontSize: 15,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              title,
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.9),
                                                fontSize: 16,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.125,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 13),
                                      
                                      // Deadline
                                      SizedBox(
                                        width: 132,
                                        height: 46.5,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Deadline',
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.4),
                                                fontSize: 15,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              deadline,
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.9),
                                                fontSize: 16,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.125,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 13),
                                      
                                      // Category
                                      SizedBox(
                                        width: 126,
                                        height: 55,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Category',
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.4),
                                                fontSize: 15,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                             
                                              height: 23,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF693CB8).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                                                child: Text(
                                                  category,
                                                  style: TextStyle(
                                                    color: const Color(0xFF673AB7).withOpacity(0.9),
                                                    fontSize: 15,
                                                    fontFamily: 'Geist',
                                                    fontWeight: FontWeight.w500,
                                                
                                                    height: 1.2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 13),
                                      
                                                                            // Task Description
                                      SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Task Description',
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.4),
                                                fontSize: 15,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              description,
                                              style: TextStyle(
                                                color: const Color(0xFF606060).withOpacity(0.9),
                                                fontSize: 16,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -0.5,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Price badge
                                Positioned(
                                  right: 23,
                                  top: 18,
                                  child: Container(
                                    width: 103,
                                    height: 29,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF20B37D).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                                                          child: Center(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: '₦',
                                                style: TextStyle(
                                                  color: Color(0xFF00A86B),
                                                  fontSize: 20,
                                                  fontFamily: 'Arial',
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.5,
                                                  height: 0.7,
                                                ),
                                              ),
                                              TextSpan(
                                                text: budget,
                                                style: const TextStyle(
                                                  color: Color(0xFF00A86B),
                                                  fontSize: 20,
                                                  fontFamily: 'Geist',
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: -0.5,
                                                  height: 0.7,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Task Images section - only show if there are images
                          if (images.isNotEmpty)
                            Container(
                              width: 388,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color.fromRGBO(96, 96, 96, 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.only(left: 27, top: 24, right: 27),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Task Images',
                                          style: TextStyle(
                                            color: const Color(0xFF000000).withOpacity(0.4),
                                            fontSize: 15,
                                            fontFamily: 'Geist',
                                            fontWeight: FontWeight.w600,
                                            height: 0.93,
                                          ),
                                        ),
                                        Text(
                                          'Click to zoom',
                                          style: TextStyle(
                                            color: const Color(0xFF000000).withOpacity(0.2),
                                            fontSize: 13,
                                            fontFamily: 'Geist',
                                            fontWeight: FontWeight.w600,
                                            height: 1.08,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 21),
                                  
                                  // Images grid
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                    child: Wrap(
                                      spacing: 7,
                                      runSpacing: 7,
                                      children: [
                                        // Display actual task images from API
                                        for (var image in images)
                                          _buildNetworkImageContainer(image['url']),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
  
  // Header with back button and title
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Back button
          Positioned(
            left: 17,
            top: 17,
            child: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF606060),
                  size: 14,
                ),
              ),
            ),
          ),
          // Title
          const Positioned(
            left: 158,
            top: 25,
            child: Text(
              'Task Details',
              style: TextStyle(
                color: Color(0xFF606060),
                fontSize: 20,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                height: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget for displaying network images
  Widget _buildNetworkImageContainer(String imageUrl) {
    return Container(
      width: 77,
      height: 77,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  
  // Fallback widget for displaying local images
  Widget _buildImageContainer(String imagePath) {
    return Container(
      width: 77,
      height: 77,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
} 