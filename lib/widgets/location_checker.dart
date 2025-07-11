import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'location_services_dialog.dart';

class LocationChecker {
  /// Static method to check if location is fully enabled and show a dialog if not
  /// This can be called before showing screens that require location
  /// Returns true if location is ready to use, false otherwise
  static Future<bool> checkLocationAndPrompt(BuildContext context) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Re-initialize to get current status
    await locationProvider.initLocation();
    
    // If location is fully enabled, return success
    if (locationProvider.isLocationFullyEnabled) {
      return true;
    }
    
    // First check if location services are disabled
    if (locationProvider.isLocationServiceDisabled) {
      await _showLocationServicesDialog(context);
      return false;
    }
    
    // Then check if permission is denied
    if (locationProvider.isLocationPermissionDenied || 
        locationProvider.isLocationPermissionDeniedForever) {
      // Show permission request dialog
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This feature requires location permission. Would you like to grant permission now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                Navigator.pop(context, true);
                
                if (locationProvider.isLocationPermissionDeniedForever) {
                  await locationProvider.openAppSettings();
                } else {
                  await locationProvider.requestLocationPermission();
                }
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      );
      
      return result ?? false;
    }
    
    return false;
  }
  
  // Show location services dialog
  static Future<bool> _showLocationServicesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationServicesDialog(
        onLocationEnabled: () {
          // Track that user attempted to enable location
        },
      ),
    );
    
    return result ?? false;
  }
} 