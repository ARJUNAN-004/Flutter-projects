import 'dart:async';
// import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:whatsapp_clone_ui/models/user_model.dart';

import '../../models/message_model.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../services/call_service.dart';
import '../../models/call_model.dart';
import '../../widgets/message_bubble.dart';
import '../../utils/colors.dart';
import 'image_preview_page.dart';
import 'contact_info_page.dart';
import '../contacts/select_contact_page.dart';
import '../group/group_info_page.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit/zego_uikit.dart';

import '../call/call_page.dart';

// Chat Screen for messaging a specific user or group
class ChatPage extends StatefulWidget {
  final ChatModel chat;
  final String currentUserId;

  const ChatPage({super.key, required this.chat, required this.currentUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showEmoji = false;

  // Selection & Actions State
  final Map<String, MessageModel> _selectedMessages = {};
  MessageModel? _replyMessage;
  String? _editingMessageId;
  Timer? _refreshTimer;

  // Audio Recording State
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInit = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _chatService.markMessagesAsRead(widget.chat.id);
    _focusNode.addListener(_onFocusChange);
    // Refresh UI every minute to update "last seen/online" status if stream is stagnant
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      return;
    }
    await _recorder.openRecorder();
    _isRecorderInit = true;
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _refreshTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && mounted) {
      setState(() => _showEmoji = false);
    }
  }

  // Toggle selection of a message
  void _toggleSelection(MessageModel message) {
    setState(() {
      if (_selectedMessages.containsKey(message.id)) {
        _selectedMessages.remove(message.id);
      } else {
        _selectedMessages[message.id!] = message;
      }
    });
  }

  // Clear all selection
  void _clearSelection() {
    if (!mounted) return;
    setState(() {
      _selectedMessages.clear();
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  // Copy selected messages
  void _copySelectedMessages() {
    // Sort messages by time? Maps are not ordered by insertion usually but LinkedHashMap is.
    // We'll just join values.
    String textToCopy = _selectedMessages.values.map((m) => m.text).join("\n");
    Clipboard.setData(ClipboardData(text: textToCopy));
    _clearSelection();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  // Delete selected messages
  void _deleteSelectedMessages() async {
    bool canDeleteForEveryone = _selectedMessages.values.every((m) => m.isMe);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete message?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete for me
              for (String id in _selectedMessages.keys) {
                _chatService.deleteMessage(
                  widget.chat.id,
                  id,
                  deleteForEveryone: false,
                  isGroup: widget.chat.isGroup,
                );
              }
              _clearSelection();
            },
            child: const Text("Delete for me"),
          ),
          if (canDeleteForEveryone)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Delete for everyone
                for (String id in _selectedMessages.keys) {
                  _chatService.deleteMessage(
                    widget.chat.id,
                    id,
                    deleteForEveryone: true,
                    isGroup: widget.chat.isGroup,
                  );
                }
                _clearSelection();
              },
              child: const Text("Delete for everyone"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Reply to a message
  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyMessage = message;
      _selectedMessages.clear();
    });
    _focusNode.requestFocus();
  }

  // Edit a message
  void _editMessage(MessageModel message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.text;
      _selectedMessages.clear();
    });
    _focusNode.requestFocus();
  }

  // Forward message
  void _forwardMessage() {
    // Navigate to contact selector
    // Pass selected messages to next screen
    List<MessageModel> messagesToForward = _selectedMessages.values.toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectContactPage(forwardedMessages: messagesToForward),
      ),
    );
    _clearSelection();
  }

  // Navigate to Contact Info Page
  void _openContactInfo() async {
    if (widget.chat.isGroup) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupInfoPage(
            groupId: widget.chat.id,
            groupName: widget.chat.name,
            groupImage: widget.chat.image,
          ),
        ),
      );
      return;
    }

    final user = await _userService.getUserById(widget.chat.id);
    if (user != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactInfoPage(user: user)),
      );
    }
  }

  // Start Call
  void _startCall(bool isVideo) async {
    if (widget.chat.isGroup) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Group calls coming soon!")));
      return;
    }

    final currentUser = await _userService.getUserById(widget.currentUserId);
    if (currentUser == null) return;

    // Generate Call ID (Chat Room ID)
    List<String> ids = [widget.currentUserId, widget.chat.id];
    ids.sort();
    String callRoomId = ids.join("_");

    // Generate Log ID
    String callLogId = FirebaseFirestore.instance.collection('calls').doc().id;

    // Create Call Model
    CallModel newCall = CallModel(
      id: callLogId,
      callerId: currentUser.id!,
      callerName: currentUser.name,
      callerPic: currentUser.profileImageUrl,
      receiverId: widget.chat.id,
      receiverName: widget.chat.name,
      receiverPic: widget.chat.image,
      callId: callRoomId,
      type: isVideo ? CallType.video : CallType.audio,
      timestamp: Timestamp.now(),
    );

    // Log Call
    await CallService().createCall(newCall);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallPage(
          callId: callRoomId,
          userId: widget.currentUserId,
          userName: currentUser.name,
          isVideoCall: isVideo,
        ),
      ),
    );
  }

  // Send message function (Modified for Edit/Reply)
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      if (_editingMessageId != null) {
        // Handle Edit
        await _chatService.editMessage(
          widget.chat.id,
          _editingMessageId!,
          _messageController.text,
          isGroup: widget.chat.isGroup,
        );
        if (mounted) {
          setState(() {
            _editingMessageId = null;
          });
        }
      } else {
        // Handle Send (with optional Reply)
        await _chatService.sendMessage(
          widget.chat.id,
          _messageController.text,
          isGroup: widget.chat.isGroup,
          replyToId: _replyMessage?.id,
          replyMessage: _replyMessage?.text,
          replySender:
              _replyMessage?.senderName ??
              (_replyMessage?.isMe == true
                  ? "You"
                  : widget.chat.name), // Simplification.
        );
        if (mounted) {
          setState(() {
            _replyMessage = null;
          });
        }
      }

      if (!mounted) return;

      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInit) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/flutter_sound.aac';
      await _recorder.startRecorder(toFile: path);
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recorder: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    try {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        // Send audio message
        await _chatService.sendFileMessage(
          widget.chat.id,
          XFile(path),
          'audio',
          isGroup: widget.chat.isGroup,
        );
      }
    } catch (e) {
      print('Error stopping recorder: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Scroll to bottom (which is 0.0 in reverse ListView)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Pick image from gallery or camera
  void _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ImagePreviewPage(imageFile: image, receiverId: widget.chat.id),
        ),
      );
    }
  }

  // Show attachment options (Camera, Gallery, etc.)
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    color: Colors.pink,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_photo,
                    color: Colors.purple,
                    label: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.headset,
                    color: Colors.orange,
                    label: "Audio",
                    onTap: () {},
                  ),
                  _buildAttachmentOption(
                    icon: Icons.location_pin,
                    color: Colors.green,
                    label: "Location",
                    onTap: () {},
                  ),
                  _buildAttachmentOption(
                    icon: Icons.person,
                    color: Colors.blue,
                    label: "Contact",
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelectionMode = _selectedMessages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: isSelectionMode ? null : 40,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_showEmoji) {
                    setState(() => _showEmoji = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
        titleSpacing: isSelectionMode ? 0 : 0,
        title: isSelectionMode
            ? Text("${_selectedMessages.length}")
            : InkWell(
                onTap: _openContactInfo,
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.chat.image),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: widget.chat.image.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: widget.chat.isGroup
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.chat.name,
                                  style: const TextStyle(
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "Tap for group info",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            )
                          : StreamBuilder<UserModel>(
                              stream: _userService.getCurrentUserStream(
                                widget.chat.id,
                              ),
                              builder: (context, snapshot) {
                                final user = snapshot.data;
                                String statusText = "Offline";

                                if (user != null) {
                                  // Determine effective status
                                  bool effectiveOnline = user.isOnline;
                                  DateTime? effectiveLastSeen = user.lastSeen;

                                  if (effectiveOnline &&
                                      user.lastActive != null) {
                                    // If heartbeat is older than 2 minutes, treat as offline
                                    final difference = DateTime.now()
                                        .difference(user.lastActive!);
                                    if (difference.inMinutes > 2) {
                                      effectiveOnline = false;
                                      effectiveLastSeen = user.lastActive;
                                    }
                                  }

                                  if (effectiveOnline) {
                                    statusText = "Online";
                                  } else if (effectiveLastSeen != null) {
                                    // Format last seen time
                                    // Simple logic: "Last seen at HH:mm"
                                    final dt = effectiveLastSeen;
                                    final time =
                                        "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                                    // Could add "Yesterday" check here but keeping simple for now
                                    statusText = "Last seen at $time";
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.chat.name,
                                      style: const TextStyle(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      statusText,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
        actions: isSelectionMode
            ? [
                if (_selectedMessages.length == 1) ...[
                  IconButton(
                    onPressed: () =>
                        _replyToMessage(_selectedMessages.values.first),
                    icon: const Icon(Icons.reply),
                  ),
                ],
                IconButton(
                  onPressed: _deleteSelectedMessages,
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: _copySelectedMessages,
                  icon: const Icon(Icons.copy),
                ),
                IconButton(
                  onPressed: _forwardMessage,
                  icon: const Icon(Iconsax.forward),
                ),
                if (_selectedMessages.length == 1 &&
                    _selectedMessages.values.first.isMe &&
                    _selectedMessages.values.first.type == 'text') ...[
                  IconButton(
                    onPressed: () =>
                        _editMessage(_selectedMessages.values.first),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ]
            : [
                ZegoSendCallInvitationButton(
                  isVideoCall: true,
                  resourceID:
                      "zegouikit_call", // You need to specify the resourceID for offline call notification
                  invitees: [
                    ZegoUIKitUser(id: widget.chat.id, name: widget.chat.name),
                  ],
                  icon: ButtonIcon(icon: const Icon(Iconsax.video)),
                  // Customize button look to match app bar icon style if needed
                  iconSize: const Size(40, 40),
                  buttonSize: const Size(40, 40),
                ),
                ZegoSendCallInvitationButton(
                  isVideoCall: false,
                  resourceID: "zegouikit_call",
                  invitees: [
                    ZegoUIKitUser(id: widget.chat.id, name: widget.chat.name),
                  ],
                  icon: ButtonIcon(icon: const Icon(Iconsax.call)),
                  iconSize: const Size(40, 40),
                  buttonSize: const Size(40, 40),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 1, child: Text('View contact')),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Media, links, and docs'),
                    ),
                    const PopupMenuItem(value: 3, child: Text('Search')),
                    const PopupMenuItem(
                      value: 4,
                      child: Text('Mute notifications'),
                    ),
                    const PopupMenuItem(value: 5, child: Text('Wallpaper')),
                  ],
                ),
              ],
      ),
      body: PopScope(
        canPop: !_showEmoji,
        onPopInvoked: (didPop) {
          if (didPop) return;
          setState(() => _showEmoji = false);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.chatBackgroundDark
                : AppColors.chatBackgroundLight,
          ),
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildMessageInput(),
              if (_showEmoji)
                SizedBox(
                  height: 270,
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    config: Config(
                      height: 270,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        columns: 7,
                        emojiSizeMax:
                            28 *
                            (defaultTargetPlatform == TargetPlatform.iOS
                                ? 1.20
                                : 1.0),
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: CategoryViewConfig(
                        initCategory: Category.RECENT,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        iconColorSelected: Theme.of(
                          context,
                        ).colorScheme.primary,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        enabled: false,
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build list of messages
  // Build list of messages
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.currentUserId,
        widget.chat.id,
        isGroup: widget.chat.isGroup,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages"));
        }

        // Check if there are any unread messages from the other user
        bool hasUnread = snapshot.data!.docs.any((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['senderId'] != widget.currentUserId &&
              (data['isRead'] == false || data['isDelivered'] == false);
        });

        if (hasUnread) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _chatService.markMessagesAsRead(widget.chat.id);
            }
          });
        }

        return ListView(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 10),
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == widget.currentUserId;

    Timestamp t = data['timestamp'];
    DateTime date = t.toDate();
    String time = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";

    // Parse new fields
    String? replyToId = data['replyToId'];
    String? replyMessage = data['replyMessage'];
    String? replySender = data['replySender'];
    bool isEdited = data['isEdited'] ?? false;

    // Note: 'deletedBy' logic (hide if deleted for me) needs to be handled here or in stream.
    // If I deleted it for myself, it shouldn't show up.
    // Check 'deletedBy' array
    List<dynamic> deletedBy = data['deletedBy'] ?? [];
    if (deletedBy.contains(widget.currentUserId)) {
      return const SizedBox.shrink(); // Hide deleted message
    }

    MessageModel message = MessageModel(
      id: doc.id,
      text: data['message'] ?? '',
      isMe: isMe,
      time: time,
      type: data['type'] ?? 'text',
      caption: data['caption'],
      isRead: data['isRead'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      senderName: widget.chat.isGroup ? data['senderName'] : null,
      replyToId: replyToId,
      replyMessage: replyMessage,
      replySender: replySender,
      isEdited: isEdited,
    );

    bool isSelected = _selectedMessages.containsKey(message.id);

    return GestureDetector(
      onLongPress: () => _toggleSelection(message),
      onTap: () {
        if (_selectedMessages.isNotEmpty) {
          _toggleSelection(message);
        }
      },
      child: Container(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        child: MessageBubble(
          message: message,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  // Build message input field
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.transparent,
      child: Column(
        children: [
          // Reply Preview
          if (_replyMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Replying to ${_replyMessage!.senderName ?? '...'} ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          _replyMessage!.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _replyMessage = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                          if (_showEmoji) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          } else {
                            _focusNode.requestFocus();
                          }
                        },
                        icon: Icon(
                          _showEmoji
                              ? Icons.keyboard
                              : Icons.emoji_emotions_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: _messageController,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: const InputDecoration(
                            hintText: "Message",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _showAttachmentOptions,
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                      ),
                      IconButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Iconsax.camera, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, child) {
                  bool isTextEmpty = value.text.trim().isEmpty;
                  bool showMic = isTextEmpty && _editingMessageId == null;

                  return CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: showMic
                        ? GestureDetector(
                            onLongPress: _startRecording,
                            onLongPressEnd: (details) => _stopRecording(),
                            child: Icon(
                              _isRecording ? Icons.mic : Icons.mic_none,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : IconButton(
                            onPressed: _sendMessage,
                            icon: Icon(
                              _editingMessageId != null
                                  ? Icons.check
                                  : Icons.send,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
