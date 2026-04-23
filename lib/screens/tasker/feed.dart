import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:taskhub/screens/tasker/task_details.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class TaskerFeedScreen extends StatefulWidget {
  const TaskerFeedScreen({super.key});

  @override
  State<TaskerFeedScreen> createState() => _TaskerFeedScreenState();
}

class _TaskerFeedScreenState extends State<TaskerFeedScreen> {
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchTaskerFeed();
    taskProvider.fetchCategories(showLoading: false);
  }

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
          // IconButton(
          //   onPressed: () {},
          //   icon: SvgPicture.asset(
          //     'assets/icons/arrange-square.svg',
          //     width: 24,
          //     height: 24,
          //     colorFilter: const ColorFilter.mode(
          //       Colors.white,
          //       BlendMode.srcIn,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<TaskProvider>(context, listen: false)
                    .fetchTaskerFeed(showLoading: false);
              },
              color: primaryColor,
              child: _buildTaskList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final catList = <String>[
          'All',
          ...provider.categories
              .map((c) => (c['displayName'] ?? c['name'] ?? '').toString())
              .where((e) => e.isNotEmpty),
        ];

        if (!catList.contains(selectedCategory)) {
          selectedCategory = 'All';
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: catList.length,
            itemBuilder: (context, index) {
              final category = catList[index];
              final isSelected = selectedCategory == category;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          isSelected ? primaryColor : Colors.grey.shade700,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final allTasks = provider.taskerFeedTasks;
        final tasks = selectedCategory == 'All'
            ? allTasks
            : allTasks.where((t) {
                final cats = t['categories'];
                if (cats is List) {
                  return cats.any((c) {
                    final name = (c is Map)
                        ? (c['displayName'] ?? c['name'] ?? '').toString()
                        : c.toString();
                    return name == selectedCategory;
                  });
                }
                return false;
              }).toList();

        if (provider.status == TaskStatus.loading && allTasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tasks.isEmpty) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 120),
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/activity-icon.svg',
                      width: 64,
                      height: 64,
                      colorFilter: ColorFilter.mode(
                        Colors.grey,
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
              ),
            ],
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
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    // Derive poster details
    final dynamic poster = task['user'] ?? task['postedBy'] ?? task['owner'];
    String posterName = '';
    String? posterAvatar;
    if (poster is Map) {
      final full = (poster['fullName'] ?? poster['name'])?.toString() ?? '';
      if (full.trim().isNotEmpty) {
        posterName = full;
      } else {
        final fn = (poster['firstName'] ?? '').toString();
        final ln = (poster['lastName'] ?? '').toString();
        posterName = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ').trim();
      }
      posterAvatar = (poster['profilePicture'] ?? poster['avatarUrl'])?.toString();
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskerTaskDetailsScreen(task: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
            Row(
              children: [
                if (task['categories'] is List &&
                    (task['categories'] as List).isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (() {
                        final cats = task['categories'] as List;
                        final c = cats.first;
                        if (c is Map) {
                          return (c['displayName'] ?? c['name'] ?? 'Task')
                              .toString();
                        }
                        return c.toString();
                      })(),
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
                  '₦${task['budget'] ?? '0'}',
                  style: const TextStyle(
                    fontFamily: 'Geist',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (posterName.isNotEmpty || (posterAvatar != null && posterAvatar.isNotEmpty))
              Row(
                children: [
                  ProfilePictureWidget(
                    profilePictureUrl: posterAvatar,
                    displayName: posterName.isEmpty ? 'User' : posterName,
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      posterName.isNotEmpty ? posterName : 'Task poster',
                      style: TextStyle(
                        fontFamily: 'Geist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Text(
              (task['title'] ?? 'Task').toString(),
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              (task['description'] ?? '').toString(),
              style: TextStyle(
                fontFamily: 'Geist',
                fontSize: 14,
                color: Colors.grey.shade300,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (_) {
                      final loc = task['location'];
                      String text = '';
                      if (loc is Map) text = (loc['address'] ?? '').toString();
                      if (loc is String) text = loc;
                      if (text.trim().isEmpty) return const SizedBox.shrink();
                      return Text(
                        text,
                        style: TextStyle(
                          fontFamily: 'Geist',
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskerTaskDetailsScreen(task: task),
                      ),
                    );
                  },
                  child: const Text(
                    'View',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
