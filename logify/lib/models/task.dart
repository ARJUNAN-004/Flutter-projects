// lib/models/task.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;             // Firestore document ID
  final String title;
  final String description;
  final bool completed;
  final Timestamp createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
  });

  /// Convert Firestore Map → Task model
  factory Task.fromMap(String docId, Map<String, dynamic> map) {
    return Task(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      completed: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  /// Convert Task → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': completed,
      'createdAt': createdAt,
    };
  }
}
