import 'package:flutter/material.dart';
import 'package:taskhub/services/background_location_service.dart';
import 'package:taskhub/theme/const_value.dart';

class LocationStatusWidget extends StatefulWidget {
  const LocationStatusWidget({super.key});

  @override
  State<LocationStatusWidget> createState() => _LocationStatusWidgetState();
}

class _LocationStatusWidgetState extends State<LocationStatusWidget> {
  late bool _isLocationUpdating;
  
  @override
  void initState() {
    super.initState();
    _isLocationUpdating = BackgroundLocationService.instance.isRunning;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isLocationUpdating 
            ? primaryColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isLocationUpdating ? primaryColor : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLocationUpdating ? Icons.location_on : Icons.location_off,
            size: 16,
            color: _isLocationUpdating ? primaryColor : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            _isLocationUpdating ? 'Location Active' : 'Location Off',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Geist',
              fontWeight: FontWeight.w500,
              color: _isLocationUpdating ? primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 