import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

class ContactInfoPage extends StatelessWidget {
  final UserModel user;

  const ContactInfoPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar for collapsible header with profile image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user.name),
              background: Image.network(
                user.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          // List of contact details and options
          SliverList(
            delegate: SliverChildListDelegate([
              // Section 1: Phone number and About
              _buildSection(context, [
                ListTile(
                  title: Text(user.phoneNumber),
                  subtitle: const Text("Mobile"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.message,
                          color: AppColors.primary,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: AppColors.primary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.videocam,
                          color: AppColors.primary,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(user.about),
                  subtitle: const Text("About"),
                ),
              ]),
              const SizedBox(height: 10),
              // Section 2: Media, links, and docs
              _buildSection(context, [
                const ListTile(
                  title: Text("Media, links, and docs"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ]),
              const SizedBox(height: 10),
              // Section 3: Notifications and Media visibility
              _buildSection(context, [
                const ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Mute notifications"),
                  trailing: Switch(value: false, onChanged: null),
                ),
                const ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text("Custom notifications"),
                ),
                const ListTile(
                  leading: Icon(Icons.image),
                  title: Text("Media visibility"),
                ),
              ]),
              const SizedBox(height: 10),
              // Section 4: Encryption and Disappearing messages
              _buildSection(context, [
                const ListTile(
                  leading: Icon(Icons.lock),
                  title: Text("Encryption"),
                  subtitle: Text(
                    "Messages and calls are end-to-end encrypted. Tap to verify.",
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.timer),
                  title: Text("Disappearing messages"),
                  subtitle: Text("Off"),
                ),
              ]),
              const SizedBox(height: 10),
              // Section 5: Block and Report
              _buildSection(context, [
                const ListTile(
                  leading: Icon(Icons.block, color: Colors.red),
                  title: Text("Block", style: TextStyle(color: Colors.red)),
                ),
                const ListTile(
                  leading: Icon(Icons.thumb_down, color: Colors.red),
                  title: Text(
                    "Report contact",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ]),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(children: children),
    );
  }
}
