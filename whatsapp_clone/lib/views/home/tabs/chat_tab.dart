import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../../../widgets/chat_tile.dart';

class ChatTab extends StatelessWidget {
  final String searchQuery;

  const ChatTab({super.key, this.searchQuery = ""});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String? currentUserId = chatService.currentUserId;
    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // StreamBuilder listens to real-time updates from Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getUserChats(),
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading chats"));
        }

        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle empty state (no chats found)
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No chats yet. Start a new one!",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Get the list of docs
        var docs = snapshot.data!.docs;

        // If searching, we need to filter.
        // Since ChatModel doesn't have the name (it's fetched in ChatTile),
        // we need to fetch user details here to filter.
        if (searchQuery.isNotEmpty) {
          return FutureBuilder<List<DocumentSnapshot>>(
            future: _filterDocs(docs, currentUserId, searchQuery),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!futureSnapshot.hasData || futureSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return _buildChatList(futureSnapshot.data!, currentUserId);
            },
          );
        }

        // If not searching, just build the list
        return _buildChatList(docs, currentUserId);
      },
    );
  }

  // Helper to filter docs by fetching user names
  Future<List<DocumentSnapshot>> _filterDocs(
    List<QueryDocumentSnapshot> docs,
    String currentUserId,
    String query,
  ) async {
    List<DocumentSnapshot> filteredDocs = [];
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> participants = data['participants'] ?? [];
      String otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (otherUserId.isNotEmpty) {
        // Fetch user data
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();
        if (userDoc.exists) {
          String name = userDoc.data()?['name'] ?? '';
          if (name.toLowerCase().contains(query.toLowerCase())) {
            filteredDocs.add(doc);
          }
        }
      }
    }
    return filteredDocs;
  }

  Widget _buildChatList(List<DocumentSnapshot> docs, String currentUserId) {
    return ListView.separated(
      itemCount: docs.length,
      // Divider between chat items
      separatorBuilder: (context, index) =>
          Divider(height: 1, thickness: 1, color: Colors.grey[800]),
      itemBuilder: (context, index) {
        // Extract chat data and convert to ChatModel
        var doc = docs[index];
        var data = doc.data() as Map<String, dynamic>;
        ChatModel chat = ChatModel.fromMap(data, currentUserId);

        // If it's a group, the ID in ChatModel might be empty because we didn't pass the doc ID.
        // Let's fix ChatModel to accept the ID or set it here.
        // Actually, let's just create a new ChatModel with the correct ID if it's a group.
        if (chat.isGroup) {
          chat = ChatModel(
            id: doc.id, // The document ID is the chat room ID for groups
            name: chat.name,
            message: chat.message,
            time: chat.time,
            image: chat.image,
            unread: chat.unread,
            isGroup: true,
          );
        }

        return ChatTile(chat: chat);
      },
    );
  }
}
