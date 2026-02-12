import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Iconsax.shield_tick),
            title: Text('Security notifications'),
          ),
          ListTile(
            leading: Icon(Iconsax.password_check),
            title: Text('Two-step verification'),
          ),
          ListTile(leading: Icon(Iconsax.mobile), title: Text('Change number')),
          ListTile(
            leading: Icon(Iconsax.document_text),
            title: Text('Request account info'),
          ),
          ListTile(
            leading: Icon(Iconsax.trash, color: Colors.red),
            title: Text('Delete account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
