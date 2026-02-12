// lib/services/database_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logify/models/task.dart';
import 'package:logify/models/employee.dart';
import 'package:logify/models/user.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService();

  // ------------------------------------------------------
  // EMPLOYEE
  // ------------------------------------------------------

  Future<EmployeeUser?> getEmployee(String docId) async {
    final doc = await _db.collection('Employee').doc(docId).get();
    if (!doc.exists) return null;
    return EmployeeUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> updateProfile(String docId, Map<String, dynamic> data) async {
    await _db.collection('Employee').doc(docId).update(data);
  }

  Future<void> updateProfilePic(String docId, String url) async {
    await _db.collection('Employee').doc(docId).update({'profilePic': url});
  }

  // ------------------------------------------------------
  // TASKS (Employee/{docId}/Tasks)
  // ------------------------------------------------------

  CollectionReference _tasksRef(String employeeDocId) =>
      _db.collection('Employee').doc(employeeDocId).collection('Tasks');

  Future<DocumentReference> addTask(
    String employeeDocId,
    String title,
    String description,
  ) async {
    return _tasksRef(employeeDocId).add({
      'title': title,
      'description': description,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask(
    String employeeDocId,
    String taskId,
    String title,
    String description,
  ) async {
    await _tasksRef(employeeDocId).doc(taskId).update({
      'title': title,
      'description': description,
    });
  }

  Future<void> toggleTaskComplete(
    String employeeDocId,
    String taskId,
    bool isCompleted,
  ) async {
    await _tasksRef(employeeDocId).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  Future<void> deleteTask(String employeeDocId, String taskId) async {
    await _tasksRef(employeeDocId).doc(taskId).delete();
  }

  Stream<List<Task>> streamTasks(
    String employeeDocId, {
    required bool completed,
  }) {
    return _tasksRef(employeeDocId)
        .where('isCompleted', isEqualTo: completed)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // ------------------------------------------------------
  // ATTENDANCE (Employee/{docId}/Record/{dd MMM yyyy})
  // ------------------------------------------------------

  CollectionReference _recordRef(String employeeDocId) =>
      _db.collection('Employee').doc(employeeDocId).collection('Record');

  Future<AttendanceRecord?> getAttendanceForDate(
    String employeeDocId,
    String dateDocId,
  ) async {
    final doc = await _recordRef(employeeDocId).doc(dateDocId).get();
    if (!doc.exists) return null;
    return AttendanceRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> checkIn(
    String employeeDocId,
    String inTime,
    String location,
  ) async {
    final dateDocId = _dateDocIdNow();
    await _recordRef(employeeDocId).doc(dateDocId).set({
      'checkIn': inTime,
      'checkOut': "--/--",
      'checkInLocation': location,
      'checkOutLocation': "",
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> checkOut(
    String employeeDocId,
    String outTime,
    String location,
  ) async {
    final dateDocId = _dateDocIdNow();

    await _recordRef(employeeDocId).doc(dateDocId).set({
      'checkOut': outTime,
      'checkOutLocation': location,
      'date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAttendance(
    String employeeDocId,
    String dateDocId,
    Map<String, dynamic> data,
  ) async {
    await _recordRef(employeeDocId).doc(dateDocId).update(data);
  }

  Stream<List<AttendanceRecord>> streamRecords(String employeeDocId) {
    return _recordRef(employeeDocId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) =>
              AttendanceRecord.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // ------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------

  String _dateDocIdNow() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')} "
        "${_monthShort(now.month)} "
        "${now.year}";
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
