import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/theme/const_value.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  static const List<String> _tabs = ['open', 'assigned', 'in-progress', 'completed', 'cancelled'];
  String _selectedStatus = 'open'; // Track selected status instead of using TabController

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.userTasks; // assumes already fetched elsewhere
    final status = taskProvider.status;

    return Scaffold(
      backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task History',
                      style: TextStyle(
                        color: Color(0xFF606060),
                        fontSize: 24,
                        fontFamily: 'Geist',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFFF7F5FB),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: SvgPicture.asset(
                    //     'assets/icons/filter.svg',
                    //     width: 24,
                    //     height: 24,
                    //     color: primaryColor,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'View all your previous tasks',
                  style: TextStyle(
                    color: const Color(0xFF606060).withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Status filter (like tasker feed)
              _buildStatusFilter(),
              const SizedBox(height: 8),
              Expanded(
                child: status == TaskStatus.loading && tasks.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTaskList(tasks),
              ),
            ],
          ),
        ),
    );
  }

  // Status filter similar to tasker feed
  Widget _buildStatusFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final status = _tabs[index];
          final isSelected = _selectedStatus == status;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                _formatTabLabel(status),
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF606060),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    final filtered = tasks.where((task) => _matchesTab(task, _selectedStatus)).toList();
    
    if (filtered.isEmpty) {
      return _EmptyTabState(label: _formatTabLabel(_selectedStatus));
    }
    
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final task = filtered[index];
        return _buildActivityItem(
          title: task['title'] ?? 'Untitled Task',
          date: _formatDate(task['createdAt'] ?? task['deadline']),
          amount: (task['budget']?.toString() ?? '0'),
          status: (task['status'] ?? 'OPEN').toString().toUpperCase(),
          statusColor: _statusColor(task['status']),
          statusBgColor: _statusBgColor(task['status']),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: filtered.length,
    );
  }

  // Helpers
  static String _formatTabLabel(String raw) {
    if (raw.contains('-')) {
      return raw.split('-').map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1)).join('-');
    }
    return raw[0].toUpperCase() + raw.substring(1);
  }

  bool _matchesTab(Map<String, dynamic> task, String tab) {
    final status = (task['status'] ?? '').toString().toLowerCase();
    switch (tab) {
      case 'open':
        return status == 'open';
      case 'assigned':
        return status == 'assigned' || status == 'ongoing'; // treat ongoing as assigned if needed
      case 'in-progress':
        return status == 'in-progress' || status == 'ongoing';
      case 'completed':
        return status == 'completed';
      case 'cancelled':
        return status == 'cancelled';
      default:
        return false;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown date';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return 'Unknown date';
    }
  }

  Color _statusColor(dynamic statusRaw) {
    final s = (statusRaw ?? '').toString().toLowerCase();
    switch (s) {
      case 'completed':
        return primaryColor.withOpacity(0.7);
      case 'ongoing':
      case 'in-progress':
        return const Color(0xFF6CCDAA);
      case 'cancelled':
        return const Color(0xFF606060).withOpacity(0.7);
      case 'assigned':
        return primaryColor; // accent
      case 'open':
      default:
        return primaryColor;
    }
  }

  Color _statusBgColor(dynamic statusRaw) {
    final s = (statusRaw ?? '').toString().toLowerCase();
    switch (s) {
      case 'completed':
      case 'open':
      case 'assigned':
        return const Color(0xFFF7F5FB);
      case 'ongoing':
      case 'in-progress':
        return const Color(0xFFEFF9F6);
      case 'cancelled':
        return const Color(0xFFF7F5FB);
      default:
        return const Color(0xFFF7F5FB);
    }
  }
  
  Widget _buildActivityItem({
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Left side: icon + details
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset('assets/icons/activity-icon.svg'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF606060),
                          fontSize: 16,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 13.5,
                          fontFamily: 'Geist',
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
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
          // Right side: amount + status
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
                      fontSize: 16,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Color(0xFF606060),
                      fontSize: 16,
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  final String label;
  const _EmptyTabState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_outlined, 
              color: Colors.grey.shade400, 
              size: 64
            ),
            const SizedBox(height: 16),
            Text(
              'No ${label.toLowerCase()} tasks',
              style: const TextStyle(
                color: Color(0xFF606060),
                fontSize: 18,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tasks with ${label.toLowerCase()} status will appear here.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontFamily: 'Geist',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

