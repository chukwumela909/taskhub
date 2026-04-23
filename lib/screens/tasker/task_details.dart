import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:taskhub/providers/task_provider.dart';
import 'package:taskhub/providers/auth_provider.dart';
import 'package:taskhub/theme/const_value.dart';
import 'package:intl/intl.dart';
import 'package:taskhub/services/bid_service.dart';
import 'package:taskhub/widgets/profile_picture_widget.dart';

class TaskerTaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskerTaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskerTaskDetailsScreen> createState() => _TaskerTaskDetailsScreenState();
}

class _TaskerTaskDetailsScreenState extends State<TaskerTaskDetailsScreen> {
  bool _isApplying = false;
  final _bidService = BidService();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();

  // --- Helpers to safely read task fields ---
  String _stringify(dynamic value, {String fallback = 'Not specified'}) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    // Common object shapes
    if (value is Map) {
      // try common name/title keys
      final keys = ['name', 'title', 'label', 'value'];
      for (final k in keys) {
        if (value[k] is String && (value[k] as String).isNotEmpty) {
          return value[k];
        }
      }
      // location-like map
      final parts = [value['address'], value['city'], value['state'] ?? value['residentState'], value['country']]
          .whereType<String>()
          .where((s) => s.trim().isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts.join(', ');
      return fallback;
    }
    if (value is List) {
      return value.map((e) => _stringify(e, fallback: '')).where((s) => s.isNotEmpty).join(', ').isNotEmpty
          ? value.map((e) => _stringify(e, fallback: '')).where((s) => s.isNotEmpty).join(', ')
          : fallback;
    }
    return fallback;
  }

  String _posterName(Map<String, dynamic> task) {
    final p1 = task['posterName'];
    if (p1 is String && p1.trim().isNotEmpty) return p1;
    final user = task['user'] ?? task['postedBy'] ?? task['owner'];
    if (user is Map) {
      final fn = user['firstName'];
      final ln = user['lastName'];
      final full = user['fullName'] ?? user['name'];
      if (full is String && full.trim().isNotEmpty) return full;
      if (fn is String || ln is String) {
        return [fn, ln].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ').trim();
      }
    }
    return 'Task Poster';
  }

  String _categoryText(Map<String, dynamic> task) {
    final cat = task['category'];
    if (cat != null) return _stringify(cat, fallback: 'General');
    final cats = task['categories'];
    if (cats is List && cats.isNotEmpty) {
      return _stringify(cats.first, fallback: 'General');
    }
    return 'General';
  }

  String _postedDate(Map<String, dynamic> task) {
    final raw = task['datePosted'] ?? task['createdAt'] ?? task['postedAt'];
    if (raw is String) {
      try {
        final dt = DateTime.parse(raw);
        return DateFormat('MMM d, y').format(dt);
      } catch (_) {
        return raw; // already friendly
      }
    }
    return 'Recently';
  }

  List<String> _imageUrls(Map<String, dynamic> task) {
    final imgs = task['images'];
    if (imgs is List) {
      return imgs.map((e) {
        if (e is String) return e;
        if (e is Map) {
          // common image url keys
          final keys = ['url', 'secure_url', 'imageUrl', 'imageURL', 'path', 'src'];
          for (final k in keys) {
            final v = e[k];
            if (v is String && v.trim().isNotEmpty) return v;
          }
        }
        return '';
      }).where((u) => u.isNotEmpty).toList();
    }
    return const [];
  }

