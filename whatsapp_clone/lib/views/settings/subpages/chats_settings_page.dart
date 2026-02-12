import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/theme_provider.dart';

class ChatsSettingsPage extends ConsumerWidget {
  const ChatsSettingsPage({super.key});

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme = ref.watch(themeProvider);
        return AlertDialog(
          title: const Text("Choose Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text("System Default"),
                value: ThemeMode.system,
                groupValue: currentTheme,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Light"),
                value: ThemeMode.light,
                groupValue: currentTheme,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Dark"),
                value: ThemeMode.dark,
                groupValue: currentTheme,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Display', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () => _showThemeDialog(context, ref),
          ),
          const ListTile(
            leading: Icon(Icons.wallpaper),
            title: Text('Wallpaper'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Chat settings', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: const Text('Enter is send'),
            subtitle: const Text('Enter key will send your message'),
            trailing: Switch(value: false, onChanged: (val) {}),
          ),
          ListTile(
            title: const Text('Media visibility'),
            subtitle: const Text(
              'Show newly downloaded media in your device\'s gallery',
            ),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const ListTile(title: Text('Font size'), subtitle: Text('Medium')),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.backup),
            title: Text('Chat backup'),
          ),
          const ListTile(
            leading: Icon(Icons.history),
            title: Text('Chat history'),
          ),
        ],
      ),
    );
  }
}
