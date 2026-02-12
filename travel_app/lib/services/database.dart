import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUser(String userId, Map<String, dynamic> userInfoMap) async {
    return FirebaseFirestore.instance.collection("users").doc(userId).set(userInfoMap);
  }

  Future addPost(Map<String, dynamic> postInfo) async {
    return FirebaseFirestore.instance.collection("posts").add(postInfo);
  }

  Stream<QuerySnapshot> getPosts() {
    return FirebaseFirestore.instance.collection("posts").orderBy('timestamp', descending: true).snapshots();
  }
}