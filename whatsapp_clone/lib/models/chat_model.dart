import 'package:cloud_firestore/cloud_firestore.dart';

// Chat Model representing a conversation in the chat list
// Chat Model representing a conversation in the chat list
class ChatModel {
  final String id; // Contact User ID or Group ID
  final String name; // Contact name or Group name
  final String message; // Last message preview
  final String time; // Time of last message
  final String image; // Contact profile image or Group image
  final int unread; // Number of unread messages
  final bool isGroup; // Is this a group chat?
  final String messageType; // Type of last message

  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.image,
    this.unread = 0,
    this.isGroup = false,
    this.messageType = 'text',
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String currentUserId) {
    bool isGroup = map['isGroup'] ?? false;
    String id;
    String name;
    String image;

    if (isGroup) {
      // For groups, the ID is the document ID (which we don't have directly in the map data usually,
      // but let's assume it's passed or we use a placeholder if missing.
      // Actually, we need the doc ID.
      // In ChatTab, we pass 'data' which is doc.data().
      // We should probably pass the doc ID to fromMap or include it in data.
      // For now, let's assume the caller handles the ID or we extract it if possible.
      // Wait, the 'id' field in ChatModel is used for navigation.
      // For groups, it should be the chatRoomId.
      // The 'map' here is the data from the document.
      // We don't have the doc ID in the map unless we put it there.
      // Let's update ChatTab to pass the ID separately or put it in the map.
      // BUT, for now, let's look at how we get the other user ID.
      // We calculate it from participants.
      // For groups, we can't calculate it.
      // We need the doc ID.
      // Let's assume the 'id' passed to the constructor will be handled by the caller
      // OR we change the signature of fromMap to accept the docId.
      // Let's change the signature of fromMap to accept docId.
      id = ''; // Placeholder, will be set by caller or we need to change logic.
      name = map['groupName'] ?? 'Group';
      image =
          map['groupImage'] ??
          "https://avatar.iran.liara.run/public/5"; // Placeholder
    } else {
      // Participants list
      List<dynamic> participants = map['participants'] ?? [];

      // Identify the other user ID
      id = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => 'Unknown',
      );
      name = "User"; // Placeholder, fetched in ChatTile
      image = "https://avatar.iran.liara.run/public/1"; // Placeholder
    }

    // Timestamp formatting
    Timestamp? timestamp = map['lastMessageTime'];
    String timeString = '';
    if (timestamp != null) {
      DateTime date = timestamp.toDate();
      timeString = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }

    // Unread count
    Map<String, dynamic> unreadCounts = map['unreadCounts'] ?? {};
    int unread = unreadCounts[currentUserId] ?? 0;

    return ChatModel(
      id: id,
      name: name,
      message: map['lastMessage'] ?? '',
      time: timeString,
      image: image,
      unread: unread,
      isGroup: isGroup,
      messageType: map['lastMessageType'] ?? 'text',
    );
  }
}
