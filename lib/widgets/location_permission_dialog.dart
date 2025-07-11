import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionDialog({
    Key? key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Location Services'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'TaskHub needs access to your location to provide you with the best experience.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'We use your location to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Show you nearby available tasks'),
          Text('• Calculate distance to job locations'),
          Text('• Provide accurate directions'),
          SizedBox(height: 12),
          Text(
            'Please enable location services to continue using all features of the app.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onPermissionDenied != null) onPermissionDenied!();
          },
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () async {
            final locationProvider = Provider.of<LocationProvider>(
              context, 
              listen: false
            );
            
            // First check if location service is enabled
            var isEnabled = await locationProvider.requestLocationPermission();
            
            if (isEnabled) {
              // Try to get the location
              await locationProvider.getCurrentLocation();
              
              if (locationProvider.status == LocationStatus.success) {
                Navigator.of(context).pop();
                if (onPermissionGranted != null) onPermissionGranted!();
              } else if (locationProvider.status == LocationStatus.disabled) {
                // Location service is disabled - ask user to enable it
                final shouldOpen = await _showLocationServiceDialog(context);
                if (shouldOpen) {
                  await locationProvider.openLocationSettings();
                }
              } else if (locationProvider.status == LocationStatus.permissionDeniedForever) {
                // Permission permanently denied - direct to app settings
                final shouldOpen = await _showAppSettingsDialog(context);
                if (shouldOpen) {
                  await locationProvider.openAppSettings();
                }
              }
            }
          },
          child: const Text('Enable Location', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }

  Future<bool> _showLocationServiceDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showAppSettingsDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Location permission was permanently denied. '
          'Please go to app settings to grant permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open App Settings'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
} 