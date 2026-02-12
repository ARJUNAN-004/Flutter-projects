import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/services/database.dart';
import 'package:travel_app/services/shared_pref.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Google Sign-In
  signInWithGoogle(BuildContext context) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // aborted

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await auth.signInWithCredential(credential);
    final user = userCred.user;

    if (user != null) {
      await SharedPreferenceHelper().saveUserName(user.displayName ?? "");
      await SharedPreferenceHelper().saveUserProfileUrl(user.photoURL ?? "");

      Map<String, dynamic> userInfo = {
        "id": user.uid,
        "name": user.displayName,
        "email": user.email,
        "imgUrl": user.photoURL,
      };

      await DatabaseMethods().addUser(user.uid, userInfo);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  }
}
