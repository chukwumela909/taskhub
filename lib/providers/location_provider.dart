import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

enum LocationStatus {
  initial,
  loading,
  enabled,
  disabled,
  permissionDenied,
  permissionDeniedForever,
  success,
  error,
}

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  LocationStatus _status = LocationStatus.initial;
  Position? _currentPosition;
  String _errorMessage = '';

  // Getters
  LocationStatus get status => _status;
  Position? get currentPosition => _currentPosition;
  String get errorMessage => _errorMessage;
  bool get hasLocation => _currentPosition != null;

  // Get formatted coordinates as a string
  String get locationString {
    if (_currentPosition == null) {
      return 'No location data';
    }
    return '${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
  }

  // Format coordinates for display
  Map<String, double> get locationCoordinates {
    if (_currentPosition == null) {
      return {'latitude': 0.0, 'longitude': 0.0};
    }
    return {
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
    };
  }

  // Check if location is fully enabled (both services and permissions)
  bool get isLocationFullyEnabled {
    return _status == LocationStatus.enabled || _status == LocationStatus.success;
  }

  // Check if location services are specifically disabled
  bool get isLocationServiceDisabled {
    return _status == LocationStatus.disabled;
  }

  // Check if permission is denied but could be requested
  bool get isLocationPermissionDenied {
    return _status == LocationStatus.permissionDenied;
  }

  // Check if permission is permanently denied
  bool get isLocationPermissionDeniedForever {
    return _status == LocationStatus.permissionDeniedForever;
  }

  // Initialization method to check location status on app start
  Future<void> initLocation() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      // First check if location service is enabled on the device
      final isServiceEnabled = await _locationService.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        _status = LocationStatus.disabled;
        notifyListeners();
        return;
      }

      // Then check permission status
      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        _status = LocationStatus.permissionDenied;
        notifyListeners();
        return;
      } else if (permission == LocationPermission.deniedForever) {
        _status = LocationStatus.permissionDeniedForever;
        notifyListeners();
        return;
      }

      // If everything is okay, get current position
      await getCurrentLocation();
      
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      final permission = await _locationService.requestPermission();
      
      if (permission == LocationPermission.denied) {
        _status = LocationStatus.permissionDenied;
        notifyListeners();
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        _status = LocationStatus.permissionDeniedForever;
        notifyListeners();
        return false;
      }

      _status = LocationStatus.enabled;
      notifyListeners();
      return true;
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    _status = LocationStatus.loading;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      
      if (position != null) {
        _currentPosition = position;
        _status = LocationStatus.success;
        
        // Save the location to shared preferences
        await _saveLocationToPrefs();
      } else {
        _status = LocationStatus.error;
        _errorMessage = 'Unable to get location';
      }
    } catch (e) {
      _status = LocationStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  // Open app settings
  Future<bool> openAppSettings() async {
    return await _locationService.openAppSettings();
  }

  // Open location settings
  Future<bool> openLocationSettings() async {
    return await _locationService.openLocationSettings();
  }

  // Save location to shared preferences
  Future<void> _saveLocationToPrefs() async {
    if (_currentPosition == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', _currentPosition!.latitude);
      await prefs.setDouble('longitude', _currentPosition!.longitude);
      await prefs.setDouble('accuracy', _currentPosition!.accuracy);
      await prefs.setString('timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving location to preferences: $e');
    }
  }

  // Load saved location from shared preferences
  Future<void> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('latitude');
      final longitude = prefs.getDouble('longitude');
      
      if (latitude != null && longitude != null) {
        _currentPosition = Position(
          latitude: latitude,
          longitude: longitude,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
          timestamp: DateTime.parse(prefs.getString('timestamp') ?? DateTime.now().toIso8601String()),
          accuracy: prefs.getDouble('accuracy') ?? 0.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
        _status = LocationStatus.success;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved location: $e');
    }
  }
} 