import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Needed for FileImage on Mobile if strict about types, but better to avoid if possible.
// Actually, FileImage needs File.
// For Cross platform, use kIsWeb check.

import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../utils/image_helper.dart';

class NewGroupPage extends StatefulWidget {
  const NewGroupPage({super.key});

  @override
  State<NewGroupPage> createState() => _NewGroupPageState();
}

class _NewGroupPageState extends State<NewGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  XFile? _image;
  final Map<String, UserModel> _selectedUsers = {};
  bool _isLoading = false;
  int _step = 1; // Step 1: Select Contacts, Step 2: Group Details

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      XFile? croppedFile = await ImageHelper.cropImage(
        pickedFile,
        context: context,
      );
      if (croppedFile != null) {
        if (mounted) {
          setState(() {
            _image = croppedFile;
          });
        }
      }
    }
  }

  void _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ChatService().createGroup(
        _groupNameController.text.trim(),
        _image,
        _selectedUsers.values.toList(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error creating group: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New Group"),
            if (_step == 1)
              const Text(
                "Add participants",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              )
            else
              const Text(
                "Add subject",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
      ),
      body: _step == 1 ? _buildSelectContactsStep() : _buildGroupDetailsStep(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_step == 1) {
            if (_selectedUsers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select at least one participant"),
                ),
              );
              return;
            }
            setState(() {
              _step = 2;
            });
          } else {
            _createGroup();
          }
        },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Icon(_step == 1 ? Icons.arrow_forward : Icons.check),
      ),
    );
  }

  Widget _buildSelectContactsStep() {
    final currentUserId = ChatService().currentUserId;
    if (currentUserId == null) {
      return const Center(child: Text("Error: No user logged in"));
    }

    return StreamBuilder<List<UserModel>>(
      stream: UserService().getAllUsers(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading contacts"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text("No contacts found"));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            UserModel user = users[index];
            bool isSelected = _selectedUsers.containsKey(user.id);

            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.profileImageUrl),
                  ),
                  if (isSelected)
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              title: Text(user.name),
              subtitle: Text(user.about),
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedUsers.remove(user.id);
                  } else {
                    _selectedUsers[user.id] = user;
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupDetailsStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _image != null
                  ? (kIsWeb
                        ? NetworkImage(_image!.path)
                        : FileImage(File(_image!.path)) as ImageProvider)
                  : null,
              child: _image == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              hintText: "Type group subject here...",
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Provide a group subject and optional group icon",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
