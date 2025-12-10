import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/services/cloud_service.dart';
import 'package:food_app/utils/consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_app/services/profile_service.dart';
import 'package:food_app/Provider/cart_provider.dart';
import 'package:food_app/Provider/favorite_provider.dart';
import 'package:food_app/services/auth_service.dart';
import 'package:food_app/views/pages/users/about.dart';
import 'package:food_app/views/pages/user_activity/cart_page.dart';
import 'package:food_app/views/pages/user_activity/favorite_page.dart';
import 'package:food_app/views/pages/user_activity/settings.dart';

final AuthService authService = AuthService();

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final picker = ImagePicker();
  final profileService = ProfileService();

  String? name;
  String? email;
  String? avatarUrl;

  bool loading = true;

 @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) loadUserData();
  });
}


  Future<void> loadUserData() async {
  final data = await profileService.getUserProfile();

  if (!mounted) return;   // FIX

  setState(() {
    name = data?['name'] ?? "User";
    email = data?['email'] ?? "No Email";
    avatarUrl = data?['avatar_url'];
    loading = false;
  });
}


  Future<void> pickImage() async {
  final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return;

  final file = File(picked.path);

  final uploadedUrl = await CloudinaryService.uploadImage(file);
  if (uploadedUrl == null) return;

  await profileService.updateAvatar(uploadedUrl);

  if (!mounted) return;   // FIX

  setState(() => avatarUrl = uploadedUrl);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,

      appBar: AppBar(
        backgroundColor: imageBackground1,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// Profile Avatar + Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.orange.shade100,
                              backgroundImage:
                                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person, size: 70, color: Colors.orange)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            name ?? "User",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            email ?? "",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// Navigation options
                    _option(Icons.favorite, "Your Favorites", Colors.pinkAccent,
                        () => _push(context, const FavoriteScreen())),
                    _option(Icons.shopping_cart, "Your Cart", Colors.green,
                        () => _push(context, const CartPage())),
                    _option(Icons.settings, "Settings", Colors.blue,
                        () => _push(context, const SettingsPage())),
                    _option(Icons.info_outline, "About App", Colors.orange,
                        () => _push(context, const AboutPage())),

                    const SizedBox(height: 10),

                    /// Logout Button
                    ElevatedButton(
                      onPressed: () async {
                        await authService.logout(context);
                        ref.invalidate(favoriteProvider);
                        ref.invalidate(cartProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 80),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Logout",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _option(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: imageBackground2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 18),
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final slide =
              Tween(begin: const Offset(1, 0), end: Offset.zero).animate(animation);
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }
}
