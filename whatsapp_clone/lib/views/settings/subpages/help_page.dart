import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Iconsax.info_circle),
            title: Text('Help Center'),
          ),
          ListTile(
            leading: Icon(Iconsax.message_question),
            title: Text('Contact us'),
            subtitle: Text('Questions? Need help?'),
          ),
          ListTile(
            leading: Icon(Iconsax.document),
            title: Text('Terms and Privacy Policy'),
          ),
          ListTile(leading: Icon(Iconsax.info_circle), title: Text('App info')),
        ],
      ),
    );
  }
}
