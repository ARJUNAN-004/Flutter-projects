import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../utils/image_helper.dart';

// Screen to view and edit user profile
class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  bool _isEditingName = false;
  bool _isEditingAbout = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _aboutController.text = widget.user.about;
  }

  // Update profile photo
  Future<void> _updateProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      XFile? croppedFile = await ImageHelper.cropImage(image, context: context);
      if (croppedFile != null) {
        setState(() => _isLoading = true);
        try {
          final bytes = await croppedFile.readAsBytes();
          String imageUrl = await _userService.uploadProfileImage(
            bytes,
            "profile_${DateTime.now().millisecondsSinceEpoch}",
          );
          await _userService.updateUserProfile(widget.user.id, {
            'profileImageUrl': imageUrl,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile photo updated!")),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error updating photo: $e")));
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }

  // Save updated name
  Future<void> _saveName() async {
    if (_nameController.text.isNotEmpty) {
      await _userService.updateUserProfile(widget.user.id, {
        'name': _nameController.text,
      });
      if (mounted) {
        setState(() => _isEditingName = false);
      }
    }
  }

  // Save updated about status
  Future<void> _saveAbout() async {
    if (_aboutController.text.isNotEmpty) {
      await _userService.updateUserProfile(widget.user.id, {
        'about': _aboutController.text,
      });
      if (mounted) {
        setState(() => _isEditingAbout = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<UserModel>(
        stream: _userService.getCurrentUserStream(widget.user.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(user.profileImageUrl),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          radius: 25,
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: colorScheme.onPrimary,
                            ),
                            onPressed: _updateProfilePhoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildEditableTile(
                  icon: Icons.person,
                  label: "Name",
                  controller: _nameController,
                  isEditing: _isEditingName,
                  onEdit: () => setState(() => _isEditingName = true),
                  onSave: _saveName,
                  subtitle:
                      "This is not your username or pin. This name will be visible to your WhatsApp contacts.",
                ),
                const Divider(),
                _buildEditableTile(
                  icon: Icons.info_outline,
                  label: "About",
                  controller: _aboutController,
                  isEditing: _isEditingAbout,
                  onEdit: () => setState(() => _isEditingAbout = true),
                  onSave: _saveAbout,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.grey),
                  title: const Text("Phone"),
                  subtitle: Text(user.phoneNumber),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          if (isEditing)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: onSave,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  onPressed: onEdit,
                ),
              ],
            ),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
    );
  }
}
