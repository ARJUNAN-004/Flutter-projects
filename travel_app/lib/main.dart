///Main Appp-------------------------------------------------------------------------
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:travel_app/pages/add_page.dart';
// import 'package:travel_app/pages/comment.dart';
// import 'package:travel_app/pages/home.dart';
import 'package:travel_app/pages/login.dart';
import 'package:travel_app/splash_screen.dart';
// import 'package:travel_app/pages/signup.dart';
// import 'package:travel_app/pages/top_places.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: 
      //Home()
      //SignUp(),
      //AddPage()
      //Comment()
      AnimatedSplashScreenWidget()
    );
  }
}