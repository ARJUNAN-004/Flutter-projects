import 'package:flutter/material.dart';

class StorageSettingsPage extends StatelessWidget {
  const StorageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storage and data')),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Manage storage'),
            subtitle: Text('2.3 GB'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('Network usage'),
            subtitle: Text('6.1 GB sent • 8.4 GB received'),
          ),
          const ListTile(
            title: Text('Use less data for calls'),
            trailing: Switch(value: false, onChanged: null),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Media auto-download',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const ListTile(
            title: Text('When using mobile data'),
            subtitle: Text('Photos'),
          ),
          const ListTile(
            title: Text('When connected on Wi-Fi'),
            subtitle: Text('All media'),
          ),
          const ListTile(
            title: Text('When roaming'),
            subtitle: Text('No media'),
          ),
        ],
      ),
    );
  }
}
