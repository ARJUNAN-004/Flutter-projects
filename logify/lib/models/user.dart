// lib/models/attendance.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String docId;

  final String checkIn;
  final String checkOut;

  final String checkInLocation;
  final String checkOutLocation;

  final double? checkInLat;
  final double? checkInLong;

  final double? checkOutLat;
  final double? checkOutLong;

  final Timestamp date;

  AttendanceRecord({
    required this.docId,
    required this.checkIn,
    required this.checkOut,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.checkInLat,
    required this.checkInLong,
    required this.checkOutLat,
    required this.checkOutLong,
    required this.date,
  });

  /// Map -> Model
  factory AttendanceRecord.fromMap(String docId, Map<String, dynamic> map) {
    return AttendanceRecord(
      docId: docId,
      checkIn: map['checkIn'] ?? "--/--",
      checkOut: map['checkOut'] ?? "--/--",
      checkInLocation: map['checkInLocation'] ?? "",
      checkOutLocation: map['checkOutLocation'] ?? "",
      
      checkInLat: (map['checkInLat'] as num?)?.toDouble(),
      checkInLong: (map['checkInLong'] as num?)?.toDouble(),
      checkOutLat: (map['checkOutLat'] as num?)?.toDouble(),
      checkOutLong: (map['checkOutLong'] as num?)?.toDouble(),

      date: map['date'] ?? Timestamp.now(),
    );
  }

  /// Model -> Map
  Map<String, dynamic> toMap() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,

      'checkInLat': checkInLat,
      'checkInLong': checkInLong,
      'checkOutLat': checkOutLat,
      'checkOutLong': checkOutLong,

      'date': date,
    };
  }
}
