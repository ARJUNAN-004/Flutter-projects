import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new status
  Future<void> addStatus(String imageUrl, String caption) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final statusData = {
        'uid': user.uid,
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
        'viewers': [],
      };

      // Save to 'status' collection
      // Structure: status -> {statusId}
      await _firestore.collection('status').add(statusData);

      // Note: In a real scalable app, we might fan-out this status ID to friends' feeds
      // or use a query to fetch friends' statuses.
    } catch (e) {
      rethrow;
    }
  }

  // Get status updates from contacts (filtered by last 24h)
  // This is a simplified version. Real version needs to filter by contacts.
  Stream<QuerySnapshot> getRecentStatusUpdates() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));

    // Simplification: Get ALL statuses from last 24h (demo mode)
    // Real app: .where('uid', whereIn: contactIds)
    return _firestore
        .collection('status')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get current user's active status (if any)
  Stream<QuerySnapshot> getMyStatus() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('status')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  // Delete a status
  Future<void> deleteStatus(String statusId) async {
    try {
      await _firestore.collection('status').doc(statusId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
