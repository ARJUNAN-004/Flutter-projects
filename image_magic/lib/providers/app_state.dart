import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/conversion_service.dart';
import '../services/image_service.dart';

// State model
class ImageState {
  final XFile? originalImage;
  final String? convertedPath;
  final bool isConverting;
  final TargetFormat targetFormat;
  final int quality;
  final int? originalSize;
  final int? convertedSize;
  final Uint8List? webImageBytes;
  final Uint8List? convertedBytes;

  ImageState({
    this.originalImage,
    this.convertedPath,
    this.isConverting = false,
    this.targetFormat = TargetFormat.jpg,
    this.quality = 90,
    this.originalSize,
    this.convertedSize,
    this.webImageBytes,
    this.convertedBytes,
  });

  ImageState copyWith({
    XFile? originalImage,
    String? convertedPath,
    bool? isConverting,
    TargetFormat? targetFormat,
    int? quality,
    int? originalSize,
    int? convertedSize,
    Uint8List? webImageBytes,
    Uint8List? convertedBytes,
  }) {
    return ImageState(
      originalImage: originalImage ?? this.originalImage,
      convertedPath: convertedPath ?? this.convertedPath,
      isConverting: isConverting ?? this.isConverting,
      targetFormat: targetFormat ?? this.targetFormat,
      quality: quality ?? this.quality,
      originalSize: originalSize ?? this.originalSize,
      convertedSize: convertedSize ?? this.convertedSize,
      webImageBytes: webImageBytes ?? this.webImageBytes,
      convertedBytes: convertedBytes ?? this.convertedBytes,
    );
  }
}

// Controller
class ImageController extends StateNotifier<ImageState> {
  final ImageService _imageService;
  final ConversionService _conversionService;

  ImageController(this._imageService, this._conversionService)
    : super(ImageState());

  Future<void> pickImage(ImageSource source) async {
    final image = await _imageService.pickImage(source);
    if (image != null) {
      final size = await image.length();
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await image.readAsBytes();
      }
      state = state.copyWith(
        originalImage: image,
        convertedPath: null, // Reset previous conversion
        convertedSize: null,
        originalSize: size,
        webImageBytes: bytes,
        convertedBytes: null,
      );
    }
  }

  void updateFormat(TargetFormat format) {
    state = state.copyWith(targetFormat: format);
  }

  void updateQuality(int quality) {
    state = state.copyWith(quality: quality);
  }

  Future<void> convertImage() async {
    debugPrint("ImageController: convertImage called");
    if (state.originalImage == null) {
      debugPrint("ImageController: originalImage is null!");
      return;
    }

    state = state.copyWith(isConverting: true);
    debugPrint("ImageController: Conversion started...");

    try {
      final result = await _conversionService.convertImage(
        imageFile: state.originalImage!,
        format: state.targetFormat,
        quality: state.quality,
      );

      debugPrint(
        "ImageController: Service returned result. Path: ${result?.path}, Bytes: ${result?.bytes?.length}",
      );

      state = state.copyWith(
        isConverting: false,
        convertedPath: result?.path,
        convertedBytes: result?.bytes,
      );
      debugPrint("ImageController: State updated with result.");
    } catch (e) {
      debugPrint("ImageController: Error during conversion: $e");
      state = state.copyWith(isConverting: false);
    }
  }

  void reset() {
    state = ImageState();
  }
}

// Providers
final imageServiceProvider = Provider((ref) => ImageService());
final conversionServiceProvider = Provider((ref) => ConversionService());

final imageControllerProvider =
    StateNotifierProvider<ImageController, ImageState>((ref) {
      return ImageController(
        ref.watch(imageServiceProvider),
        ref.watch(conversionServiceProvider),
      );
    });
