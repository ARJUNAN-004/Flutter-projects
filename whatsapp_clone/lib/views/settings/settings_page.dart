import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../services/auth_service.dart';
import '../auth/phone_login_page.dart';
import '../../models/user_model.dart';
import 'profile_page.dart';
import 'subpages/account_settings_page.dart';
import 'subpages/privacy_settings_page.dart';
import 'subpages/chats_settings_page.dart';
import 'subpages/notifications_settings_page.dart';
import 'subpages/storage_settings_page.dart';
import 'subpages/help_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder<UserModel>(
        stream: AuthService().currentUserStream,
        builder: (context, snapshot) {
          // If no data yet, show a loading indicator or a placeholder
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return ListView(
            children: [
              // User Profile Section
              ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(user.profileImageUrl),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: user.profileImageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  user.name.isEmpty ? 'User' : user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(user.about),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code, color: Colors.green),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: user),
                    ),
                  );
                },
              ),
              const Divider(),
              // Account Settings
              _buildSettingsItem(
                context,
                Iconsax.key,
                "Account",
                "Security notifications, change number",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsPage(),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.lock,
                "Privacy",
                "Block contacts, disappearing messages",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacySettingsPage(),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.user,
                "Avatar",
                "Create, edit, profile photo",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: user),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                Iconsax.message,
                "Chats",
                "Theme, wallpapers, chat history",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatsSettingsPage(),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.notification,
                "Notifications",
                "Message, group & call tones",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsSettingsPage(),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.data,
                "Storage and data",
                "Network usage, auto-download",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StorageSettingsPage(),
                  ),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.global,
                "App language",
                "English (device's language)",
              ),
              _buildSettingsItem(
                context,
                Iconsax.info_circle,
                "Help",
                "Help center, contact us, privacy policy",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                ),
              ),
              _buildSettingsItem(
                context,
                Iconsax.people,
                "Invite a friend",
                "",
              ),
              _buildSettingsItem(
                context,
                Iconsax.logout,
                "Logout",
                "",
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneLoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Footer
              const Center(
                child: Column(
                  children: [
                    Text("from", style: TextStyle(color: Colors.grey)),
                    Text(
                      "Meta",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: onTap ?? () {},
    );
  }
}
