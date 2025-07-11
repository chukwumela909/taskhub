import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// Enum to represent the authentication status more clearly
enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  String? _token;
  String? _errorMessage;
  Map<String, dynamic>? _userData; // Store user data
  Map<String, dynamic>? _userType; // check if user is a tasker or a user
  bool _isTasker = false; // Track if current user is a tasker

  // Getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get userType => _userType;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isTasker => _isTasker;

  AuthProvider() {
    // Check for stored token on initialization
    _checkToken();
  }

  // Public method to manually check authentication status
  Future<void> checkAuthenticationStatus() async {
    await _checkToken();
  }

  // Check if a token exists and validate it
  Future<void> _checkToken() async {
    final storedToken = await _authService.getToken();
    
    if (storedToken != null) {
      _token = storedToken;
      
      // Get the stored user type
      final storedUserType = await _authService.getUserType();
      
      try {
        if (storedUserType == 'tasker') {
          // User is a tasker, fetch tasker data
          _isTasker = true;
          await fetchTaskerData();
        } else {
          // Default to regular user
          _isTasker = false;
          await fetchUserData();
        }
        _status = AuthStatus.authenticated;
      } catch (e) {
        // Token might be invalid or expired
        _token = null;
        _isTasker = false;
        await _authService.deleteToken();
        await _authService.deleteUserType();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // --- Text Editing Controllers ---
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // --- Additional controllers for taskers ---
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController residentStateController = TextEditingController();
  final TextEditingController originStateController = TextEditingController();

  // User registration method
  Future<bool> userRegister() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.userRegister(
        fullName: fullNameController.text.trim(),
        emailAddress: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        country: countryController.text.isEmpty ? "Nigeria" : countryController.text.trim(),
        residentState: stateController.text.trim(),
        dateOfBirth: dobController.text.trim(),
        address: addressController.text.trim(),
        password: passwordController.text,
      );

      _status = AuthStatus.unauthenticated; // Stay unauthenticated after register
      notifyListeners();
      return true; // Indicate registration call was successful
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Tasker registration method
  Future<bool> taskerRegister() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.taskerRegister(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        emailAddress: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text,
        country: countryController.text.isEmpty ? "Nigeria" : countryController.text.trim(),
        residentState: residentStateController.text.trim(),
        originState: originStateController.text.trim(),
        address: addressController.text.trim(),
        dateOfBirth: dobController.text.trim(),
      );

      _status = AuthStatus.unauthenticated; // Stay unauthenticated after register
      notifyListeners();
      return true; // Indicate registration call was successful
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // User login method
  Future<bool>  userLogin() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.userLogin(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response['status'] == 'success' && response['token'] != null) {
        // Token and user type are already stored by AuthService
        _token = response['token'];
        _isTasker = false; // Mark as regular user
        _status = AuthStatus.authenticated;
        
        // Fetch user data immediately after successful login
        await fetchUserData();
        
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Login failed: Invalid response from server';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Tasker login method
  Future<bool> taskerLogin() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.taskerLogin(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response['status'] == 'success' && response['token'] != null) {
        // Token and user type are already stored by AuthService
        _token = response['token'];
        _isTasker = true; // Mark as tasker
        _status = AuthStatus.authenticated;
        
        // Fetch tasker data immediately after successful login
        await fetchTaskerData();
        
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Login failed: Invalid response from server';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  // Fetch user data method
  Future<bool> fetchUserData() async {
    // Check for token first
    final storedToken = await _authService.getToken();
    
    if (storedToken == null) {
      // No token available
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
    
    // We have a token, set it and update status to loading
    _token = storedToken;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.fetchUserData();
      _userData = response;
      _isTasker = false; // Mark as regular user
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      // Token might be invalid or expired
      _token = null;
      _userData = null;
      await _authService.deleteToken();
      await _authService.deleteUserType();
      _status = AuthStatus.unauthenticated;
      _handleError(e);
      return false;
    }
  }

  // Fetch tasker data method
  Future<bool> fetchTaskerData() async {
    // Check for token first
    final storedToken = await _authService.getToken();
    
    if (storedToken == null) {
      // No token available
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
    
    // We have a token, set it and update status to loading
    _token = storedToken;
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final response = await _authService.fetchTaskerData();
      _userData = response;
      _isTasker = true; // Mark as tasker
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      // Token might be invalid or expired
      _token = null;
      _userData = null;
      _isTasker = false;
      await _authService.deleteToken();
      await _authService.deleteUserType();
      _status = AuthStatus.unauthenticated;
      _handleError(e);
      return false;
    }
  }

  Future<String?> forgotPassword(String email, {String userType = "user"}) async {
    // Doesn't change auth state, just performs the action
    _status = AuthStatus.loading; // Indicate activity
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(
        emailAddress: email,
        type: userType,
      );
      _status = AuthStatus.unauthenticated; // Remain unauthenticated
      notifyListeners();
      // Return success message from API if available
      return response['message'] as String? ??
          'Password reset instructions sent.';
    } catch (e) {
      _handleError(e);
      return null; // Indicate failure
    }
  }

  // Update profile picture method
  Future<bool> updateProfilePicture(String profilePictureUrl) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfilePicture(
        profilePicture: profilePictureUrl,
      );

      if (response['status'] == 'success') {
        // Update the local user data with the new profile picture
        if (_userData != null && _userData!['user'] != null) {
          _userData!['user']['profilePicture'] = response['profilePicture'];
        }
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Profile picture update failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  void logout() async {
    await _authService.logout();
    _token = null;
    _userData = null;
    _isTasker = false; // Reset tasker flag
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Clear form fields
  void clearFormFields() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    countryController.clear();
    stateController.clear();
    dobController.clear();
    addressController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    firstNameController.clear();
    lastNameController.clear();
    residentStateController.clear();
    originStateController.clear();
  }

  // Helper to handle errors and reset state
  void _handleError(Object e) {
    _errorMessage = e.toString();
    _status = AuthStatus.error; // Set a distinct error status
    notifyListeners();
    // Reset status back to unauthenticated after a delay
    Future.delayed(Duration(seconds: 3), () {
      if (_status == AuthStatus.error) {
         _status = AuthStatus.unauthenticated;
         notifyListeners();
      }
    });
  }
}



