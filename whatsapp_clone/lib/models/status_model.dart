import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String id;
  final String uid;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  final DateTime expiresAt;
  final List<String> viewers;

  StatusModel({
    required this.id,
    required this.uid,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    required this.expiresAt,
    required this.viewers,
  });

  factory StatusModel.fromMap(Map<String, dynamic> map, String id) {
    return StatusModel(
      id: id,
      uid: map['uid'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt:
          (map['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 24)),
      viewers: List<String>.from(map['viewers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'imageUrl': imageUrl,
      'caption': caption,
      'timestamp': Timestamp.fromDate(timestamp),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewers': viewers,
    };
  }
}
