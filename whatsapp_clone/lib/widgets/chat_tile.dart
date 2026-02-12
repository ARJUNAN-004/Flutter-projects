import 'package:flutter/material.dart';
import 'profile_dialog.dart';
import '../../models/chat_model.dart';
import '../../views/chat/chat_page.dart';

import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../../models/user_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;

  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final ChatService chatService = ChatService();
    final String? currentUserId = chatService.currentUserId;
    if (currentUserId == null) return const SizedBox.shrink();

    // If it's a group, we don't need to fetch user data
    if (chat.isGroup) {
      return _buildTile(context, chat, currentUserId);
    }

    // For 1-on-1, fetch other user's data to get latest name/image
    return StreamBuilder<UserModel>(
      stream: userService.getCurrentUserStream(chat.id),
      builder: (context, snapshot) {
        // Use chat model data as fallback while loading or if error
        String displayName = chat.name;
        String displayImage = chat.image;

        if (snapshot.hasData) {
          displayName = snapshot.data!.name;
          displayImage = snapshot.data!.profileImageUrl;
        }

        // Create a temporary chat model with updated info for navigation
        ChatModel updatedChat = ChatModel(
          id: chat.id,
          name: displayName,
          message: chat.message,
          time: chat.time,
          image: displayImage,
          unread: chat.unread,
          isGroup: false,
          messageType: chat.messageType,
        );

        return _buildTile(
          context,
          updatedChat,
          currentUserId,
          user: snapshot.data,
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    ChatModel chatItem,
    String currentUserId, {
    UserModel? user,
  }) {
    return ListTile(
      // Navigate to Chat Page on tile tap
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(chat: chatItem, currentUserId: currentUserId),
          ),
        );
      },
      // Profile Picture with Tap Action
      leading: GestureDetector(
        onTap: () {
          // Show Profile Dialog on tap
          if (user != null) {
            showDialog(
              context: context,
              builder: (context) => ProfileDialog(user: user),
            );
          } else if (chatItem.isGroup) {
            // Optional: Show group info dialog
          }
        },
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(chatItem.image),
          onBackgroundImageError: (exception, stackTrace) {},
          child: chatItem.image.isEmpty ? const Icon(Icons.person) : null,
        ),
      ),
      title: Text(
        chatItem.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          if (chatItem.messageType == 'image') ...[
            const Icon(Icons.photo_camera, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              chatItem.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chatItem.time,
            style: TextStyle(
              color: chatItem.unread > 0 ? Colors.green : Colors.grey,
              fontSize: 12,
            ),
          ),
          if (chatItem.unread > 0) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                chatItem.unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
