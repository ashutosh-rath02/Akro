// lib/core/services/photo_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        // Save to app directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            'checklist_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File(path.join(directory.path, fileName));

        await savedImage.writeAsBytes(await photo.readAsBytes());
        return savedImage.path;
      }
      return null;
    } catch (e) {
      print('Error capturing photo: $e');
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
      print('Error deleting photo: $e');
    }
  }
}
