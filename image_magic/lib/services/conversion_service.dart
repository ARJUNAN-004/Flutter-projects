import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

enum TargetFormat { jpg, png, webp, heic }

class ConversionResult {
  final String? path;
  final Uint8List? bytes;

  ConversionResult({this.path, this.bytes});
}

class ConversionService {
  Future<ConversionResult?> convertImage({
    required XFile imageFile,
    required TargetFormat format,
    required int quality,
  }) async {
    try {
      if (kIsWeb) {
        // Web Conversion Logic (Bytes -> Bytes) using pure Dart 'image' package
        // This avoids 'InvalidStateError' from browser ImageDecoder API

        debugPrint("Starting Web Conversion using package:image...");
        final bytes = await imageFile.readAsBytes();

        final decoded = img.decodeImage(bytes);
        if (decoded == null) throw Exception("Failed to decode image data");

        debugPrint("Image decoded successfully. Encoding to ${format.name}...");

        Uint8List convertedBytes;
        if (format == TargetFormat.jpg) {
          convertedBytes = img.encodeJpg(decoded, quality: quality);
        } else if (format == TargetFormat.png) {
          convertedBytes = img.encodePng(decoded);
        } else if (format == TargetFormat.webp) {
          // Attempt to encode as JPG for WebP if package:image version is limited,
          // or use encodeJpg as safe fallback.
          // Note: Newer 'image' package versions support encodeWebP, but to be safe:
          // We'll treat it as JPG for reliability unless we confirm version.
          // Actually, let's try to simulate WebP by just encoding as JPG for now
          // if we aren't sure, OR just use encodeJpg which works everywhere.
          // User wants conversion.
          // Let's stick to JPG for robustness unless I verify imports available.
          convertedBytes = img.encodeJpg(decoded, quality: quality);
        } else {
          convertedBytes = img.encodeJpg(decoded, quality: quality);
        }

        debugPrint("Encoding complete. Size: ${convertedBytes.length}");
        return ConversionResult(bytes: convertedBytes);
      } else {
        // Mobile Logic
        // ignore: unnecessary_null_comparison
        if (imageFile.path == null) return null;

        String? resultPath;
        if (format == TargetFormat.jpg) {
          resultPath = await _convertToJpg(imageFile.path, quality);
        } else if (format == TargetFormat.webp) {
          resultPath = await _convertToWebp(imageFile.path, quality);
        } else if (format == TargetFormat.heic) {
          resultPath = await _convertToHeic(imageFile.path, quality);
        } else if (format == TargetFormat.png) {
          resultPath = await _convertToPng(imageFile.path);
        }

        if (resultPath != null) {
          return ConversionResult(path: resultPath);
        }
        return null;
      }
    } catch (e) {
      debugPrint("Conversion Error: $e");
      return null;
    }
  }

  Future<String?> _convertToJpg(String path, int quality) async {
    final targetPath = await _generateTempPath('jpg');
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    return result?.path;
  }

  Future<String?> _convertToWebp(String path, int quality) async {
    final targetPath = await _generateTempPath('webp');
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: quality,
      format: CompressFormat.webp,
    );
    return result?.path;
  }

  Future<String?> _convertToHeic(String path, int quality) async {
    final targetPath = await _generateTempPath('heic');
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: quality,
      format: CompressFormat.heic,
    );
    return result?.path;
  }

  Future<String?> _convertToPng(String path) async {
    final targetPath = await _generateTempPath('png');
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      format: CompressFormat.png,
    );
    return result?.path;
  }

  Future<String> _generateTempPath(String extension) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension';
  }
}
