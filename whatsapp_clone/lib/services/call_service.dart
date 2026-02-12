import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/call_model.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new call entry in history
  Future<void> createCall(CallModel call) async {
    try {
      await _firestore.collection('calls').doc(call.id).set(call.toMap());
    } catch (e) {
      print("Error creating call log: $e");
    }
  }

  // End call (optional: update status/duration if we added those fields)
  Future<void> endCall(String callDocId) async {
    // For now, just a placeholder or ensuring it exists
    // Could update 'endedAt' timestamp if we had one
  }

  // Get call history for current user
  Stream<List<CallModel>> getCallHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('calls')
        .where(
          Filter.or(
            Filter('callerId', isEqualTo: user.uid),
            Filter('receiverId', isEqualTo: user.uid),
          ),
        )
        .snapshots()
        .map((snapshot) {
          final calls = snapshot.docs
              .map((doc) => CallModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort client-side to avoid complex composite index requirement
          calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return calls;
        });
  }
}
