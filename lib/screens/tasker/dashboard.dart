import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/screens/tasker/task_details.dart';
import 'package:taskhub/screens/tasker/identity_verification.dart';
import 'package:taskhub/screens/tasker/history.dart';
import 'package:taskhub/services/background_location_service.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';
import 'package:intl/intl.dart';

class TaskerDashboardScreen extends StatefulWidget {
  const TaskerDashboardScreen({super.key});

  @override
  State<TaskerDashboardScreen> createState() => _TaskerDashboardScreenState();
}

class _TaskerDashboardScreenState extends State<TaskerDashboardScreen> with WidgetsBindingObserver {
  Timer? _refreshTimer;
  final int _refreshIntervalSeconds = 30;
  DateTime _lastRefreshed = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchData();
    _startLocationUpdatesIfTasker();
    _refreshTimer = Timer.periodic(Duration(seconds: _refreshIntervalSeconds), (_) {
      _fetchData(showLoading: false);
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _stopLocationUpdates();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground, start location updates and fetch data
        _fetchData(showLoading: false);
        _startLocationUpdatesIfTasker();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App is in background, stop location updates to save battery
        _stopLocationUpdates();
        break;
      case AppLifecycleState.detached:
        _stopLocationUpdates();
        break;
    }
  }

  // Start location updates only for taskers
  Future<void> _startLocationUpdatesIfTasker() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.isTasker) {
      await BackgroundLocationService.instance.startLocationUpdates();
    }
  }
  
  // Stop location updates
  void _stopLocationUpdates() {
    BackgroundLocationService.instance.stopLocationUpdates();
  }
  
  void _fetchData({bool showLoading = true}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    if (authProvider.userData == null) {
      authProvider.fetchTaskerData();
    }
    
    // Use tasker feed instead of user tasks for taskers
    taskProvider.fetchTaskerFeed(showLoading: showLoading).then((_) {
      setState(() {
        _lastRefreshed = DateTime.now();
      });
    });
  }

  Future<void> _handleRefresh() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.fetchTaskerFeed(showLoading: false);
    setState(() {
      _lastRefreshed = DateTime.now();
    });
    return Future.delayed(const Duration(milliseconds: 300));
  }

  String _getLastRefreshedText() {
    return 'Last updated: ${DateFormat('HH:mm:ss').format(_lastRefreshed)}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userData = authProvider.userData;
    final allTasks = taskProvider.taskerFeedTasks; // Use tasker feed instead of user tasks
    
    // Filter to only show tasks that the user has applied for (canApply is false)
    final availableTasks = allTasks.where((task) {
      final applicationInfo = task['applicationInfo'] as Map<String, dynamic>?;
      final canApply = applicationInfo?['canApply'] ?? true;
      return !canApply; // Only show tasks where canApply is false (already applied)
    }).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: authProvider.status == AuthStatus.loading && userData == null
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: taskerPrimaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _buildTaskerProfileSection(userData),
                        const SizedBox(height: 20),
                        
                        // Removed location status chip and last-updated timestamp

                        if (taskProvider.status == TaskStatus.loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        else if (availableTasks.isNotEmpty)
                          _buildMainTaskCard(availableTasks[0])
                        else
                          _buildEmptyTasksCard(),
                        const SizedBox(height: 20),

                        if (availableTasks.length > 1)
                          _buildUpcomingTaskCard(availableTasks[1]),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Geist',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                height: 0.78,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TaskerHistoryScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  color: taskerPrimaryColor,
                                  fontSize: 15,
                                  fontFamily: 'Geist',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (taskProvider.status == TaskStatus.loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        else if (availableTasks.isNotEmpty)
                          Column(
                            children: [
                              ...availableTasks.take(4).map((task) => Column(
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
    );
  }

  Widget _buildTaskerProfileSection(Map<String, dynamic>? userData) {
    final user = userData != null ? userData['user'] : null;
    final profilePictureUrl = user?['profilePicture'] as String?;
  final bool isVerified = user?['verifyIdentity'] == true;
    
    String displayName = 'Loading...';
    if (user != null) {
      if (user['firstName'] != null && user['lastName'] != null) {
        displayName = '${user['firstName']} ${user['lastName']}';
      } else if (user['fullName'] != null) {
        displayName = user['fullName'];
      }
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ProfilePictureWidget(
              profilePictureUrl: profilePictureUrl,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Tasker',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    if (!isVerified)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskerIdentityVerificationScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.orange.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Icon(Icons.verified_user_outlined, size: 14, color: Colors.orange),
                                SizedBox(width: 5),
                                Text(
                                  'Identity not verified',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                    fontFamily: 'Geist',
                                    letterSpacing: -0.2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Container(
            //   padding: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF2A2A2A),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: SvgPicture.asset(
            //     'assets/icons/notification.svg',
            //     width: 24,
            //     height: 24,
            //    color: taskerPrimaryColor,
            //   ),
            // ),
            // const SizedBox(width: 8),
            // GestureDetector(
            //   onTap: () {
            //     _fetchData(showLoading: false);
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         content: const Text('Refreshing data...'),
            //         duration: const Duration(seconds: 1),
            //         backgroundColor: taskerPrimaryColor,
            //       ),
            //     );
            //   },
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF2A2A2A),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Icon(
            //       Icons.refresh,
            //       color: taskerPrimaryColor,
            //       size: 24,
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyTasksCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No Tasks Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tasks matching your categories are available right now.\nCheck back later for new opportunities.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _fetchData(showLoading: false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: taskerPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Refresh Tasks',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
    
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No Activity Here',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete tasks to see your activity\nhistory and earnings here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontFamily: 'Geist',
            ),
          ),
        ],
      ),
    );
  }

  // Removed "All Caught Up!" card.

  Widget _buildMainTaskCard(Map<String, dynamic> task) {
    final applicationInfo = task['applicationInfo'] as Map<String, dynamic>?;
    final taskerBidInfo = task['taskerBidInfo'] as Map<String, dynamic>?;
    final isBiddingEnabled = task['isBiddingEnabled'] ?? false;
    final canApply = applicationInfo?['canApply'] ?? true;
    final applicationLabel = applicationInfo?['applicationLabel'] ?? 'Apply for Task';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskerTaskDetailsScreen(task: task),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              taskerPrimaryColor,
              taskerPrimaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isBiddingEnabled ? 'Bidding Task' : 'Fixed Price Task',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (taskerBidInfo?['hasBid'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Applied',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: 'Geist',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '₦${task['budget'] ?? '0'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task['title'] ?? 'Task Title',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task['description'] ?? 'Task description...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontFamily: 'Geist',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container()),
                // Icon(
                //   Icons.location_on,
                //   color: Colors.white.withOpacity(0.8),
                //   size: 16,
                // ),
                // const SizedBox(width: 4),
                // Expanded(
                //   child: Text(
                //     task['location']?['address'] ?? 'Location not specified',
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(0.8),
                //       fontSize: 12,
                //       fontFamily: 'Geist',
                //     ),
                //   ),
                // ),
                Text(
                  canApply ? applicationLabel : 'View Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    decoration: canApply ? null : TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTaskCard(Map<String, dynamic> task) {
    final isBiddingEnabled = task['isBiddingEnabled'] ?? false;
    final taskerBidInfo = task['taskerBidInfo'] as Map<String, dynamic>?;
    
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
              Row(
                children: [
                  Text(
                    isBiddingEnabled ? 'Bidding' : 'Fixed Price',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (taskerBidInfo?['hasBid'] == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Applied',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '₦${task['budget'] ?? '0'}',
                style: TextStyle(
                  color: taskerPrimaryColor,
                  fontSize: 14,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task['title'] ?? 'Task Title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task['description'] ?? 'Task description...',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontFamily: 'Geist',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItemFromTask(Map<String, dynamic> task) {
    final isBiddingEnabled = task['isBiddingEnabled'] ?? false;
    final taskerBidInfo = task['taskerBidInfo'] as Map<String, dynamic>?;
    final applicationInfo = task['applicationInfo'] as Map<String, dynamic>?;
    final canApply = applicationInfo?['canApply'] ?? true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: taskerPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBiddingEnabled ? Icons.gavel : Icons.task_alt,
              color: taskerPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'Task',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  taskerBidInfo?['hasBid'] == true 
                      ? 'Already applied' 
                      : canApply 
                          ? (isBiddingEnabled ? 'Available for bidding' : 'Available for application')
                          : 'Not available',
                  style: TextStyle(
                    color: taskerBidInfo?['hasBid'] == true 
                        ? Colors.orange.shade400
                        : canApply 
                            ? Colors.grey.shade400
                            : Colors.red.shade400,
                    fontSize: 12,
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦${task['budget'] ?? '0'}',
            style: TextStyle(
              color: taskerPrimaryColor,
              fontSize: 14,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 