  Widget _buildApplicationSection({
    required bool canApply,
    required String applicationMode,
    required bool priceEditable,
    double? fixedPrice,
    required String applicationLabel,
  }) {
    // Show guidance and fields based on mode
    final isBidding = applicationMode == 'bidding';
    final budgetText = _stringify(widget.task['budget'], fallback: '0');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            canApply
                ? (isBidding
                    ? 'This task is in bidding mode. Enter your bid amount and an optional message.'
                    : 'This is a fixed-price task. Amount is set by the poster. You can include a message.')
                : 'You have already applied to this task.',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 14,
              fontFamily: 'Geist',
            ),
          ),
          const SizedBox(height: 16),
          if (isBidding || priceEditable)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Offer (₦)',
                  style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Geist'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountCtrl,
                  enabled: canApply,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter your amount',
                    filled: true,
                    fillColor: const Color(0xFF1F1F1F),
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fixed Price',
                  style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Geist'),
                ),
                Text(
                  '₦${(fixedPrice ?? double.tryParse(budgetText) ?? 0).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Geist', fontWeight: FontWeight.w600),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            'Message (optional)',
            style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Geist'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageCtrl,
            enabled: canApply,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Introduce yourself, relevant experience, availability…',
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  // derive application info
  final appInfo = (widget.task['applicationInfo'] as Map?)?.cast<String, dynamic>();
  final canApply = (appInfo?['canApply'] as bool?) ?? true;
  final applicationMode = (appInfo?['applicationMode'] as String?) ?? 'fixed';
  final applicationLabel = (appInfo?['applicationLabel'] as String?) ?? (applicationMode == 'bidding' ? 'Place Bid' : 'Apply for Task');
  final priceEditable = (appInfo?['priceEditable'] as bool?) ?? (applicationMode == 'bidding');
  final fixedPrice = (appInfo?['fixedPrice'] is num) ? (appInfo!['fixedPrice'] as num).toDouble() : null;

  // derive task status and assignment
  final status = (widget.task['status'] ?? 'open').toString().toLowerCase();
  final normStatus = status.replaceAll('_', '-');
  final assigned = widget.task['assignedTo'] ?? widget.task['tasker'];
  String assignedId = '';
  if (assigned is String) {
    assignedId = assigned;
  } else if (assigned is Map) {
    assignedId = (assigned['_id'] ?? assigned['id'] ?? '').toString();
  }
  final auth = Provider.of<AuthProvider>(context, listen: false);
  final currentUserId = (auth.userData != null)
      ? ((auth.userData!['user'] is Map)
          ? (auth.userData!['user']['_id'] ?? auth.userData!['user']['id'] ?? '').toString()
          : auth.userData!['user']?.toString() ?? '')
      : '';
  final isAssignedToMe = assignedId.isNotEmpty && assignedId == currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Geist',
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(9),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back-arrow.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1A1A1A),
          statusBarIconBrightness: Brightness.light,
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              _buildTaskHeader(),
              const SizedBox(height: 24),
              
              // Task description
              _buildTaskDescription(),
              const SizedBox(height: 24),
              
              // Task details
              _buildTaskDetails(),
              const SizedBox(height: 24),
              
              // Images if any
              if (widget.task['images'] != null && widget.task['images'].isNotEmpty)
                _buildImagesSection(),
              
              const SizedBox(height: 24),
              _buildApplicationSection(
                canApply: canApply,
                applicationMode: applicationMode,
                priceEditable: priceEditable,
                fixedPrice: fixedPrice,
                applicationLabel: applicationLabel,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(
        canApply: canApply,
        applicationLabel: applicationLabel,
        applicationMode: applicationMode,
        priceEditable: priceEditable,
        fixedPrice: fixedPrice,
  status: normStatus,
  isAssignedToMe: isAssignedToMe,
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Available',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '₦${_stringify(widget.task['budget'], fallback: '0')}',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 24,
                  fontFamily: 'Geist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _stringify(widget.task['title'], fallback: 'Task Title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Builder(builder: (_) {
            final dynamic poster = widget.task['user'] ?? widget.task['postedBy'] ?? widget.task['owner'];
            final name = _posterName(widget.task);
            String? avatar;
            if (poster is Map) {
              avatar = (poster['profilePicture'] ?? poster['avatarUrl'])?.toString();
            }
            return Row(
              children: [
                ProfilePictureWidget(
                  profilePictureUrl: avatar,
                  displayName: name,
                  radius: 10,
                ),
                const SizedBox(width: 6),
                Text(
                  'Posted by $name',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskDescription() {
    // Full-width, no card container
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _stringify(widget.task['description'], fallback: 'No description provided.'),
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 15,
            fontFamily: 'Geist',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Category', _categoryText(widget.task)),
          const SizedBox(height: 12),
          _buildDetailRow('Duration', _stringify(widget.task['duration'], fallback: 'Not specified')),
          const SizedBox(height: 12),
          _buildDetailRow('Urgency', _stringify(widget.task['urgency'], fallback: 'Normal')),
          const SizedBox(height: 12),
          _buildDetailRow('Posted', _postedDate(widget.task)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
            fontFamily: 'Geist',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Geist',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Builder(
                  builder: (_) {
                    final txt = _stringify(widget.task['location'], fallback: '');
                    if (txt.trim().isEmpty) return const SizedBox.shrink();
                    return Text(
                      txt,
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 15,
                        fontFamily: 'Geist',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    final images = _imageUrls(widget.task);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Images',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade700,
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar({
    required bool canApply,
    required String applicationLabel,
    required String applicationMode,
    required bool priceEditable,
    double? fixedPrice,
  required String status,
  required bool isAssignedToMe,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
  child: Row(
          children: [
            // Left side: Contextual action based on assignment/status
            Expanded(
              child: ElevatedButton(
    onPressed: () async {
                  if (_isApplying) return;
                  // Assigned to me and awaiting start
                  if (isAssignedToMe && (status == 'assigned' || status == 'accepted')) {
                    await _startWork();
                    return;
                  }
                  // In progress by me -> complete
                  if (isAssignedToMe && (status == 'in-progress' || status == 'inprogress')) {
                    await _completeTask();
                    return;
                  }
                  // Else default to applying if possible
                  if (canApply) {
                    _applyForTask(
                      applicationMode: applicationMode,
                      priceEditable: priceEditable,
                      fixedPrice: fixedPrice,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
    child: _isApplying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        () {
                          if (isAssignedToMe && (status == 'assigned' || status == 'accepted')) return 'Start Work';
                          if (isAssignedToMe && (status == 'in-progress' || status == 'inprogress')) return 'Complete Task';
                          return canApply ? applicationLabel : 'Unavailable';
                        }(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  void _applyForTask({
    required String applicationMode,
    required bool priceEditable,
    double? fixedPrice,
  }) async {
    setState(() {
      _isApplying = true;
    });
    try {
      final taskId = (widget.task['_id'] ?? widget.task['id'] ?? '').toString();
      if (taskId.isEmpty) throw 'Invalid task ID';

      double? amount;
      if (applicationMode == 'bidding' || priceEditable) {
        final raw = _amountCtrl.text.trim();
        if (raw.isEmpty) {
          throw 'Please enter your bid amount';
        }
        amount = double.tryParse(raw);
        if (amount == null || amount <= 0) {
          throw 'Please enter a valid amount';
        }
      } else {
        // fixed price: backend ignores amount; we won't send it
        amount = null;
      }

      final res = await _bidService.createBid(
        taskId: taskId,
        amount: amount,
        message: _messageCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isApplying = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startWork() async {
    setState(() => _isApplying = true);
    try {
      final taskId = (widget.task['_id'] ?? widget.task['id'] ?? '').toString();
      if (taskId.isEmpty) throw 'Invalid task ID';

      final ok = await Provider.of<TaskProvider>(context, listen: false).startTaskAsTasker(taskId);
      if (!mounted) return;
      setState(() => _isApplying = false);
      if (ok) {
        // Update local status for immediate UX
        setState(() {
          widget.task['status'] = 'in-progress';
          // fallback shape some backends use
          widget.task['status_text'] = 'in-progress';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have started this task'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start task'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeTask() async {
    setState(() => _isApplying = true);
    try {
      final taskId = (widget.task['_id'] ?? widget.task['id'] ?? '').toString();
      if (taskId.isEmpty) throw 'Invalid task ID';

      final ok = await Provider.of<TaskProvider>(context, listen: false).completeTaskAsTasker(taskId);
      if (!mounted) return;
      setState(() => _isApplying = false);
      if (ok) {
        setState(() {
          widget.task['status'] = 'completed';
          widget.task['status_text'] = 'completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed. Payment will be released.'), backgroundColor: Colors.green),
        );
        // Optionally pop back with success
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete task'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApplying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  // Removed Task Poster section as requested
} 