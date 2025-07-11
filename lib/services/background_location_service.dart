import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:taskhub/services/auth_service.dart';
import 'package:taskhub/services/location_service.dart';

class BackgroundLocationService {
  static BackgroundLocationService? _instance;
  static BackgroundLocationService get instance => _instance ??= BackgroundLocationService._();
  
  BackgroundLocationService._();
  
  Timer? _locationTimer;
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  
  // Update interval in minutes (default: 5 minutes)
  static const int _updateIntervalMinutes = 5;
  
  bool _isRunning = false;
  Position? _lastKnownPosition;
  
  // Start background location updates
  Future<void> startLocationUpdates() async {
    if (_isRunning) return;
    
    print('Starting background location updates...');
    _isRunning = true;
    
    // Update location immediately
    await _updateLocation();
    
    // Set up periodic updates
    _locationTimer = Timer.periodic(
      const Duration(minutes: _updateIntervalMinutes),
      (timer) => _updateLocation(),
    );
  }
  
  // Stop background location updates
  void stopLocationUpdates() {
    print('Stopping background location updates...');
    _locationTimer?.cancel();
    _locationTimer = null;
    _isRunning = false;
  }
  
  // Update location in the background
  Future<void> _updateLocation() async {
    try {
      // Get current position
      final position = await _locationService.getCurrentPosition(
        accuracy: LocationAccuracy.medium, // Use medium for battery efficiency
      );
      
      if (position == null) {
        print('Failed to get current position');
        return;
      }
      
      // Check if location has changed significantly (>100 meters)
      if (_lastKnownPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        
        // If movement is less than 100 meters, skip update to save API calls
        if (distance < 100) {
          print('Location change too small ($distance meters), skipping update');
          return;
        }
      }
      
      // Update location in database
      await _authService.updateTaskerLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      _lastKnownPosition = position;
      print('Location updated successfully: ${position.latitude}, ${position.longitude}');
      
    } catch (e) {
      print('Error updating location: $e');
      // Don't stop the service on error, just log and continue
    }
  }
  
  // Get the current status
  bool get isRunning => _isRunning;
  
  // Force an immediate location update
  Future<void> forceLocationUpdate() async {
    await _updateLocation();
  }
  
  // Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;
} 