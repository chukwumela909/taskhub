import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/chat_provider.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:intl/intl.dart';
import 'package:taskhub/screens/user/chat_screen.dart';

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
      final tp = Provider.of<TaskProvider>(context, listen: false);
      tp.fetchTaskById(widget.taskId).then((ok) async {
        if (!ok) return;
        // After loading task, try to fetch bids (owners only). We'll gate render later.
        await tp.fetchTaskBids(widget.taskId);
      });
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

  // Open image viewer with gallery navigation
  void _openImageViewer(BuildContext context, String currentImageUrl, List<dynamic> allImages) {
    // Extract all image URLs
  final imageUrls = allImages
    .map((img) => img['url'])
    .where((u) => u != null)
    .map((u) => u.toString())
    .toList();
    final currentIndex = imageUrls.indexOf(currentImageUrl);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageUrls: imageUrls,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
        ),
      ),
    );
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
            final status = (task['status'] ?? 'open').toString().toLowerCase();
            final isEscrowHeld = (task['isEscrowHeld'] ?? task['escrowHeld'] ?? false) == true;
            final escrowAmount = (task['escrowAmount'] ?? task['budget'])?.toString();
            final assignedTo = task['assignedTo'] ?? task['tasker'];
            String? assignedName;
            String? assignedAvatar;
            if (assignedTo is Map) {
              final full = (assignedTo['fullName'] ?? assignedTo['name'])?.toString();
              if (full != null && full.trim().isNotEmpty) assignedName = full;
              assignedAvatar = (assignedTo['profilePicture'] ?? assignedTo['avatarUrl'])?.toString();
            }
            String _categoryLabel(dynamic value) {
              if (value == null) return 'Uncategorized';
              if (value is Map) {
                final display = value['displayName'] ?? value['name'];
                final s = display?.toString().trim() ?? '';
                return s.isNotEmpty ? s : 'Uncategorized';
              }
              if (value is String) {
                return value.isNotEmpty ? value : 'Uncategorized';
              }
              return 'Uncategorized';
            }
            final category = categories.isNotEmpty
                ? _categoryLabel(categories.first)
                : 'Uncategorized';
            final budget = task['budget']?.toString() ?? '0';
            final images = task['images'] as List<dynamic>? ?? [];
            // Determine ownership: server may embed user as id or object
            final ownerId = (() {
              final u = task['user'];
              if (u is String) return u;
              if (u is Map) return (u['_id'] ?? u['id'] ?? '').toString();
              return '';
            })();
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final currentUserId = (auth.userData != null)
                ? ((auth.userData!['user'] is Map)
                    ? (auth.userData!['user']['_id'] ?? auth.userData!['user']['id'] ?? '').toString()
                    : (auth.userData!['_id'] ?? auth.userData!['id'] ?? '').toString())
                : '';
            final isOwner = ownerId.isNotEmpty && ownerId == currentUserId;
            
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
                            width: double.infinity,
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
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Task Title
                                      Column(
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
                                              height: 1.25,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 13),

                                      // Deadline
                                      Column(
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
                                              height: 1.25,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 13),

                                      // Category
                                      Column(
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
                                            constraints: const BoxConstraints(minHeight: 23),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF693CB8).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                              child: Text(
                                                category,
                                                style: TextStyle(
                                                  color: const Color(0xFF673AB7).withOpacity(0.9),
                                                  fontSize: 14,
                                                  fontFamily: 'Geist',
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.2,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                                height: 1.35,
                                              ),
                                              softWrap: true,
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
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF20B37D).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: '₦',
                                              style: TextStyle(
                                                color: Color(0xFF00A86B),
                                                fontSize: 18,
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: budget,
                                              style: const TextStyle(
                                                color: Color(0xFF00A86B),
                                                fontSize: 18,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isEscrowHeld)
                                  Positioned(
                                    left: 23,
                                    top: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF673AB7).withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.25)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.lock_outline, size: 14, color: Color(0xFF673AB7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Escrow: ₦${escrowAmount ?? budget}',
                                            style: const TextStyle(
                                              color: Color(0xFF673AB7),
                                              fontSize: 12,
                                              fontFamily: 'Geist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                              width: double.infinity,
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
                                          GestureDetector(
                                            onTap: () => _openImageViewer(context, image['url'], images),
                                            child: Stack(
                                              children: [
                                                _buildNetworkImageContainer(image['url']),
                                                // Subtle overlay to indicate clickability
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: Colors.black.withOpacity(0.1),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.fullscreen,
                                                        color: Colors.white,
                                                        size: 16,
                                                        shadows: [
                                                          Shadow(
                                                            color: Colors.black54,
                                                            blurRadius: 2,
                                                            offset: Offset(0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          if (assignedName != null && assignedName.isNotEmpty)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color.fromRGBO(96, 96, 96, 0.1)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    backgroundImage: (assignedAvatar != null && assignedAvatar.isNotEmpty)
                                        ? NetworkImage(assignedAvatar)
                                        : null,
                                    child: (assignedAvatar == null || assignedAvatar.isEmpty)
                                        ? Text(
                                            assignedName[0].toUpperCase(),
                                            style: const TextStyle(color: Color(0xFF606060), fontFamily: 'Geist'),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Assigned to $assignedName',
                                      style: const TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 14,
                                        fontFamily: 'Geist',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF9F6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'ASSIGNED',
                                      style: TextStyle(
                                        color: Color(0xFF00A86B),
                                        fontSize: 12,
                                        fontFamily: 'Geist',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 12),
                          if (isOwner) _BidsSection(taskId: widget.taskId),

                          const SizedBox(height: 20),
                          if (isOwner && (status == 'open' || status == 'assigned'))
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Cancel task?'),
                                      content: Text(status == 'assigned'
                                          ? 'This will cancel the task and refund escrow to your wallet.'
                                          : 'This will cancel the task.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, cancel')),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;
                                  final tp = Provider.of<TaskProvider>(context, listen: false);
                                  final ok = await tp.cancelTaskAsUser(widget.taskId);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(ok ? 'Task cancelled${status == 'assigned' ? ' and refunded' : ''}.' : tp.errorMessage ?? 'Failed to cancel'),
                                  ));
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel task'),
                                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB00020)),
                              ),
                            ),
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
      child: Row(
        children: [
          const SizedBox(width: 17),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF606060),
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Task Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF606060),
                fontSize: 20,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 60), // balance right side spacing
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

class _BidsSection extends StatelessWidget {
  final String taskId;
  const _BidsSection({required this.taskId});
  String _bidderName(dynamic bidder) {
    if (bidder is Map) {
      final full = bidder['fullName'] ?? bidder['name'];
      if (full is String && full.trim().isNotEmpty) return full;
      final fn = bidder['firstName'];
      final ln = bidder['lastName'];
      final joined = [fn, ln].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ').trim();
      if (joined.isNotEmpty) return joined;
    }
    return 'Tasker';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, tp, _) {
      final loading = tp.taskBidsLoading;
      final error = tp.taskBidsError;
      final bids = tp.taskBids;

    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
      // Removed outside border to give inner cards more room
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 20, right: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applications/Bids',
                    style: TextStyle(
                      color: const Color(0xFF000000).withOpacity(0.4),
                      fontSize: 15,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 8),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontFamily: 'Geist'),
                ),
              ),

            if (!loading && bids.isEmpty && error == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 14),
                child: Text(
                  'No applications yet. You will see taskers’ bids here.',
                  style: TextStyle(
                    color: const Color(0xFF000000).withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Geist',
                  ),
                ),
              ),

            if (bids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 18),
                child: Column(
                  children: bids.map((b) {
                    final amount = (b['amount'] ?? b['offer'] ?? '').toString();
                    final msg = (b['message'] ?? '').toString();
                    final status = (b['status'] ?? 'pending').toString();
                    final bidder = b['tasker'] ?? b['bidder'] ?? b['user'];
                    final name = _bidderName(bidder);
                    final bidId = (b['_id'] ?? b['id'] ?? '').toString();
                    final taskerId = (() {
                      if (bidder is String) return bidder;
                      if (bidder is Map) return (bidder['_id'] ?? bidder['id'] ?? '').toString();
                      return '';
                    })();
                    final avatarUrl = (bidder is Map) ? (bidder['profilePicture'] ?? bidder['avatarUrl'] ?? '') as String? : null;
                    final createdAt = (b['createdAt'] ?? b['date'] ?? '').toString();
                    return Container(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromRGBO(96, 96, 96, 0.1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFF5F5F5),
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'T',
                                    style: const TextStyle(
                                      color: Color(0xFF606060),
                                      fontFamily: 'Geist',
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 14,
                                        fontFamily: 'Geist',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (amount.isNotEmpty)
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: '₦',
                                              style: TextStyle(
                                                color: Color(0xFF00A86B),
                                                fontSize: 14,
                                                fontFamily: 'Arial',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            TextSpan(
                                              text: amount,
                                              style: const TextStyle(
                                                color: Color(0xFF00A86B),
                                                fontSize: 14,
                                                fontFamily: 'Geist',
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                if (msg.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    msg,
                                    style: TextStyle(
                                      color: const Color(0xFF606060).withOpacity(0.9),
                                      fontSize: 13,
                                      fontFamily: 'Geist',
                                    ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Actions and meta row now wraps to avoid horizontal overflow
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: status == 'pending'
                                                ? const Color(0xFFFFF4E5)
                                                : status == 'accepted'
                                                    ? const Color(0xFFE8FFF3)
                                                    : const Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: status == 'pending'
                                                  ? const Color(0xFFB26A00)
                                                  : status == 'accepted'
                                                      ? const Color(0xFF00A86B)
                                                      : const Color(0xFF606060),
                                              fontSize: 12,
                                              fontFamily: 'Geist',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat('MMM d, y').format(
                                            () {
                                              try {
                                                return DateTime.parse(createdAt).toLocal();
                                              } catch (_) {
                                                return DateTime.now();
                                              }
                                            }(),
                                          ),
                                          style: TextStyle(
                                            color: const Color(0xFF000000).withOpacity(0.4),
                                            fontSize: 12,
                                            fontFamily: 'Geist',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (status == 'pending')
                                          ElevatedButton(
                                            onPressed: () async {
                                              final tp = Provider.of<TaskProvider>(context, listen: false);
                                              final ok = await tp.acceptBid(bidId: bidId, taskId: taskId);
                                              if (!context.mounted) return;
                                              if (ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Bid accepted. Escrow held.')),
                                                );
                                              } else {
                                                final err = (tp.errorMessage ?? 'Failed to accept bid');
                                                final insufficient = err.toLowerCase().contains('insufficient');
                                                if (insufficient) {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text('Insufficient wallet balance'),
                                                      content: const Text('You don\'t have enough balance to hold escrow. Please top up your wallet and try again.'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                                                        // If there\'s a wallet screen, navigate there; else just close.
                                                        TextButton(onPressed: () { Navigator.pop(context); /* TODO: Navigate to wallet */ }, child: const Text('Top up')),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              textStyle: const TextStyle(fontFamily: 'Geist', fontWeight: FontWeight.w600),
                                            ),
                                            child: const Text('Accept'),
                                          ),
                                        const SizedBox(width: 6),
                                        Tooltip(
                                          message: 'Message',
                                          child: IconButton(
                                            onPressed: () => _openMessage(context, bidId: bidId, taskerId: taskerId, name: name, avatarUrl: avatarUrl),
                                            icon: const Icon(Icons.message_outlined),
                                            color: primaryColor,
                                            splashRadius: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _openMessage(BuildContext context, {required String bidId, required String taskerId, required String name, String? avatarUrl}) async {
    try {
      final chat = Provider.of<ChatProvider>(context, listen: false);
      // Prefer using taskId + bidId to resolve/create the conversation
      final convo = await chat.openConversation(taskId: taskId, bidId: bidId, taskerId: taskerId);
      if (convo == null) return;
      final convoId = (convo['_id'] ?? convo['id']).toString();
      final title = (convo['title'] ?? name).toString();
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: convoId,
            title: title,
            avatarUrl: avatarUrl,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

// Full-screen image viewer with gallery navigation
class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main image viewer
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Geist',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Image counter (if multiple images)
            if (widget.imageUrls.length > 1)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            // Navigation arrows (if multiple images)
            if (widget.imageUrls.length > 1) ...[
              // Previous button
              if (_currentIndex > 0)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Next button
              if (_currentIndex < widget.imageUrls.length - 1)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
} 