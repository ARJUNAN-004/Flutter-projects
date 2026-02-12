import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_service.dart';
import '../../services/status_service.dart';
import '../../utils/colors.dart';

class ConfirmStatusPage extends StatefulWidget {
  final XFile file;

  const ConfirmStatusPage({super.key, required this.file});

  @override
  State<ConfirmStatusPage> createState() => _ConfirmStatusPageState();
}

class _ConfirmStatusPageState extends State<ConfirmStatusPage> {
  final TextEditingController _captionController = TextEditingController();
  final UserService _userService = UserService();
  bool _isUploading = false;

  void _uploadStatus() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await widget.file.readAsBytes();
      final filename =
          'status_${DateTime.now().millisecondsSinceEpoch}'; // proper extension needed in real app

      // Upload Image
      final imageUrl = await _userService.uploadImage(
        bytes,
        filename,
        folder: 'status_updates',
      );

      // Save Status Metadata to Firestore
      await StatusService().addStatus(imageUrl, _captionController.text);

      if (mounted) {
        Navigator.pop(context); // Close confirm page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload status: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: kIsWeb
                ? Image.network(
                    widget.file.path,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.file(
                    File(widget.file.path),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.secondary,
                    child: IconButton(
                      onPressed: _isUploading ? null : _uploadStatus,
                      icon: _isUploading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
