import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import '../providers/app_state.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageControllerProvider);

    if (state.convertedPath == null && state.convertedBytes == null) {
      return const Scaffold(body: Center(child: Text("No result")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Success!")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              "Image Converted Successfully",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb && state.convertedBytes != null
                  ? Image.memory(state.convertedBytes!)
                  : Image.file(File(state.convertedPath!)),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (kIsWeb) {
                        if (state.convertedBytes != null) {
                           final file = XFile.fromData(
                             state.convertedBytes!,
                             name: 'converted_image.${state.targetFormat.name}',
                             mimeType: 'image/${state.targetFormat.name}',
                           );
                           await Share.shareXFiles([file]);
                        }
                      } else {
                        if (state.convertedPath != null) {
                          await Share.shareXFiles([XFile(state.convertedPath!)]);
                        }
                      }
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                  ),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await Gal.putImage(state.convertedPath!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Saved to Gallery!")),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Error: $e")));
                          }
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(imageControllerProvider.notifier).reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Convert Another"),
            ),
          ],
        ),
      ),
    );
  }
}
