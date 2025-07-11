import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'location_checker.dart';

class LocationDisplay extends StatelessWidget {
  final bool showRefreshButton;
  final bool showCoordinates;
  final VoidCallback? onLocationUpdated;
  
  const LocationDisplay({
    Key? key,
    this.showRefreshButton = true,
    this.showCoordinates = false,
    this.onLocationUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: _getLocationStatusColor(locationProvider.status),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getLocationStatusText(locationProvider.status),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (showCoordinates && locationProvider.hasLocation)
                  Text(
                    locationProvider.locationString,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (showRefreshButton)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshLocation(context, locationProvider),
              tooltip: 'Refresh location',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              iconSize: 20,
            ),
        ],
      ),
    );
  }
  
  Future<void> _refreshLocation(BuildContext context, LocationProvider locationProvider) async {
    // First check if location services are enabled
    final locationEnabled = await LocationChecker.checkLocationAndPrompt(context);
    
    if (locationEnabled) {
      // Get current location
      await locationProvider.getCurrentLocation();
      
      if (onLocationUpdated != null) {
        onLocationUpdated!();
      }
    }
  }
  
  Color _getLocationStatusColor(LocationStatus status) {
    switch (status) {
      case LocationStatus.success:
        return Colors.green;
      case LocationStatus.loading:
        return Colors.blue;
      case LocationStatus.disabled:
      case LocationStatus.permissionDenied:
      case LocationStatus.permissionDeniedForever:
        return Colors.red;
      case LocationStatus.error:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _getLocationStatusText(LocationStatus status) {
    switch (status) {
      case LocationStatus.success:
        return 'Location available';
      case LocationStatus.loading:
        return 'Getting location...';
      case LocationStatus.disabled:
        return 'Location services disabled';
      case LocationStatus.permissionDenied:
        return 'Location permission denied';
      case LocationStatus.permissionDeniedForever:
        return 'Location permission permanently denied';
      case LocationStatus.error:
        return 'Error getting location';
      default:
        return 'Location status unknown';
    }
  }
} 