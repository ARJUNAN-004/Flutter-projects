import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true, // Crucial for getting bytes on web immediately
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          // Create XFile from bytes if available, or path
          if (file.bytes != null) {
            return XFile.fromData(
              file.bytes!,
              name: file.name,
              mimeType: 'image/${file.extension}',
            );
          }
        }
        return null;
      } else {
        // Mobile
        final XFile? image = await _picker.pickImage(
          source: source,
          imageQuality: 100,
        );
        return image;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<bool> saveImageToGallery(String path) async {
    try {
      // Check for access permissions
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final access = await Gal.requestAccess();
        if (!access) return false;
      }

      await Gal.putImage(path);
      return true;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return false;
    }
  }
}
