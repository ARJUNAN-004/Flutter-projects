import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io'; // Removed for web compatibility
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';

// Service class for handling Chat operations (Firestore & Cloudinary)
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudinary instance
  // REPLACE WITH YOUR CLOUD NAME AND UPLOAD PRESET
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'da7qor6kl',
    'whatsapp',
    cache: false,
  );

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Send a message (text or file)
  Future<void> sendMessage(
    String receiverId,
    String message, {
    String type = 'text',
    String? caption,
    bool isGroup = false,
    String? replyToId,
    String? replyMessage,
    String? replySender,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;
    final Timestamp timestamp = Timestamp.now();

    // Fetch sender name
    String senderName = 'Unknown';
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        senderName = userDoc['name'] ?? 'Unknown';
      }
    } catch (e) {
      // Error fetching sender name
    }

    // Create a new message
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderName': senderName, // Add sender name
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'type': type, // text, image, video, file
      'isRead': false,
      'isDelivered': false,
      if (caption != null) 'caption': caption,
      // Reply fields
      if (replyToId != null) 'replyToId': replyToId,
      if (replyMessage != null) 'replyMessage': replyMessage,
      if (replySender != null) 'replySender': replySender,
      'isEdited': false,
      'deletedBy': [],
    };

    String chatRoomId;
    if (isGroup) {
      chatRoomId = receiverId; // For groups, receiverId IS the chatRoomId
    } else {
      // Construct chat room ID (sorted to ensure uniqueness between two users)
      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      chatRoomId = ids.join("_");
    }

    // Add message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Update last message in chat room
    String lastMessageText = type == 'text' ? message : 'Sent a $type';

    Map<String, dynamic> updateData = {
      'lastMessage': lastMessageText,
      'lastMessageTime': timestamp,
      'lastMessageType': type,
    };

    if (!isGroup) {
      updateData['participants'] = [currentUserId, receiverId]..sort();
      updateData['unreadCounts'] = {receiverId: FieldValue.increment(1)};
    }

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set(updateData, SetOptions(merge: true));
  }

  // Delete message
  Future<void> deleteMessage(
    String receiverId,
    String messageId, {
    bool deleteForEveryone = false,
    bool isGroup = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String chatRoomId;
    if (isGroup) {
      chatRoomId = receiverId;
    } else {
      List<String> ids = [user.uid, receiverId];
      ids.sort();
      chatRoomId = ids.join("_");
    }

    DocumentReference messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    try {
      if (deleteForEveryone) {
        // 1. Get message details before update (to check timestamp)
        DocumentSnapshot messageDoc = await messageRef.get();
        Timestamp? messageTime;
        if (messageDoc.exists) {
          messageTime = messageDoc['timestamp'];
        }

        // 2. Mark as deleted for everyone
        await messageRef.update({
          'type': 'deleted',
          'message': 'This message was deleted',
        });

        // 3. Update Chat Room if this was the last message
        if (messageTime != null) {
          DocumentReference chatRoomRef = _firestore
              .collection('chat_rooms')
              .doc(chatRoomId);
          DocumentSnapshot chatRoomDoc = await chatRoomRef.get();

          if (chatRoomDoc.exists) {
            Timestamp? lastMessageTime = chatRoomDoc['lastMessageTime'];

            // Check if timestamps match (exact match might be tricky with FieldValue.serverTimestamp(),
            // but usually for stored messages it's a Timestamp object)
            // Using milliseconds comparison for safety
            if (lastMessageTime != null &&
                messageTime.millisecondsSinceEpoch ==
                    lastMessageTime.millisecondsSinceEpoch) {
              await chatRoomRef.update({
                'lastMessage': 'This message was deleted',
                'lastMessageType':
                    'text', // Reset type to text for the "deleted" msg
              });
            }
          }
        }
      } else {
        // Delete for me only (add to deletedBy array)
        await messageRef.update({
          'deletedBy': FieldValue.arrayUnion([user.uid]),
        });
      }
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  // Edit message
  Future<void> editMessage(
    String receiverId,
    String messageId,
    String newText, {
    bool isGroup = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String chatRoomId;
    if (isGroup) {
      chatRoomId = receiverId;
    } else {
      List<String> ids = [user.uid, receiverId];
      ids.sort();
      chatRoomId = ids.join("_");
    }

    DocumentReference messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    try {
      // 1. Get message details (timestamp)
      DocumentSnapshot messageDoc = await messageRef.get();
      Timestamp? messageTime;
      if (messageDoc.exists) {
        messageTime = messageDoc['timestamp'];
      }

      // 2. Update the message
      await messageRef.update({'message': newText, 'isEdited': true});

      // 3. Update Chat Room if this was the last message
      if (messageTime != null) {
        DocumentReference chatRoomRef = _firestore
            .collection('chat_rooms')
            .doc(chatRoomId);
        DocumentSnapshot chatRoomDoc = await chatRoomRef.get();

        if (chatRoomDoc.exists) {
          Timestamp? lastMessageTime = chatRoomDoc['lastMessageTime'];

          if (lastMessageTime != null &&
              messageTime.millisecondsSinceEpoch ==
                  lastMessageTime.millisecondsSinceEpoch) {
            await chatRoomRef.update({
              'lastMessage': newText,
              // Keep type as is (assuming edits are only for text/text-captions usually,
              // but if type was 'image' and we edit text? Actually editMessage only updates 'message' text field. Use caution.)
              // If the original type was image, 'lastMessage' might have been "Sent a photo".
              // If we edit the caption, we probably want to show the new caption or keep "Sent a photo"?
              // The current editMessage implies editing TEXT content.
              // Safe to update lastMessage to newText if it's a text message.
              // If it's an image with caption, 'message' field usually holds the caption or text.
            });
          }
        }
      }
    } catch (e) {
      print("Error editing message: $e");
    }
  }

  // Create a new group
  Future<void> createGroup(
    String groupName,
    XFile? groupImage,
    List<UserModel> participants,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;
    List<String> members =
        participants.map((u) => u.id!).toList() + [currentUserId];

    String? imageUrl;
    if (groupImage != null) {
      try {
        imageUrl = await uploadFile(groupImage);
      } catch (e) {
        print("Error uploading group image: $e");
      }
    }

    DocumentReference groupDoc = _firestore.collection('chat_rooms').doc();
    final Timestamp now = Timestamp.now();

    // Fetch user name for system message
    String senderName = 'Someone';
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        senderName = userDoc['name'] ?? 'Someone';
      }
    } catch (e) {
      // Ignore
    }

    String initialMessage = '$senderName created group "$groupName"';

    await groupDoc.set({
      'isGroup': true,
      'groupName': groupName,
      'groupImage': imageUrl ?? '',
      'adminId': currentUserId,
      'participants': members,
      'lastMessage': initialMessage,
      'lastMessageTime': now,
      'createdAt': now,
    });

    // Add System Message: "X created group Y"
    await groupDoc.collection('messages').add({
      'senderId': currentUserId,
      'senderName': senderName,
      'receiverId': groupDoc.id,
      'message': initialMessage,
      'timestamp': now,
      'type': 'system',
      'isRead': true,
      'isDelivered': true,
    });

    // Add System Message for each participant: "X added Y"
    for (int i = 0; i < participants.length; i++) {
      final participant = participants[i];
      await groupDoc.collection('messages').add({
        'senderId': currentUserId,
        'senderName': senderName,
        'receiverId': groupDoc.id,
        'message': '$senderName added ${participant.name}',
        'targetId': participant.id,
        'targetName': participant.name,
        'timestamp': Timestamp.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + 1 + i,
        ),
        'type': 'system',
        'isRead': true,
        'isDelivered': true,
      });
    }
  }

  // Upload file to Cloudinary
  Future<String> uploadFile(XFile file) async {
    try {
      // For Web compatibility, use bytes if path is not available or handled by Cloudinary plugin
      // CloudinaryPublic 0.23.1 supports uploadFile with CloudinaryFile.fromFile or fromBytesData
      // For cross-platform XFile, usually readAsBytes is safest for web.
      final bytes = await file.readAsBytes();
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: file.name,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      // Cloudinary error
      rethrow;
    }
  }

  // Send file message
  Future<void> sendFileMessage(
    String receiverId,
    XFile file,
    String type, {
    String? caption,
    bool isGroup = false,
  }) async {
    try {
      String downloadUrl = await uploadFile(file);
      await sendMessage(
        receiverId,
        downloadUrl,
        type: type, // 'audio', 'video', 'image', 'file'
        caption: caption,
        isGroup: isGroup,
      );
    } catch (e) {
      // Error sending file
    }
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(
    String userId,
    String otherUserId, {
    bool isGroup = false,
  }) {
    String chatRoomId;
    if (isGroup) {
      chatRoomId = otherUserId; // In group context, otherUserId is the group ID
    } else {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      chatRoomId = ids.join("_");
    }

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get user's chats (for Chat List)
  Stream<QuerySnapshot> getUserChats() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // 1. Update unread count in chat room
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'unreadCounts': {currentUserId: 0},
    }, SetOptions(merge: true));

    // 2. Mark individual messages as read AND delivered
    if (receiverId == currentUserId) return;

    var snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: receiverId)
        .where('isRead', isEqualTo: false)
        .get();

    try {
      if (snapshot.docs.isNotEmpty) {
        WriteBatch batch = _firestore.batch();
        for (var doc in snapshot.docs) {
          // Mark as read and also ensure delivered is true
          batch.update(doc.reference, {'isRead': true, 'isDelivered': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  // Mark messages as delivered
  Future<void> markMessagesAsDelivered(String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;

    if (receiverId == currentUserId) return;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Query messages sent by the OTHER user that are NOT delivered
    var messagesSnapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: receiverId)
        .where('isDelivered', isEqualTo: false)
        .get();

    try {
      if (messagesSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _firestore.batch();
        for (var doc in messagesSnapshot.docs) {
          // Check if document exists before updating logic, though batch handles refs
          batch.update(doc.reference, {'isDelivered': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print("Error marking messages as delivered: $e");
    }
  }

  // Mark ALL incoming messages as delivered (when app opens)
  Future<void> markAllIncomingMessagesAsDelivered() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final String currentUserId = user.uid;

    // Get all chat rooms where user is a participant
    var chatsSnapshot = await _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var chatDoc in chatsSnapshot.docs) {
      // For each chat room, find un-delivered messages NOT sent by us
      try {
        var messagesSnapshot = await chatDoc.reference
            .collection('messages')
            .where('isDelivered', isEqualTo: false)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          WriteBatch batch = _firestore.batch();
          bool hasUpdates = false;

          for (var doc in messagesSnapshot.docs) {
            final data = doc.data();
            // Filter client-side to avoid Index requirements
            if (data['senderId'] != currentUserId) {
              batch.update(doc.reference, {'isDelivered': true});
              hasUpdates = true;
            }
          }
          if (hasUpdates) {
            await batch.commit();
          }
        }
      } catch (e) {
        print(
          "Error marking incoming messages as delivered for chat ${chatDoc.id}: $e",
        );
      }
    }
  }
}
