import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:whatsapp_clone_ui/utils/colors.dart';
import 'tabs/chat_tab.dart';
import '../../services/chat_service.dart';

import 'tabs/status_tab.dart';
import 'tabs/calls_tab.dart';
import '../settings/settings_page.dart';

import '../contacts/select_contact_page.dart';
import '../group/new_group_page.dart';
import 'package:image_picker/image_picker.dart';
import '../status/confirm_status_page.dart';

// Main Home Screen with Tabs (Chats, Status, Calls)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _chatsSubscription;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _markDelivered();
    _setupDeliveryStatusListener();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

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

  void _markDelivered() async {
    await ChatService().markAllIncomingMessagesAsDelivered();
  }

  void _setupDeliveryStatusListener() {
    final chatService = ChatService();
    final currentUserId = chatService.currentUserId;

    if (currentUserId == null) return;

    _chatsSubscription = chatService.getUserChats().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);

        // Find the other user's ID
        final otherUserId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );

        if (otherUserId.isNotEmpty) {
          // Mark messages from this user as delivered
          chatService.markMessagesAsDelivered(otherUserId);
        }
      }
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                autofocus: true,
              )
            : const Text(
                'Chathub',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                });
              },
              icon: const Icon(Icons.close),
            )
          else ...[
            IconButton(onPressed: () {}, icon: const Icon(Iconsax.camera)),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: const Icon(Iconsax.search_normal),
            ),
            PopupMenuButton(
              onSelected: (value) {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewGroupPage(),
                    ),
                  );
                } else if (value == 5) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 1, child: Text('New group')),
                const PopupMenuItem(value: 2, child: Text('New broadcast')),
                const PopupMenuItem(value: 3, child: Text('Linked devices')),
                const PopupMenuItem(value: 4, child: Text('Starred messages')),
                const PopupMenuItem(value: 5, child: Text('Settings')),
              ],
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.accent : AppColors.primaryLight,
          indicatorWeight: 3,
          labelColor: isDark ? AppColors.accent : AppColors.primaryLight,
          unselectedLabelColor: isDark
              ? Colors.grey
              : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatTab(searchQuery: _searchQuery),
          const StatusTab(),
          const CallsTab(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // Build Floating Action Button based on current tab
  Widget _buildFAB() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          heroTag: "fab_chats",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectContactPage(),
              ),
            );
          },
          child: const Icon(Iconsax.message_text),
        );
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              heroTag: "fab_status_edit",
              onPressed: () {},
              backgroundColor: Colors.grey[200],
              child: const Icon(Iconsax.edit, color: Colors.black),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "fab_status_camera",
              onPressed: () {
                _pickStatusImage(context);
              },
              child: const Icon(Iconsax.camera),
            ),
          ],
        );
      case 2:
        return FloatingActionButton(
          heroTag: "fab_calls",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectContactPage(),
              ),
            );
          },
          child: const Icon(Iconsax.call_add),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
