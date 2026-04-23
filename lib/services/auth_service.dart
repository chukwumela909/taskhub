import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthService {
  final String _baseUrl = "https://taskhub-server1.onrender.com/api/auth";
  // Core API root (non-auth endpoints)
  final String _apiRoot = "https://taskhub-server1.onrender.com/api";
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Store the token in secure storage
  Future<void> storeToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get the token from secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Delete the token from secure storage
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Store the user type in secure storage
  Future<void> storeUserType(String userType) async {
    await _storage.write(key: 'user_type', value: userType);
  }

  // Get the user type from secure storage
  Future<String?> getUserType() async {
    return await _storage.read(key: 'user_type');
  }

  // Delete the user type from secure storage
  Future<void> deleteUserType() async {
    await _storage.delete(key: 'user_type');
  }

  Future<Map<String, dynamic>> userRegister({
    required String fullName,
    required String emailAddress,
    required String phoneNumber,
    required String country,
    required String residentState,
    required String dateOfBirth,
    required String address,
    required String password,
  }) async {
    final Map<String, String> body = {
      'fullName': fullName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'country': country,
      'residentState': residentState,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'password': password,
    };

    print(body);

    final response = await http.post(
      Uri.parse('$_baseUrl/user-register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode.toString().startsWith('4')) {
      // Handle client error (4xx)
      String message = 'Registration failed';
      final body = jsonDecode(response.body);
      print(body['message']);
      if (body['message'] != null) {
        message = body['message'];
      }
      message = body['message'];
      throw message;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle 201 Created as well
      // Assuming server returns user data or just success message
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      String message = 'Registration failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Registration failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  Future<Map<String, dynamic>> userLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/user-login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'emailAddress': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);

      // Store the token if the login was successful
      if (data['status'] == 'success' && data['token'] != null) {
        await storeToken(data['token']);
        await storeUserType('user');
      }

      return data;
    } else {
      // Attempt to parse error message from response body
      String message = 'An error occurred';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        // Ignore if body is not valid JSON or doesn't contain 'message'
        message = 'Login failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  Future<String?> getPlayerId() async {
    var deviceState = await OneSignal.User.pushSubscription.id;

    if (deviceState == null || deviceState == null) {
      return null;
    }

    var playerId = await deviceState;
    return playerId;
  }

  setNotificationId() async {
    var not_id = await getPlayerId();
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/user/notification-id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'notificationId': not_id ?? '',
      }),
    );
    final data = jsonDecode(response.body);
    print(data);
  }

  // Update OneSignal player ID for tasker accounts
  setTaskerNotificationId() async {
    var not_id = await getPlayerId();
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/tasker/notification-id'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'notificationId': not_id ?? '',
      }),
    );
    final data = jsonDecode(response.body);
    print(data);
  }

  // New method to fetch user data
  Future<Map<String, dynamic>> fetchUserData() async {
    // Get the token from secure storage
    final token = await getToken();

    if (token == null) {
      throw 'Authentication token not found';
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Failed to fetch user data';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Request failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // New method to fetch tasker data
  Future<Map<String, dynamic>> fetchTaskerData() async {
    // Get the token from secure storage
    final token = await getToken();

    if (token == null) {
      throw 'Authentication token not found';
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/tasker'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Failed to fetch tasker data';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Request failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Email verification method
  Future<Map<String, dynamic>> verifyEmail({
    required String code,
    required String emailAddress,
    required String type, // "user" or "tasker"
  }) async {
    final Map<String, String> body = {
      'code': code,
      'emailAddress': emailAddress,
      'type': type,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/verify-email'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Email verification failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Verification failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Resend email verification method
  Future<Map<String, dynamic>> resendEmailVerification({
    required String emailAddress,
    required String type, // "user" or "tasker"
  }) async {
    final Map<String, String> body = {
      'emailAddress': emailAddress,
      'type': type,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/resend-verification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Failed to resend verification code';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Resend failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  Future<Map<String, dynamic>> taskerRegister({
    required String firstName,
    required String lastName,
    required String emailAddress,
    required String phoneNumber,
    required String password,
    required String country,
    required String residentState,
    required String originState,
    required String address,
    required String dateOfBirth,
  }) async {
    final Map<String, String> body = {
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'phoneNumber': phoneNumber,
      'password': password,
      'country': country,
      'residentState': residentState,
      'originState': originState,
      'address': address,
      'dateOfBirth': dateOfBirth,
    };

    print(body);

    final response = await http.post(
      Uri.parse('$_baseUrl/tasker-register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode.toString().startsWith('4')) {
      // Handle client error (4xx)
      String message = 'Registration failed';
      final body = jsonDecode(response.body);
      print(body['message']);
      if (body['message'] != null) {
        message = body['message'];
      }
      message = body['message'];
      throw message;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle 201 Created as well
      // Assuming server returns user data or just success message
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      String message = 'Registration failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Registration failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  Future<Map<String, dynamic>> taskerLogin(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/tasker-login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'emailAddress': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Store the token if the login was successful
      if (data['status'] == 'success' && data['token'] != null) {
        await storeToken(data['token']);
        await storeUserType('tasker');
      }

      return data;
    } else {
      // Attempt to parse error message from response body
      String message = 'An error occurred';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        // Ignore if body is not valid JSON or doesn't contain 'message'
        message = 'Login failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Forgot password method
  Future<Map<String, dynamic>> forgotPassword({
    required String emailAddress,
    required String type, // "user" or "tasker"
  }) async {
    final Map<String, String> body = {
      'emailAddress': emailAddress,
      'type': type,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/forgot-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Forgot password request failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Request failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Reset password method
  Future<Map<String, dynamic>> resetPassword({
    required String code,
    required String newPassword,
    required String emailAddress,
    required String type, // "user" or "tasker"
  }) async {
    final Map<String, String> body = {
      'code': code,
      'newPassword': newPassword,
      'emailAddress': emailAddress,
      'type': type,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Password reset failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Reset failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Change password method
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Get the token from secure storage
    final token = await getToken();

    if (token == null) {
      throw 'Authentication token not found';
    }

    final Map<String, String> body = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/change-password'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Password change failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Change failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Update profile picture method
  Future<Map<String, dynamic>> updateProfilePicture({
    required String profilePicture,
  }) async {
    // Get the token from secure storage
    final token = await getToken();

    if (token == null) {
      throw 'Authentication token not found';
    }

    final Map<String, String> body = {
      'profilePicture': profilePicture,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/profile-picture'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Profile picture update failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Update failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Update tasker location method
  Future<Map<String, dynamic>> updateTaskerLocation({
    required double latitude,
    required double longitude,
  }) async {
    // Get the token from secure storage
    final token = await getToken();

    if (token == null) {
      throw 'Authentication token not found';
    }

    final Map<String, dynamic> body = {
      'latitude': latitude,
      'longitude': longitude,
    };

    final response = await http.put(
      Uri.parse('$_baseUrl/location'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Location update failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Update failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Get all categories (public endpoint)
  Future<Map<String, dynamic>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('$_apiRoot/categories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      String message = 'Failed to fetch categories';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Request failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Update tasker categories
  Future<Map<String, dynamic>> updateTaskerCategories({
    required List<String> categories,
    String? token, // Optional explicit token to avoid storage race conditions
  }) async {
    // Prefer provided token, otherwise fall back to secure storage
    final authToken = token ?? await getToken();

    if (authToken == null || authToken.isEmpty) {
      throw 'Authentication token not found';
    }

    final Map<String, dynamic> body = {
      'categories': categories,
    };

    final response = await http.put(
      Uri.parse('$_apiRoot/auth/categories'),
      headers: <String, String>{
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      print("hellooo");
      return jsonDecode(response.body);
    } else {
      String message = 'Categories update failed';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Update failed (Status Code: ${response.statusCode})';
      }
      throw message;
    }
  }

  // Verify tasker identity using NIN
  Future<Map<String, dynamic>> verifyTaskerIdentity({
    required String nin,
    required String firstName,
    required String lastName,
    required String dateOfBirth, // YYYY-MM-DD
    required String gender, // male | female
    String? phoneNumber,
    String? email,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw 'Authentication token not found';
    }

    final Map<String, dynamic> body = {
      'nin': nin,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/verify-identity'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print(jsonDecode(response.body));
      String message = 'Identity verification failed';
      try {
        final body = jsonDecode(response.body);
        print(body);
        if (body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {
        message = 'Verification failed (Status Code: ${response.statusCode})';
      }
      throw message; 
    }
  }

  // Logout method to clear token and user type
  Future<void> logout() async {
    await deleteToken();
    await deleteUserType();
  }
}
