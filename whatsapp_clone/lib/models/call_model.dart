import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallDirection { incoming, outgoing, missed }

// Call Model representing a call history item
class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String callerPic;
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final String callId;
  final CallType type;
  final Timestamp timestamp;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerPic,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPic,
    required this.callId,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPic': receiverPic,
      'callId': callId,
      'type': type.index, // Store enum as int
      'timestamp': timestamp,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? 'Unknown',
      callerPic: map['callerPic'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? 'Unknown',
      receiverPic: map['receiverPic'] ?? '',
      callId: map['callId'] ?? '',
      type: CallType.values[map['type'] ?? 0],
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }
}
