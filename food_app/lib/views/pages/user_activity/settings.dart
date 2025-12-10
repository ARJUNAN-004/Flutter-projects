import 'package:flutter/material.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/views/pages/users/about.dart';
import 'package:food_app/views/pages/users/profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationOn = true;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,

      appBar: AppBar(
        backgroundColor:imageBackground1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -----------------------
            /// Account Section
            /// -----------------------
            const Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _settingsTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProfilePage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final offsetAnimation = Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),

            _settingsTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              color: Colors.orange,
              onTap: () {},
            ),

            const SizedBox(height: 30),

            /// -----------------------
            /// App Settings Section
            /// -----------------------
            const Text(
              "App Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _switchTile(
              icon: Icons.notifications_active_outlined,
              title: "Notifications",
              color: Colors.purple,
              value: isNotificationOn,
              onChanged: (v) => setState(() => isNotificationOn = v),
            ),

            _switchTile(
              icon: Icons.dark_mode_outlined,
              title: "Dark Mode",
              color: Colors.black,
              value: isDarkMode,
              onChanged: (v) => setState(() => isDarkMode = v),
            ),

            const SizedBox(height: 30),

            /// -----------------------
            /// About Section
            /// -----------------------
            const Text(
              "More",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _settingsTile(
              icon: Icons.info_outline,
              title: "About App",
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const AboutPage(),
                    transitionsBuilder: (_, animation, __, child) {
                      final offsetAnimation = Tween(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),

            _settingsTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              color: Colors.red,
              onTap: () {},
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// -----------------------------------
  /// Setting Tile (Normal navigation)
  /// -----------------------------------
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: imageBackground2,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  /// -----------------------------------
  /// Setting Tile with Switch Button
  /// -----------------------------------
  Widget _switchTile({
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor:imageBackground2,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ),
    );
  }
}
