import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Service class for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user 
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<UserModel> get currentUserStream {
    if (currentUser == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data()!));
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if it's a new user
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      await saveUserToFirestore(userCredential.user!, isNewUser: isNewUser);
      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserToFirestore(User user, {bool isNewUser = false}) async {
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'lastSeen': DateTime.now(),
    };

    if (isNewUser) {
      userData['requiresProfileSetup'] = true;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));
  }
}
