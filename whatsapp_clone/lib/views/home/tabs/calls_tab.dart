import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/call_model.dart';
import '../../../services/call_service.dart';

// Tab for displaying call history
class CallsTab extends StatelessWidget {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: Icon(Iconsax.link, color: Colors.white),
            ),
            title: Text(
              "Create call link",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Share a link for your WhatsApp call"),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Recent",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          StreamBuilder<List<CallModel>>(
            stream: CallService().getCallHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final calls = snapshot.data ?? [];
              if (calls.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text("No recent calls")),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  final call = calls[index];
                  final isMeCaller =
                      call.callerId == FirebaseAuth.instance.currentUser?.uid;

                  // Determine display info (show OTHER person's details)
                  final name = isMeCaller ? call.receiverName : call.callerName;
                  final pic = isMeCaller ? call.receiverPic : call.callerPic;

                  // Determine direction icon
                  IconData icon;
                  Color iconColor;

                  if (isMeCaller) {
                    icon = Iconsax.arrow_up;
                    iconColor = Colors.green;
                  } else {
                    // For now treating all incoming as "answered" or "incoming" since we don't hold state
                    // If we want "missed", we need 'status' field in CallModel
                    icon = Iconsax.arrow_down;
                    iconColor = Colors.red; // Or green if we assume answered
                  }

                  // Format time
                  final dt = call.timestamp.toDate();
                  final time =
                      "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: pic.isNotEmpty
                          ? NetworkImage(pic)
                          : null,
                      child: pic.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(icon, size: 16, color: iconColor),
                        const SizedBox(width: 5),
                        Text(time),
                      ],
                    ),
                    trailing: Icon(
                      call.type == CallType.audio
                          ? Iconsax.call
                          : Iconsax.video,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
