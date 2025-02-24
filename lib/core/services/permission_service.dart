import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> handleDeniedPermission(
    BuildContext context,
    Permission permission,
    String permissionName,
  ) async {
    if (await permission.isPermanentlyDenied) {
      final shouldOpenSettings = await _showPermissionPermanentlyDeniedDialog(
        context,
        permissionName,
      );

      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    } else {
      final shouldRequest = await _showPermissionRationaleDialog(
        context,
        permissionName,
      );

      if (shouldRequest) {
        final status = await permission.request();
        return status.isGranted;
      }
      return false;
    }
  }

  static Future<bool> _showPermissionRationaleDialog(
    BuildContext context,
    String permissionName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('$permissionName Access Needed'),
                content: Text(
                  'Akro needs $permissionName access to verify your checklist items. Would you like to grant this permission?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Not Now'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Continue'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  static Future<bool> _showPermissionPermanentlyDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('$permissionName Permission Required'),
                content: Text(
                  'This feature requires $permissionName permission to work. Please enable it in app settings.',
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
