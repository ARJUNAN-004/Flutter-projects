import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp_clone_ui/models/user_model.dart';
import '../../services/user_service.dart';

class GroupInfoPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;

  const GroupInfoPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupImage,
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final UserService _userService = UserService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var groupData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> participantIds = groupData['participants'] ?? [];
          String groupName = groupData['groupName'] ?? widget.groupName;
          String groupImage = groupData['groupImage'] ?? widget.groupImage;
          String adminId = groupData['adminId'] ?? '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(groupName),
                  background: groupImage.isNotEmpty
                      ? Image.network(
                          groupImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey,
                            child: const Icon(
                              Icons.group,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          color: theme.primaryColor,
                          child: const Icon(
                            Icons.group,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${participantIds.length} participants",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  String userId = participantIds[index];
                  return FutureBuilder<UserModel?>(
                    future: _userService.getUserById(userId),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text("Loading..."),
                        );
                      }

                      UserModel user = userSnapshot.data!;
                      bool isAdmin = user.id == adminId;
                      bool isMe = user.id == currentUserId;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.profileImageUrl),
                        ),
                        title: Text(isMe ? "You" : user.name),
                        subtitle: Text(user.about),
                        trailing: isAdmin
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Group Admin",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  );
                }, childCount: participantIds.length),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Exit Group"),
                    onPressed: () => _exitGroup(participantIds),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _exitGroup(List<dynamic> currentParticipants) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit Group?"),
            content: const Text("Are you sure you want to leave this group?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Exit", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        List<dynamic> updatedParticipants = List.from(currentParticipants);
        updatedParticipants.remove(currentUserId);

        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(widget.groupId)
            .update({'participants': updatedParticipants});

        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error leaving group: $e")));
        }
      }
    }
  }
}
