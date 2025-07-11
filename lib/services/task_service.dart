import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TaskService {
  final String _baseUrl = "https://taskhub-server-yw24.onrender.com/api";
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>> createTask({
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
    // Get the token from secure storage
    final token = await getToken();
    
    if (token == null) {
      throw 'Authentication token not found. Please login first.';
    }

    // Prepare the request body
    final Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'categories': categories,
      'budget': budget,
      'deadline': deadline.toIso8601String(),
      'isBiddingEnabled': isBiddingEnabled,
    };

    // Add optional fields if provided
    if (tags != null && tags.isNotEmpty) {
      body['tags'] = tags;
    }

    if (images != null && images.isNotEmpty) {
      body['images'] = images;
    }

    if (location != null) {
      body['location'] = location;
    }

    try {
      // Log request details for debugging (remove in production)
      print('Sending task creation request to: $_baseUrl/tasks');
      print('Request body: ${jsonEncode(body)}');
    
    // Make the API request
    final response = await http.post(
      Uri.parse('$_baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      // Handle successful response (status code 200 or 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 'success') {
          return responseData;
    } else {
          throw responseData['message'] ?? 'Unknown error occurred';
        }
      } 
      // Handle error responses
      else {
        // API error format from documentation:
        // { "status": "error", "message": "Invalid deadline", "details": "Deadline must be a valid future date" }
      String errorMessage = 'Failed to create task';
        
        if (responseData['status'] == 'error') {
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
            
            // Add details if available
            if (responseData['details'] != null) {
              errorMessage += ': ${responseData['details']}';
      }
          }
        }
        
        throw errorMessage;
      }
    } catch (e) {
      // For debugging (remove in production)
      print('Task creation error: $e');
      
      // Rethrow error to be handled by the provider
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getUserTasks() async {
    // Get the token from secure storage
    final token = await getToken();
    
    if (token == null) {
      throw 'Authentication token not found. Please login first.';
    }

    try {
      print('Fetching user tasks from: $_baseUrl/tasks/user/tasks');
    final response = await http.get(
        Uri.parse('$_baseUrl/tasks/user/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success' && responseData['tasks'] is List) {
          // Return the tasks array from the response
        return List<Map<String, dynamic>>.from(responseData['tasks']);
      }
        // If no tasks or empty array, return empty list
      return [];
    } else {
      String errorMessage = 'Failed to fetch user tasks';
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Error fetching user tasks: $e');
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getTaskById(String taskId) async {
    // Get the token from secure storage
    final token = await getToken();
    
    if (token == null) {
      throw 'Authentication token not found. Please login first.';
    }

    try {
      print('Fetching task details from: $_baseUrl/tasks/$taskId');
      final response = await http.get(
        Uri.parse('$_baseUrl/tasks/$taskId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
        final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success' && responseData['task'] != null) {
          // Return the task object from the response
          return responseData['task'];
        }
        throw 'Task not found';
      } else {
        String errorMessage = 'Failed to fetch task details';
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Error fetching task details: $e');
      throw e.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      print('Fetching categories from: $_baseUrl/categories');
      final response = await http.get(
        Uri.parse('$_baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success' && responseData['categories'] is List) {
          // Return the categories array from the response
          return List<Map<String, dynamic>>.from(responseData['categories']);
        }
        // If no categories or empty array, return empty list
        return [];
      } else {
        String errorMessage = 'Failed to fetch categories';
        if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw e.toString();
    }
  }
} 