import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../models/status_model.dart';
import '../../../services/status_service.dart';
import '../../../services/user_service.dart';
import '../../status/confirm_status_page.dart';
import '../../status/status_view_page.dart';

// Tab for displaying status updates
class StatusTab extends StatelessWidget {
  const StatusTab({super.key});

  Future<void> _pickStatusImage(BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmStatusPage(file: pickedFile),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // My Status Section
        StreamBuilder<QuerySnapshot>(
          stream: StatusService().getMyStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red),
                title: Text("Error loading status: ${snapshot.error}"),
                subtitle: const Text("Check console for details"),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a skeleton or loading state if needed, but for now just fallback to empty
              // so it doesn't flicker too much, or show a loader.
              // Actually, keeping silent while loading is common for cached data,
              // but for debugging let's assume it might hang.
            }

            final myStatusDocs = snapshot.data?.docs ?? [];
            final now = DateTime.now();
            final cutoff = now.subtract(const Duration(hours: 24));

            final myStatuses =
                myStatusDocs
                    .map(
                      (doc) => StatusModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .where((status) => status.timestamp.isAfter(cutoff))
                    .toList()
                  ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            final hasStatus = myStatuses.isNotEmpty;

            // Fetch current user image separately
            return StreamBuilder<UserModel>(
              stream: AuthService().currentUserStream,
              builder: (context, userSnapshot) {
                String? imageUrl = userSnapshot.data?.profileImageUrl;

                return ListTile(
                  onTap: () {
                    if (hasStatus) {
                      // View Status
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusViewPage(
                            statuses: myStatuses,
                            isMe: true,
                            userName: "My Status",
                            profileImageUrl: imageUrl,
                          ),
                        ),
                      );
                    } else {
                      // Add Status
                      _pickStatusImage(context);
                    }
                  },
                  leading: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: hasStatus
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              )
                            : null,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              imageUrl != null && imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: imageUrl == null || imageUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                      if (!hasStatus)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text(
                    "My Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    hasStatus
                        ? "Tap to view status update"
                        : "Tap to add status update",
                  ),
                );
              },
            );
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            "Recent updates",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),

        // Recent Updates Section
        StreamBuilder<QuerySnapshot>(
          stream: StatusService().getRecentStatusUpdates(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final currentUserId = AuthService().currentUser?.uid;

            // Group statuses by UID
            final Map<String, List<StatusModel>> groupedStatuses = {};
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              // Skip current user's statuses in this list
              if (data['uid'] == currentUserId) continue;

              final status = StatusModel.fromMap(data, doc.id);
              if (!groupedStatuses.containsKey(status.uid)) {
                groupedStatuses[status.uid] = [];
              }
              groupedStatuses[status.uid]!.add(status);
            }

            if (groupedStatuses.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No recent updates"),
              );
            }

            return Column(
              children: groupedStatuses.entries.map((entry) {
                final uid = entry.key;
                final statuses = entry.value;
                return _StatusUserTile(uid: uid, statuses: statuses);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StatusUserTile extends StatelessWidget {
  final String uid;
  final List<StatusModel> statuses;

  const _StatusUserTile({required this.uid, required this.statuses});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: UserService().getUserById(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          // You might want to show a skeleton or nothing while loading
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        final latestStatus = statuses.first; // Assumes sorted desc
        final timestamp = latestStatus.timestamp;
        final timeString =
            "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}";

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatusViewPage(
                  statuses: statuses,
                  isMe: false,
                  userName: user.name,
                  profileImageUrl: user.profileImageUrl,
                ),
              ),
            );
          },
          leading: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.grey[300],
              backgroundImage: user.profileImageUrl.isNotEmpty
                  ? NetworkImage(user.profileImageUrl)
                  : null,
              child: user.profileImageUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Today, $timeString"),
        );
      },
    );
  }
}
