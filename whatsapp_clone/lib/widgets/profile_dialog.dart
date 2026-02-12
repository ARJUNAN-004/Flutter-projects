import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../views/chat/chat_page.dart';
import '../views/chat/contact_info_page.dart';
import '../utils/colors.dart';

class ProfileDialog extends StatelessWidget {
  final UserModel user;

  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 300,
        width: 300,
        child: Column(
          children: [
            // Image and Name Overlay
            Expanded(
              child: Stack(
                children: [
                  // Profile Image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: NetworkImage(user.profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Top Overlay with User Name
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Actions Bar (Message & Info)
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.symmetric(
                vertical: 2,
              ), // Reduced padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Message Button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog

                      final ChatService chatService = ChatService();
                      final String? currentUserId = chatService.currentUserId;
                      if (currentUserId == null) return;

                      // Create a temporary ChatModel for navigation
                      final chat = ChatModel(
                        id: user.id,
                        name: user.name,
                        message: '', // No message yet
                        time: '',
                        image: user.profileImageUrl,
                        unread: 0,
                        isGroup: false,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chat: chat,
                            currentUserId: currentUserId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.message, color: AppColors.primary),
                  ),
                  // Info Button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactInfoPage(user: user),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
