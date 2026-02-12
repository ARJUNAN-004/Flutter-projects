import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

import 'package:cloudinary_public/cloudinary_public.dart';

// Service class for handling User operations (Firestore & Cloudinary)
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudinary instance
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'da7qor6kl',
    'whatsapp',
    cache: false,
  );

  // Get all users (excluding current user)
  Stream<List<UserModel>> getAllUsers(String currentUserId) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.id != currentUserId)
          .toList();
    });
  }

  // Get current user data stream
  Stream<UserModel> getCurrentUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()!));
  }

  // Get user by ID (Future)
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search users by name or phone
  // Search users by name or phone
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      // Fetch all users
      // Optimization: In a real app, use Algolia or ElasticSearch.
      // For this scale, fetching all users is acceptable.
      final snapshot = await _firestore.collection('users').get();

      final allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      final lowerQuery = query.toLowerCase();
      final currentUserId = _auth.currentUser?.uid;

      return allUsers.where((user) {
        if (user.id == currentUserId) return false; // Exclude current user
        final name = user.name.toLowerCase();
        final phone = user.phoneNumber;
        return name.contains(lowerQuery) || phone.contains(query);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Upload image to Cloudinary (Profile or Status)
  Future<String> uploadImage(
    List<int> bytes,
    String filename, {
    String folder = 'profile_images',
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          bytes,
          identifier: filename,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Deprecated alias for backward compatibility if needed, or just replace usages
  Future<String> uploadProfileImage(List<int> bytes, String filename) =>
      uploadImage(bytes, filename, folder: 'profile_images');

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  // Update user presence (Online/Offline)
  Future<void> updateUserPresence(bool isOnline) async {
    final user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> data = {'isOnline': isOnline};

    if (!isOnline) {
      data['lastSeen'] = FieldValue.serverTimestamp();
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      // Ignore presence errors to avoid spamming logs/UI
    }
  }

  // Update last active timestamp (Heartbeat)
  Future<void> updateLastActive() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastActive': FieldValue.serverTimestamp(),
        'isOnline': true, // Ensure online status if heartbeat is running
      });
    } catch (e) {
      // Ignore
    }
  }
}
