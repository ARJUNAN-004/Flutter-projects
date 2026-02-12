import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Messages', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            title: Text('Notification tone'),
            subtitle: Text('Default (Spaceline)'),
          ),
          const ListTile(title: Text('Vibrate'), subtitle: Text('Default')),
          ListTile(
            title: const Text('Reaction Notifications'),
            subtitle: const Text(
              'Show notifications for reactions to messages you send',
            ),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Groups', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            title: Text('Notification tone'),
            subtitle: Text('Default (Spaceline)'),
          ),
          const ListTile(title: Text('Vibrate'), subtitle: Text('Default')),
          ListTile(
            title: const Text('Reaction Notifications'),
            subtitle: const Text(
              'Show notifications for reactions to messages you send',
            ),
            trailing: Switch(value: true, onChanged: (val) {}),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Calls', style: TextStyle(color: Colors.grey)),
          ),
          const ListTile(
            title: Text('Ringtone'),
            subtitle: Text('Default (Spaceline)'),
          ),
          const ListTile(title: Text('Vibrate'), subtitle: Text('Default')),
        ],
      ),
    );
  }
}
