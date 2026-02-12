import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Who can see my personal info',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ListTile(
            title: Text('Last seen and online'),
            subtitle: Text('Everyone'),
          ),
          ListTile(title: Text('Profile photo'), subtitle: Text('Everyone')),
          ListTile(title: Text('About'), subtitle: Text('Everyone')),
          ListTile(title: Text('Status'), subtitle: Text('My contacts')),
          Divider(),
          ListTile(
            title: Text('Read receipts'),
            subtitle: Text(
              'If turned off, you won\'t send or receive Read receipts. Read receipts are always sent for group chats.',
            ),
            trailing: Switch(
              value: true,
              onChanged: null,
            ), // Toggle functionality to be added
          ),
          Divider(),
          ListTile(title: Text('Groups'), subtitle: Text('Everyone')),
          ListTile(title: Text('Live location'), subtitle: Text('None')),
          ListTile(title: Text('Blocked contacts'), subtitle: Text('None')),
          ListTile(title: Text('Fingerprint lock'), subtitle: Text('Disabled')),
        ],
      ),
    );
  }
}
