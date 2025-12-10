import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_app/views/core/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://adddxvtndaxdllfncaym.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkZGR4dnRuZGF4ZGxsZm5jYXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3OTQ3NTcsImV4cCI6MjA3OTM3MDc1N30.UUol3lWBxmn_gmWaZr3Czo10RXa3C6WIwqLH3Mmf2SI",
  );
  await Future.delayed(Duration(seconds: 1));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Food App",
        home: 
        const 
        SplashScreen()
        //SearchPage()
        ,
      ),
    );
  }
}
