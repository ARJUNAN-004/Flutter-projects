import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImageUrl;
  final String about;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime? lastActive;
  final bool requiresProfileSetup;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.about,
    required this.isOnline,
    this.lastSeen,
    this.lastActive,
    required this.requiresProfileSetup,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl:
          map['profileImageUrl'] ??
          map['image'] ??
          '', // Fallback to 'image' for older data as well
      about:
          map['about'] ??
          map['status'] ??
          '', // Fallback to 'status' for older data as well
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
      requiresProfileSetup: map['requiresProfileSetup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'about': about,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'requiresProfileSetup': requiresProfileSetup,
    };
  }
}
