import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';

class LocationService {
  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final bool shouldEnable = await _showLocationServicesDisabledDialog(
          context,
        );
        if (shouldEnable) {
          await Geolocator.openLocationSettings();
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }

        if (!serviceEnabled) {
          return null;
        }
      }

      try {
        return await Geolocator.getCurrentPosition();
      } catch (e) {
        if (e.toString().contains('permission') ||
            e.toString().contains('denied')) {
          final shouldRetry = await PermissionService.handleDeniedPermission(
            context,
            Permission.location,
            'Location',
          );

          if (shouldRetry) {
            return await Geolocator.getCurrentPosition();
          }
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }

    return null;
  }

  static Future<bool> _showLocationServicesDisabledDialog(
    BuildContext context,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Location Services Disabled'),
                content: const Text(
                  'To use this feature, you need to enable location services on your device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
