import 'package:flutter/material.dart';
import '../services/task_service.dart';

enum TaskStatus { initial, loading, success, error }

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  TaskStatus _status = TaskStatus.initial;
  List<Map<String, dynamic>> _userTasks = [];
  Map<String, dynamic>? _currentTask;
  String? _errorMessage;
  
  // Categories related
  TaskStatus _categoriesStatus = TaskStatus.initial;
  List<Map<String, dynamic>> _categories = [];
  String? _categoriesErrorMessage;
  
  // Getters
  TaskStatus get status => _status;
  List<Map<String, dynamic>> get userTasks => _userTasks;
  Map<String, dynamic>? get currentTask => _currentTask;
  String? get errorMessage => _errorMessage;
  
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
  Future<bool> fetchUserTasks({bool showLoading = true}) async {
    if (showLoading) {
    _status = TaskStatus.loading;
    notifyListeners();
    }
    
    try {
      final tasks = await _taskService.getUserTasks();
      _userTasks = tasks;
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
  
  // Clear current task data
  void clearCurrentTask() {
    _currentTask = null;
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