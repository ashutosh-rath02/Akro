import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'permission_service.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto({required BuildContext context}) async {
    try {
      XFile? photo;

      try {
        photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          preferredCameraDevice: CameraDevice.rear,
        );
      } catch (e) {
        if (e.toString().contains('permission') ||
            e.toString().contains('denied')) {
          final shouldRetry = await PermissionService.handleDeniedPermission(
            context,
            Permission.camera,
            'Camera',
          );

          if (shouldRetry) {
            photo = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 80,
              preferredCameraDevice: CameraDevice.rear,
            );
          }
        } else {
          rethrow;
        }
      }

      if (photo != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'checklist_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File(path.join(directory.path, fileName));

        await savedImage.writeAsBytes(await photo.readAsBytes());
        return savedImage.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}
