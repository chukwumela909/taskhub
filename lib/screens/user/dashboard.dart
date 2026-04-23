import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/screens/user/post_task.dart';
import 'package:taskhub/screens/user/task_details.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';
import 'package:taskhub/services/preferences_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  Timer? _refreshTimer;
  final int _refreshIntervalSeconds = 2; // Refresh every 30 seconds
  DateTime _lastRefreshed = DateTime.now();
  // Walkthrough state (FAB highlight)
  final GlobalKey _postTaskFabKey = GlobalKey();
  OverlayEntry? _postTaskWalkthroughEntry;
  bool _walkthroughShownThisSession = false;
  // Walkthrough and arrow removed
  
  @override
  void initState() {
    super.initState();
    // Register observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Only fetch data if not already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _fetchDataIfNeeded();
      _maybeShowPostTaskWalkthrough();
    });
    
    // Set up periodic refresh timer
    _refreshTimer = Timer.periodic(Duration(seconds: _refreshIntervalSeconds), (_) {
      _fetchData(showLoading: false);
    });
  }
  
  @override
  void dispose() {
    // Cancel timer when widget is disposed
    _refreshTimer?.cancel();
    // Remove lifecycle observer
  WidgetsBinding.instance.removeObserver(this);
  _postTaskWalkthroughEntry?.remove();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only refresh data when app comes back to foreground if it's been a while
    if (state == AppLifecycleState.resumed) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshed);
      // Only fetch if it's been more than 5 minutes since last refresh
      if (timeSinceLastRefresh.inMinutes > 5) {
        _fetchData(showLoading: false);
      }
    }
  }
  
  // Fetch data only if needed (not already loaded)
  Future<void> _fetchDataIfNeeded() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Ensure user data is loaded first
    if (authProvider.userData == null) {
      await authProvider.fetchUserData();
    }
    // Derive current user id for scoping task cache
    String? currentUserId;
    final ud = authProvider.userData;
    if (ud != null) {
      final dynamic userObj = ud['user'];
      if (userObj is Map) {
        final dynamic idVal = userObj['_id'] ?? userObj['id'] ?? userObj['uuid'];
        if (idVal != null) currentUserId = idVal.toString();
      }
    }
    
    // Only fetch user data if not available
    if (authProvider.userData == null) {
      authProvider.fetchUserData();
    }
    
    // Only fetch tasks if not available or empty
    if (taskProvider.userTasks.isEmpty && taskProvider.status != TaskStatus.loading) {
  taskProvider.fetchUserTasks(showLoading: true, currentUserId: currentUserId).then((_) {
        setState(() {
          _lastRefreshed = DateTime.now();
        });
      });
    } else {
      // Update last refreshed time even if not fetching
      setState(() {
        _lastRefreshed = DateTime.now();
      });
    }
  }

  // Fetch data from providers (force refresh)
  void _fetchData({bool showLoading = true}) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Derive current user id for scoping task cache
    String? currentUserId;
    final ud = authProvider.userData;
    if (ud != null) {
      final dynamic userObj = ud['user'];
      if (userObj is Map) {
        final dynamic idVal = userObj['_id'] ?? userObj['id'] ?? userObj['uuid'];
        if (idVal != null) currentUserId = idVal.toString();
      }
    }
    
      if (authProvider.userData == null) {
        authProvider.fetchUserData();
      }
    
    // Fetch user tasks with option to show loading indicator
  taskProvider.fetchUserTasks(showLoading: showLoading, currentUserId: currentUserId).then((_) {
      setState(() {
        _lastRefreshed = DateTime.now();
      });
    });
  }

  // Pull-to-refresh functionality
  Future<void> _handleRefresh() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? currentUserId;
    final ud = authProvider.userData;
    if (ud != null) {
      final dynamic userObj = ud['user'];
      if (userObj is Map) {
        final dynamic idVal = userObj['_id'] ?? userObj['id'] ?? userObj['uuid'];
        if (idVal != null) currentUserId = idVal.toString();
      }
    }
    await taskProvider.fetchUserTasks(showLoading: false, currentUserId: currentUserId);
    setState(() {
      _lastRefreshed = DateTime.now();
    });
    return Future.delayed(const Duration(milliseconds: 300));
  }

  // ================= Walkthrough Logic (FAB highlight) =================
  Future<void> _maybeShowPostTaskWalkthrough() async {
    if (_walkthroughShownThisSession) return;
    final alreadyShown = await PreferencesService.isPostTaskWalkthroughShown();
    if (alreadyShown) return;
    // Only show if there are no tasks yet (encourage first task creation)
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    if (taskProvider.userTasks.isNotEmpty) return;
    // Delay a frame to ensure FAB is laid out
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _showPostTaskWalkthrough();
  }

  void _showPostTaskWalkthrough() {
    final ctx = _postTaskFabKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _postTaskWalkthroughEntry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final holeRect = Rect.fromLTWH(
          offset.dx - 12,
          offset.dy - 12,
          size.width + 24,
          size.height + 24,
        );
        return Stack(
          children: [
            // Dim layer
            Positioned.fill(
              child: GestureDetector(
                onTap: _dismissPostTaskWalkthrough,
                child: Container(color: Colors.black.withOpacity(0.65)),
              ),
            ),
            // Cutout painter
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HolePainter(holeRect: holeRect, borderRadius: 28),
                ),
              ),
            ),
            // Tooltip bubble
            Positioned(
              left: (holeRect.left).clamp(16.0, media.size.width - 260.0),
              bottom: media.size.height - holeRect.top + 16,
              child: SizedBox(
                width: 244,
                child: _WalkthroughBubble(
                  title: 'Post a Task',
                  message: 'Tap this button to create your first task. Describe what you need and publish it to get offers.',
                  onGotIt: _dismissPostTaskWalkthrough,
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_postTaskWalkthroughEntry!);
    _walkthroughShownThisSession = true;
    PreferencesService.markPostTaskWalkthroughShown();
  }

  void _dismissPostTaskWalkthrough() {
    _postTaskWalkthroughEntry?.remove();
    _postTaskWalkthroughEntry = null;
  }

  // Format the last refreshed time
  String _getLastRefreshedText() {
    return 'Last updated: ${DateFormat('HH:mm:ss').format(_lastRefreshed)}';
  }

  // Walkthrough and empty-state arrow logic removed

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userData = authProvider.userData;
    final userTasks = taskProvider.userTasks;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: authProvider.status == AuthStatus.loading && userData == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // User profile and notification section
                      _buildUserProfileSection(userData),
                        const SizedBox(height: 8),
                        
                        // Last refreshed indicator
                              // Center(
                              //   child: Text(
                              //     _getLastRefreshedText(),
                              //     style: TextStyle(
                              //       color: Colors.grey.shade600,
                              //       fontSize: 12,
                              //       fontFamily: 'Geist',
                              //     ),
                              //   ),
                              // ),
                        const SizedBox(height: 16),

                        // Main task card (purple background) or empty state
                        // Only show loading if we don't have cached data
                        if (taskProvider.status == TaskStatus.loading && userTasks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (userTasks.isNotEmpty)
                          _buildMainTaskCard(userTasks[0])
                        else
                          _buildEmptyTasksCard(),
                      const SizedBox(height: 24),

                        // Upcoming task card - show if there's a second task
                        if (userTasks.length > 1)
                          _buildUpcomingTaskCard(userTasks[1])
                        else if (userTasks.isNotEmpty)
                          _buildNoMoreTasksCard(),
                      const SizedBox(height: 24),

                      // Recent Activity section with header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              color: Color(0xFF606060),
                              fontSize: 18,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                              height: 0.78,
                            ),
                          ),
                          Text(
                            'See all',
                            style: TextStyle(
                              color: const Color(0xFF606060).withOpacity(0.7),
                              fontSize: 15,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                        // Recent activity items - show real tasks or empty state
                        // Only show loading if we don't have cached data
                        if (taskProvider.status == TaskStatus.loading && userTasks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (userTasks.isNotEmpty)
                          Column(
                            children: [
                              ...userTasks.take(4).map((task) => Column(
                                children: [
                                  _buildActivityItemFromTask(task),
                      const SizedBox(height: 16),
                                ],
                              )).toList(),
                            ],
                          )
                        else
                          _buildEmptyActivityCard(),
                      const SizedBox(height: 24),
                    ],
                    ),
                  ),
                ),
              ),
      ),
        floatingActionButton: FloatingActionButton(
          key: _postTaskFabKey,
          backgroundColor: primaryColor,
          onPressed: () {
            _dismissPostTaskWalkthrough();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostTaskScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
    );
  }

  Widget _buildUserProfileSection(Map<String, dynamic>? userData) {
    final user = userData != null ? userData['user'] : null;
    final profilePictureUrl = user?['profilePicture'] as String?;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // User profile image
              ProfilePictureWidget(
                profilePictureUrl: profilePictureUrl,
                displayName: userData != null ? (userData['user']['fullName'] ?? '') : null,
                radius: 20,
              ),
              const SizedBox(width: 10),
              // User name and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData != null ? userData['user']['fullName'] : 'Loading...',
                      style: const TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 16,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'User',
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.9),
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
        ),
        // Notification, refresh and settings icons
        // Row(
        //   children: [
        //     // Notification icon
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
        //         color: primaryColor,
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildEmptyTasksCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PostTaskScreen()),
        );
      },
  child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No Tasks Here',
              style: TextStyle(
                color: Color(0xFF606060),
                fontSize: 18,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no ongoing tasks, click on\nthe button below to create one',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontFamily: 'Geist',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostTaskScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Post a Task',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Container(
      width: double.infinity,
      
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
  
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50,),
          const Text(
            'No Activity Here',
            style: TextStyle(
              color: Color(0xFF606060),
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no activities here, engage\nin an activity of any sort to see\nthem here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontFamily: 'Geist',
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildNoMoreTasksCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.09)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No more upcoming tasks',
              style: TextStyle(
                color: const Color(0xFF606060),
                fontSize: 16,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format date from ISO string
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Safely get a category display name from either a Map or String
  String _categoryLabel(dynamic value) {
    if (value == null) return 'Uncategorized';
    if (value is Map) {
      final display = value['displayName'] ?? value['name'];
      return (display?.toString().trim().isNotEmpty ?? false)
          ? display.toString()
          : 'Uncategorized';
    }
    if (value is String) {
      return value.isNotEmpty ? value : 'Uncategorized';
    }
    return 'Uncategorized';
  }

  Widget _buildMainTaskCard(Map<String, dynamic> task) {
    // Extract task data
    final title = task['title'] ?? 'Untitled Task';
    final description = task['description'] ?? 'No description';
    final budget = task['budget']?.toString() ?? '0';
    final deadline = task['deadline'] != null 
        ? _formatDate(task['deadline']) 
        : 'No deadline';
  final categories = task['categories'] as List<dynamic>? ?? [];
    final status = task['status'] ?? 'open';
    final taskId = task['_id'] ?? '';
    
    // Get the first category for display, or use fallback
  final primaryCategory = categories.isNotEmpty
    ? _categoryLabel(categories.first)
    : 'Uncategorized';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: taskId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row - Category and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryCategory,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (categories.length > 1) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${categories.length - 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 9,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 22,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w400,
                letterSpacing: -0.3,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            
            // Bottom row - Budget and Deadline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Budget container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A86B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '₦',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            budget,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Geist',
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'BUDGET',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 9,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Deadline and action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Deadline
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deadline,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Action button
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTaskCard(Map<String, dynamic> task) {
    // Extract task data
    final title = task['title'] ?? 'Untitled Task';
    final budget = task['budget']?.toString() ?? '0';
    final deadline = task['deadline'] != null 
        ? _formatDate(task['deadline']) 
        : 'No deadline';
  final categories = task['categories'] as List<dynamic>? ?? [];
    final status = task['status'] ?? 'open';
    final taskId = task['_id'] ?? '';
    
    // Get the first category for display, or use fallback
  final primaryCategory = categories.isNotEmpty
    ? _categoryLabel(categories.first)
    : 'Uncategorized';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: taskId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Left Column - Main content
            Expanded(
              flex: 2,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Upcoming task badge
              Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                      'Upcoming Task',
                  style: TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                  ),
                ),
              ),
                  const SizedBox(height: 12),
                  
                  // Task title
              Text(
                  title,
                    style: const TextStyle(
                      color: Color(0xFF2D3748),
                  fontSize: 18,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      height: 1.2,
                ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF693CB8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      primaryCategory,
                      style: TextStyle(
                        color: const Color(0xFF673AB7).withOpacity(0.8),
                        fontSize: 11,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Budget and status row
              Row(
                children: [
                      // Budget
                  Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF8F4),
                          borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                          mainAxisSize: MainAxisSize.min,
                      children: [
                            const Text(
                              '₦',
                              style: TextStyle(
                                color: Color(0xFF00A86B),
                                fontSize: 14,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 4),
                          Text(
                            budget,
                            style: const TextStyle(
                                color: Color(0xFF00A86B),
                                fontSize: 14,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                      const SizedBox(width: 8),
                      
                      // Status
                  Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                          color: const Color(0xFF673AB7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                    ),
                        child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                            color: Color(0xFF673AB7),
                            fontSize: 11,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
            ),
            
            const SizedBox(width: 16),
            
            // Right Column - Date and action
            Expanded(
              flex: 1,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                  // Edit icon
              Container(
                    padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/edit-icon.svg',
                      width: 16,
                      height: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Deadline container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFB74D).withOpacity(0.3),
                        width: 1,
                      ),
                ),
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFFFF8F00),
                          size: 16,
                        ),
                        const SizedBox(height: 4),
                    const Text(
                          'Deadline',
                      style: TextStyle(
                            color: Color(0xFFBF360C),
                            fontSize: 10,
                        fontFamily: 'Geist',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                      ),
                    ),
                        const SizedBox(height: 4),
                      Text(
                        deadline,
                          style: const TextStyle(
                            color: Color(0xFFBF360C),
                            fontSize: 12,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                      ),
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildActivityItemFromTask(Map<String, dynamic> task) {
    // Extract task data
    final title = task['title'] ?? 'Untitled Task';
    final budget = task['budget']?.toString() ?? '0';
    final createdAt = task['createdAt'] != null 
        ? _formatDate(task['createdAt']) 
        : 'Unknown date';
    final status = task['status'] ?? 'open';
    final taskId = task['_id'] ?? '';
    
    // Determine status color based on status
    Color statusColor;
    Color statusBgColor;
    
    switch(status.toLowerCase()) {
      case 'completed':
        statusColor = primaryColor.withOpacity(0.7);
        statusBgColor = const Color(0xFFF7F5FB);
        break;
      case 'ongoing':
        statusColor = const Color(0xFF6CCDAA);
        statusBgColor = const Color(0xFFEFF9F6);
        break;
      case 'cancelled':
        statusColor = const Color(0xFF606060).withOpacity(0.7);
        statusBgColor = const Color(0xFFF7F5FB);
        break;
      case 'open':
      default:
        statusColor = primaryColor;
        statusBgColor = const Color(0xFFF7F5FB);
        break;
    }
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: taskId),
          ),
        );
      },
      child: _buildActivityItem(
        title: title,
        date: createdAt,
        amount: budget,
        status: status.toUpperCase(),
        statusColor: statusColor,
        statusBgColor: statusBgColor,
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - icon and task details
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon placeholder
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset('assets/icons/activity-icon.svg'),
              ),
              const SizedBox(width: 12),
              // Text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 18,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 15,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
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
        const SizedBox(width: 12),
        // Right side - price and status
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '₦',
                  style: TextStyle(
                    color: Color(0xFF606060),
                    fontSize: 18,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF606060),
                    fontSize: 17,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================= Walkthrough Support Widgets =================

class _HolePainter extends CustomPainter {
  final Rect holeRect;
  final double borderRadius;
  _HolePainter({required this.holeRect, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final bg = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)));
    final diff = Path.combine(PathOperation.difference, bg, cutout);
    canvas.drawPath(diff, overlayPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HolePainter oldDelegate) =>
      oldDelegate.holeRect != holeRect || oldDelegate.borderRadius != borderRadius;
}

class _WalkthroughBubble extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onGotIt;
  const _WalkthroughBubble({required this.title, required this.message, required this.onGotIt});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 13,
                height: 1.3,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onGotIt,
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FancyArrowPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Rect cardRect;
  final Color color;
  _FancyArrowPainter({required this.start, required this.end, required this.cardRect, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
  // Build a tighter path hugging the card without crossing text.
  final path = Path();
  path.moveTo(start.dx, start.dy);
  // Slight outward nudge (small offset) then down along left boundary
  final outsideLeftX = cardRect.left - 18; // reduced distance
  final topOutside = Offset(outsideLeftX, start.dy - 8);
  final midLeft = Offset(cardRect.left - 6, cardRect.top + cardRect.height * 0.40);
  path.quadraticBezierTo(topOutside.dx, topOutside.dy, midLeft.dx, midLeft.dy);
  // Curve inward toward button with a shallow approach
  final approachCtrl = Offset(cardRect.left + cardRect.width * 0.25, end.dy - 32);
  path.quadraticBezierTo(approachCtrl.dx, approachCtrl.dy, end.dx, end.dy);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = color.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, glow);
    final paintStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.15), color.withOpacity(0.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromPoints(start, end));
    canvas.drawPath(path, paintStroke);
    final totalLength = path.computeMetrics().fold<double>(0, (p, m) => p + m.length);
    double target = totalLength - 2;
    double traversed = 0;
    dynamic tangent; // PathMetric.getTangentForOffset returns a Tangent object
    for (final metric in path.computeMetrics()) {
      if (traversed + metric.length >= target) {
        tangent = metric.getTangentForOffset(target - traversed);
        break;
      }
      traversed += metric.length;
    }
    if (tangent != null) {
      final headPos = tangent.position;
      final angle = tangent.angle;
      const headSize = 11.0;
      final headPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      final arrowPath = Path();
      arrowPath.moveTo(headPos.dx, headPos.dy);
      arrowPath.lineTo(
        headPos.dx - headSize * math.cos(angle - 0.45),
        headPos.dy - headSize * math.sin(angle - 0.45),
      );
      arrowPath.moveTo(headPos.dx, headPos.dy);
      arrowPath.lineTo(
        headPos.dx - headSize * math.cos(angle + 0.45),
        headPos.dy - headSize * math.sin(angle + 0.45),
      );
      canvas.drawPath(arrowPath, headPaint);
      // Endpoint dot indicating tap target proximity
      final dotPaint = Paint()..color = color.withOpacity(0.9);
      canvas.drawCircle(headPos, 5, dotPaint);
      canvas.drawCircle(headPos, 9, Paint()..color = color.withOpacity(0.15));
      final pulse = Paint()..color = color.withOpacity(0.2);
      canvas.drawCircle(start, 10, pulse);
      canvas.drawCircle(start, 5, Paint()..color = color.withOpacity(0.4));
    }
  }
  @override
  bool shouldRepaint(covariant _FancyArrowPainter oldDelegate) => oldDelegate.start != start || oldDelegate.end != end || oldDelegate.color != color || oldDelegate.cardRect != cardRect;
}
