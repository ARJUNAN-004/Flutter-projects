import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logify/views/core/home_page.dart';
import 'package:logify/views/core/login_page.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  /// Load saved employee doc ID from SharedPreferences
  Future<String?> _getStoredDocId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_doc_id');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getStoredDocId(),
      builder: (context, snapshot) {
        // Still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state (optional UI)
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong.")),
          );
        }

        final docId = snapshot.data;

        // If no stored doc ID → go to Login
        if (docId == null) {
          return const LoginPage();
        }

        // Already logged in → go to Home
        return HomePage(employeeDocId: docId);
      },
    );
  }
}
