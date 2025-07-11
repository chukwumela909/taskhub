import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationServicesDialog extends StatelessWidget {
  final VoidCallback? onLocationEnabled;

  const LocationServicesDialog({
    Key? key,
    this.onLocationEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Location Services'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TaskHub needs access to your location.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text('This is required for:'),
          SizedBox(height: 8),
          Text('• Finding nearby tasks'),
          Text('• Calculating distances'),
          Text('• Connecting with taskers'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () async {
            Navigator.pop(context);
            
            final locationProvider = Provider.of<LocationProvider>(
              context, 
              listen: false,
            );
            
            // Open device location settings
            await locationProvider.openLocationSettings();
            
            // Wait a moment and then check if location is now enabled
            await Future.delayed(const Duration(seconds: 3));
            await locationProvider.initLocation();
            
            if (onLocationEnabled != null) onLocationEnabled!();
          },
          child: const Text('Enable Location', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
} 