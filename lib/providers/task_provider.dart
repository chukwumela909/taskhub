import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/bid_service.dart';

enum TaskStatus { initial, loading, success, error }

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final BidService _bidService = BidService();
  
  TaskStatus _status = TaskStatus.initial;
  List<Map<String, dynamic>> _userTasks = [];
  Map<String, dynamic>? _currentTask;
  String? _errorMessage;
  String? _userIdForUserTasks; // Track which user the current userTasks belong to
  
  // Tasker feed data
  List<Map<String, dynamic>> _taskerFeedTasks = [];
  Map<String, dynamic>? _taskerFeedMeta;

  // Bids for a task (owner view)
  List<Map<String, dynamic>> _taskBids = [];
  bool _taskBidsLoading = false;
  String? _taskBidsError;
  
  // Categories related
  TaskStatus _categoriesStatus = TaskStatus.initial;
  List<Map<String, dynamic>> _categories = [];
  String? _categoriesErrorMessage;
  
  // Getters
  TaskStatus get status => _status;
  List<Map<String, dynamic>> get userTasks => _userTasks;
  Map<String, dynamic>? get currentTask => _currentTask;
  String? get errorMessage => _errorMessage;
  String? get userIdForUserTasks => _userIdForUserTasks;
  
  // Tasker feed getters
  List<Map<String, dynamic>> get taskerFeedTasks => _taskerFeedTasks;
  Map<String, dynamic>? get taskerFeedMeta => _taskerFeedMeta;
  List<Map<String, dynamic>> get taskBids => _taskBids;
  bool get taskBidsLoading => _taskBidsLoading;
  String? get taskBidsError => _taskBidsError;
  
  // Categories getters
  TaskStatus get categoriesStatus => _categoriesStatus;
  List<Map<String, dynamic>> get categories => _categories;
  String? get categoriesErrorMessage => _categoriesErrorMessage;
  
  // Fetch categories
  Future<bool> fetchCategories({bool showLoading = true}) async {
    if (showLoading) {
      _categoriesStatus = TaskStatus.loading;
      notifyListeners();
    }
    
    try {
      final categories = await _taskService.getCategories();
      _categories = categories;
      _categoriesStatus = TaskStatus.success;
      _categoriesErrorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _categoriesErrorMessage = e.toString();
      _categoriesStatus = TaskStatus.error;
      notifyListeners();
      
      // Reset status after a delay
      Future.delayed(Duration(seconds: 3), () {
        if (_categoriesStatus == TaskStatus.error) {
          _categoriesStatus = TaskStatus.initial;
          notifyListeners();
        }
      });
      return false;
    }
  }
  
  // Post a new task
  Future<bool> createTask({
    required String title,
    required String description,
    required List<String> categories,
    required double budget,
    required DateTime deadline,
    required bool isBiddingEnabled,
    List<String>? tags,
    List<Map<String, String>>? images,
    Map<String, dynamic>? location,
  }) async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await _taskService.createTask(
        title: title,
        description: description,
        categories: categories,
        budget: budget,
        deadline: deadline,
        isBiddingEnabled: isBiddingEnabled,
        tags: tags,
        images: images,
        location: location,
      );
      
      // If successful, add the new task to the user's tasks list
      if (response['status'] == 'success' && response['task'] != null) {
        _userTasks.add(response['task']);
      }
      
      _status = TaskStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }
  
  // Fetch user tasks
  Future<bool> fetchUserTasks({bool showLoading = true, String? currentUserId}) async {
    // If user switched, clear state bound to previous user
    if (currentUserId != null && currentUserId != _userIdForUserTasks) {
      _userIdForUserTasks = currentUserId;
      _userTasks = [];
      _currentTask = null;
      _taskBids = [];
      _taskBidsError = null;
      _taskerFeedTasks = [];
      _taskerFeedMeta = null;
      // don't notify yet; we'll set loading below
    }
    if (showLoading) {
    _status = TaskStatus.loading;
    notifyListeners();
    }
    
    try {
      final tasks = await _taskService.getUserTasks();
      _userTasks = tasks;
      // Ensure the user scope remains set
      if (currentUserId != null) {
        _userIdForUserTasks = currentUserId;
      }
      _status = TaskStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  // Fetch tasker feed (personalized tasks for taskers)
  Future<bool> fetchTaskerFeed({
    bool showLoading = true,
    int page = 1,
    int limit = 10,
    bool? biddingOnly,
    double? budgetMin,
    double? budgetMax,
    double? maxDistance,
  }) async {
    if (showLoading) {
      _status = TaskStatus.loading;
      notifyListeners();
    }
    
    try {
      final response = await _taskService.getTaskerFeed(
        page: page,
        limit: limit,
        biddingOnly: biddingOnly,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        maxDistance: maxDistance,
      );
      
      _taskerFeedTasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);
      _taskerFeedMeta = {
        'pagination': response['pagination'],
        'taskerCategories': response['taskerCategories'],
        'filters': response['filters'],
      };
      _status = TaskStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }
  
  // Fetch a specific task by ID
  Future<bool> fetchTaskById(String taskId) async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    _currentTask = null;
    notifyListeners();
    
    try {
      final task = await _taskService.getTaskById(taskId);
      _currentTask = task;
      _status = TaskStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e.toString());
      return false;
    }
  }

  // Fetch bids for a given task
  Future<void> fetchTaskBids(String taskId) async {
    _taskBidsLoading = true;
    _taskBidsError = null;
    notifyListeners();

    try {
      final bids = await _taskService.getTaskBids(taskId);
      _taskBids = bids;
      _taskBidsLoading = false;
      notifyListeners();
    } catch (e) {
      _taskBidsLoading = false;
      _taskBidsError = e.toString();
      notifyListeners();
    }
  }

  // Accept a bid (user/owner only). On success, refresh task and bids.
  Future<bool> acceptBid({required String bidId, required String taskId}) async {
    try {
      final resp = await _bidService.acceptBid(bidId: bidId);
      // Refresh current task and bids to reflect assigned state and rejected others
      await fetchTaskById(taskId);
      await fetchTaskBids(taskId);
      final map = resp as Map<String, dynamic>;
      return (map['status'] == 'success' || map['ok'] == true);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // User cancels a task (open: plain cancel; assigned: refund escrow). Backend enforces rules.
  Future<bool> cancelTaskAsUser(String taskId) async {
    try {
      final resp = await _taskService.updateTaskStatusAsUser(taskId: taskId, status: 'cancelled');
      // Refresh task and bids (bids may be cleared/locked post-cancel)
      await fetchTaskById(taskId);
      await fetchTaskBids(taskId);
      return (resp['status'] == 'success');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Tasker starts work: assigned -> in-progress
  Future<bool> startTaskAsTasker(String taskId) async {
    try {
      final resp = await _taskService.updateTaskStatusAsTasker(taskId: taskId, status: 'in-progress');
      await fetchTaskById(taskId);
      return (resp['status'] == 'success');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Tasker completes task: in-progress -> completed (payout release)
  Future<bool> completeTaskAsTasker(String taskId) async {
    try {
      final resp = await _taskService.updateTaskStatusAsTasker(taskId: taskId, status: 'completed');
      await fetchTaskById(taskId);
      return (resp['status'] == 'success');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Clear current task data
  void clearCurrentTask() {
    _currentTask = null;
    notifyListeners();
  }

  // Clear all cached task state (use on logout)
  void clearAll() {
    _status = TaskStatus.initial;
    _userTasks = [];
    _currentTask = null;
    _errorMessage = null;
    _userIdForUserTasks = null;
    _taskerFeedTasks = [];
    _taskerFeedMeta = null;
    _taskBids = [];
    _taskBidsLoading = false;
    _taskBidsError = null;
    _categoriesStatus = TaskStatus.initial;
    _categories = [];
    _categoriesErrorMessage = null;
    notifyListeners();
  }
  
  // Helper to handle errors
  void _handleError(String error) {
    _errorMessage = error;
    _status = TaskStatus.error;
    notifyListeners();
    
    // Reset status after a delay
    Future.delayed(Duration(seconds: 3), () {
      if (_status == TaskStatus.error) {
        _status = TaskStatus.initial;
        notifyListeners();
      }
    });
  }
}