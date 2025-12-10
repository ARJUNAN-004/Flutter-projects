import 'package:flutter/material.dart';
import 'package:food_app/views/core/login_page.dart';
import 'package:food_app/views/pages/food/main_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthCheck extends StatelessWidget {
  final supabase = Supabase.instance.client;
  AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return MainPage();
        }else{
          return LoginPage();
        }
      },
    );
  }
}
