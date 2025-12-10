import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state.dart';
import '../services/conversion_service.dart';
import 'result_screen.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageControllerProvider);
    final controller = ref.read(imageControllerProvider.notifier);

    // Listen for conversion success
    // Listen for conversion success
    ref.listen<ImageState>(imageControllerProvider, (prev, next) {
      final successMobile =
          prev?.convertedPath != next.convertedPath &&
          next.convertedPath != null;
      final successWeb =
          prev?.convertedBytes != next.convertedBytes &&
          next.convertedBytes != null;

      if (successMobile || successWeb) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ResultScreen()));
      }
    });

    if (state.originalImage == null) {
      return const Scaffold(body: Center(child: Text("No image selected")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Image")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb && state.webImageBytes != null
                  ? Image.memory(
                      state.webImageBytes!,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(state.originalImage!.path),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 24),

            // Format Selection
            const Text(
              "Select Format",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SegmentedButton<TargetFormat>(
              segments: const [
                ButtonSegment(value: TargetFormat.jpg, label: Text('JPG')),
                ButtonSegment(value: TargetFormat.png, label: Text('PNG')),
                ButtonSegment(value: TargetFormat.webp, label: Text('WEBP')),
              ],
              selected: {state.targetFormat},
              onSelectionChanged: (newSelection) {
                controller.updateFormat(newSelection.first);
              },
            ),

            const SizedBox(height: 24),

            // Quality Slider (only for JPG/WEBP)
            if (state.targetFormat != TargetFormat.png) ...[
              Text(
                "Quality: ${state.quality}%",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: state.quality.toDouble(),
                min: 10,
                max: 100,
                divisions: 90,
                label: state.quality.toString(),
                onChanged: (v) => controller.updateQuality(v.toInt()),
              ),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: state.isConverting
                  ? null
                  : () => controller.convertImage(),
              child: state.isConverting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Convert Image"),
            ),
          ],
        ),
      ),
    );
  }
}
