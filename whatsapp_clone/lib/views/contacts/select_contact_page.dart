import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart'; // Added import
import '../../models/chat_model.dart';
import '../../services/user_service.dart';
import '../../services/chat_service.dart';
import '../chat/chat_page.dart';

// Screen to search and select a contact to chat with
class SelectContactPage extends StatefulWidget {
  final List<MessageModel>? forwardedMessages;

  const SelectContactPage({super.key, this.forwardedMessages});

  @override
  State<SelectContactPage> createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _users = [];
  bool _isLoading = false;

  // Search users by query
  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _users = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _users = users;
      });
    } catch (e) {
      // Error searching users
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _searchUsers,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search name or number...",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(
              child: Text(
                "Search for users to start a chat",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  onTap: () {
                    final ChatService chatService = ChatService();
                    final String currentUserId = chatService.currentUserId!;

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

                    // Check if we have forwarded messages
                    if (widget.forwardedMessages != null &&
                        widget.forwardedMessages!.isNotEmpty) {
                      for (var msg in widget.forwardedMessages!) {
                        String type = msg.type;
                        if (type == 'text' ||
                            type == 'image' ||
                            type == 'video') {
                          chatService.sendMessage(
                            user.id,
                            msg.text,
                            type: type,
                            // Ensure we don't carry over replies or edit status
                          );
                        }
                      }

                      // Show confirmation
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Messages forwarded")),
                      // );
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatPage(chat: chat, currentUserId: currentUserId),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.about),
                );
              },
            ),
    );
  }
}
