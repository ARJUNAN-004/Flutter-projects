import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/chat_service.dart';
import '../../utils/colors.dart';

// Screen to preview and caption image before sending
class ImagePreviewPage extends StatefulWidget {
  final XFile imageFile;
  final String receiverId;

  const ImagePreviewPage({
    super.key,
    required this.imageFile,
    required this.receiverId,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  final TextEditingController _captionController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isSending = false;

  // Send image with caption
  void _sendImage() async {
    setState(() => _isSending = true);
    try {
      await _chatService.sendFileMessage(
        widget.receiverId,
        widget.imageFile,
        'image',
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context); // Close preview
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending image: $e")));
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_rotate, color: Colors.white),
            onPressed: () {}, // Placeholder for crop
          ),
          IconButton(
            icon: const Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.white,
            ),
            onPressed: () {}, // Placeholder for emoji
          ),
          IconButton(
            icon: const Icon(Icons.title, color: Colors.white),
            onPressed: () {}, // Placeholder for text on image
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {}, // Placeholder for draw
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: kIsWeb
                ? Image.network(widget.imageFile.path)
                : Image.file(File(widget.imageFile.path)),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black38,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Add a caption...",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: _isSending
                        ? const CircularProgressIndicator(color: Colors.white)
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendImage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
