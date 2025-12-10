import 'package:flutter/material.dart';
import 'package:food_app/views/core/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // SIGNUP
  Future<String?> signup(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,        // ✅ FIXED
        password: password,
      );

      if (response.user != null) {
        return null; // success
      }
      return "An unknown error occurred";
    } on AuthException catch (e) {
      return e.message; // supabase error
    } catch (e) {
      return "Error: $e";
    }
  }

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,        // ✅ FIXED
        password: password,
      );

      if (response.user != null) {
        return null; // success
      }
      return "An unknown error occurred";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error: $e";
    }
  }

  // LOGOUT
  Future<void> logout(BuildContext context) async {
    try {
      await supabase.auth.signOut();

      if (!context.mounted) return;     // ✅ FIXED
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      print("Logout Error: $e");
    }
  }
}