import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import 'audio_bubble.dart';

import 'package:any_link_preview/any_link_preview.dart';

// Widget for displaying a single message bubble
// Widget for displaying a single message bubble
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // System Message Handling
    if (message.type == 'system') {
      String text = message.text;

      if (message.targetId != null) {
        String actor = message.isMe ? "You" : (message.senderName ?? "Someone");
        String target = message.targetId == currentUserId
            ? "you"
            : (message.targetName ?? "someone");
        text = "$actor added $target";
      } else if (message.text.contains("created group") && message.isMe) {
        // Replace sender name with You if simpler
        // Assuming text format "$senderName created group..."
        // We can just rely on replacing the start if it matches senderName?
        // Or just construct it if we had groupName. We don't.
        // Brittle replace:
        if (message.senderName != null) {
          text = text.replaceFirst(message.senderName!, "You");
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = message.isMe;

    final bubbleColor = isMe
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final metaTextColor = isMe
        ? colorScheme.onPrimary.withOpacity(0.7)
        : colorScheme.onSurfaceVariant.withOpacity(0.7);

    // Deleted Message Handling
    if (message.type == 'deleted') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isMe
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.surfaceContainerHighest.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    size: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "This message was deleted",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe
                  ? const Radius.circular(12)
                  : const Radius.circular(0),
              bottomRight: isMe
                  ? const Radius.circular(0)
                  : const Radius.circular(12),
            ),
          ),
          color: bubbleColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reply Preview
                if (message.replyMessage != null)
                  Container(
                    // width: double.infinity, // Removed to allow shrink wrap
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.secondary,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.replySender ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message.replyMessage!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sender Name (for group chats)
                if (!isMe && message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      message.senderName!,
                      style: TextStyle(
                        color: colorScheme.tertiary, // Use tertiary for name
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                // Image Message
                if (message.type == 'image')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            message.text, // URL is stored in text
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: textColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: textColor,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Image not available",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (message.caption != null &&
                            message.caption!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 2),
                            child: Text(
                              message.caption!,
                              style: TextStyle(fontSize: 16, color: textColor),
                            ),
                          ),
                      ],
                    ),
                  )
                // File Message
                else if (message.type == 'file')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_drive_file, color: textColor),
                        const SizedBox(width: 10),
                        Text(
                          "File",
                          style: TextStyle(
                            color: textColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  )
                // Audio Message
                else if (message.type == 'audio')
                  AudioBubble(url: message.text, isMe: isMe)
                // Text Message (with optional Link Preview)
                else ...[
                  if (_containsUrl(message.text))
                    AnyLinkPreview(
                      link: _extractUrl(message.text),
                      showMultimedia: true,
                      bodyMaxLines: 2,
                      bodyTextOverflow: TextOverflow.ellipsis,
                      titleStyle: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      bodyStyle: TextStyle(color: metaTextColor, fontSize: 12),
                      errorBody: 'Could not preview link',
                      errorTitle: 'Error',
                      errorWidget: Container(
                        color: Colors.transparent,
                        child: Text(
                          message.text,
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                      ),
                      backgroundColor: isMe
                          ? Colors.black.withOpacity(0.1)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: 12,
                      removeElevation: true,
                      boxShadow: const [],
                      onTap: () {}, // Handle tap if needed
                    ),

                  // Adaptive Layout Logic
                  Builder(
                    builder: (context) {
                      final bool isLink = _containsUrl(message.text);
                      // Fallback to Column behavior for links
                      if (isLink) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildTimestampRow(
                                  message,
                                  isMe,
                                  metaTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Measure Text
                      final textStyle = TextStyle(
                        fontSize: 16,
                        color: textColor,
                      );
                      final textSpan = TextSpan(
                        text: message.text,
                        style: textStyle,
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        textDirection: TextDirection.ltr,
                      );

                      // Max width for the bubble content
                      final maxBubbleWidth =
                          MediaQuery.of(context).size.width * 0.7 - 20;

                      textPainter.layout(maxWidth: maxBubbleWidth);

                      // Measure Timestamp
                      double timestampWidth = 65; // Base estimate
                      if (message.isEdited) timestampWidth += 35;
                      if (isMe) timestampWidth += 20; // Checkmark
                      const double spacing = 10;

                      bool fitsOnOneLine =
                          (textPainter.width + spacing + timestampWidth) <
                          maxBubbleWidth;
                      bool isSingleLineText =
                          textPainter.computeLineMetrics().length <= 1;

                      if (fitsOnOneLine && isSingleLineText) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(message.text, style: textStyle),
                              ),
                              const SizedBox(width: 8),
                              _buildTimestampRow(message, isMe, metaTextColor),
                            ],
                          ),
                        );
                      } else {
                        // Standard Column Layout
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message.text, style: textStyle),
                              const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.centerRight,
                                child: _buildTimestampRow(
                                  message,
                                  isMe,
                                  metaTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _containsUrl(String text) {
    final urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?",
    );
    return urlRegExp.hasMatch(text);
  }

  String _extractUrl(String text) {
    final urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?",
    );
    return urlRegExp.firstMatch(text)?.group(0) ?? '';
  }

  Widget _buildTimestampRow(
    MessageModel message,
    bool isMe,
    Color metaTextColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Text("Edited", style: TextStyle(fontSize: 10, color: metaTextColor)),
          const SizedBox(width: 4),
        ],
        Text(
          message.time,
          style: TextStyle(fontSize: 10, color: metaTextColor),
        ),
        if (isMe) ...[
          const SizedBox(width: 5),
          Icon(
            message.isRead || message.isDelivered
                ? Icons.done_all
                : Icons.check,
            size: 14,
            color: message.isRead
                ? (isMe ? Colors.white : Colors.blue)
                : metaTextColor,
          ),
        ],
      ],
    );
  }
}
