// Message Model representing a single chat message
class MessageModel {
  final String? id; // Document ID
  final String text; // Message content
  final bool isMe; // True if sent by current user
  final String time; // Formatted time string
  final String type; // Message type (text, image, system, deleted, etc.)
  final String? caption; // Optional caption for media
  final bool isRead; // Read status
  final bool isDelivered; // Delivery status

  final String? senderName; // Sender name for group chats

  // New fields for Actions
  final String? replyToId;
  final String? replyMessage;
  final String? replySender;
  final bool isEdited;
  final List<dynamic>
  deletedBy; // List of user IDs who deleted this message for themselves

  // System Message Fields
  final String?
  targetId; // ID of the user this system message is about (e.g., added user)
  final String? targetName; // Name of the user this system message is about

  MessageModel({
    this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.type = 'text',
    this.caption,
    this.isRead = false,
    this.isDelivered = false,
    this.senderName,
    this.replyToId,
    this.replyMessage,
    this.replySender,
    this.isEdited = false,
    this.deletedBy = const [],
    this.targetId,
    this.targetName,
  });
}

// Dummy Data
List<MessageModel> dummyMessages = [
  MessageModel(text: "Hi there!", isMe: false, time: "10:00 AM"),
  MessageModel(text: "Hello! How's it going?", isMe: true, time: "10:01 AM"),
  MessageModel(
    text: "Pretty good, working on a Flutter app.",
    isMe: false,
    time: "10:02 AM",
  ),
  MessageModel(text: "That sounds awesome!", isMe: true, time: "10:03 AM"),
];
