// lib/models/employee.dart

class EmployeeUser {
  final String docId;       // Firestore document ID
  final String id;          // Employee ID (A123456)
  final String? password;   // Optional
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? birthDate;
  final String? profilePic; // URL if uploaded

  EmployeeUser({
    required this.docId,
    required this.id,
    this.password,
    this.firstName,
    this.lastName,
    this.address,
    this.birthDate,
    this.profilePic,
  });

  /// Map → EmployeeUser model
  factory EmployeeUser.fromMap(String docId, Map<String, dynamic> map) {
    return EmployeeUser(
      docId: docId,
      id: map['id'] ?? '',
      password: map['password'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      birthDate: map['birthDate'],
      profilePic: map['profilePic'],
    );
  }

  /// Model → Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthDate': birthDate,
      'profilePic': profilePic,
    };
  }
}
