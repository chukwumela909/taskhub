import 'package:flutter/material.dart';
import 'location_checker.dart';

/// Example widget that shows how to check location before performing an action
class TaskLocationCheck extends StatelessWidget {
  final VoidCallback onTaskPost;
  
  const TaskLocationCheck({
    Key? key, 
    required this.onTaskPost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _handleTaskPosting(context),
      child: const Text('Post a New Task'),
    );
  }
  
  Future<void> _handleTaskPosting(BuildContext context) async {
    // Check if location is available before posting a task
    final locationEnabled = await LocationChecker.checkLocationAndPrompt(context);
    
    if (locationEnabled) {
      // Location services are enabled, proceed with task posting
      onTaskPost();
    } else {
      // Show a message explaining why location is needed
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are required to post tasks'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
} 