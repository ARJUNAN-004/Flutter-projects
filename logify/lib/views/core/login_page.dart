import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logify/views/core/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // ======================================================
  // FIXED LOGIN (METHOD 2 – GET AUTO DOCUMENT ID)
  // ======================================================
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    String empId = _empIdController.text.trim();
    String password = _passwordController.text.trim();

    try {
      /// 🔥 Step 1: Find employee by ID (not docId)
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('Employee')
          .where('id', isEqualTo: empId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _showError("Employee ID not found");
        return;
      }

      /// 🔥 Step 2: Extract actual Firestore document ID
      var doc = snap.docs.first;
      String docId = doc.id;
      var userData = doc.data() as Map<String, dynamic>;

      /// 🔥 Step 3: Check password
      if (password != userData["password"]) {
        _showError("Incorrect password");
        return;
      }

      // 🔥 Step 4: Save REAL document id + employee id
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("employee_doc_id", docId);
      await prefs.setString("employee_id", empId);

      _showSuccess("Login Successful");

      // 🔥 Step 5: Navigate with Fade animation
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomePage(employeeDocId: docId),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      _showError("Login failed. Please check your connection.");
    }
  }

  // ======================================================

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  /// LOGO + TITLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icon/logo.png', height: 35),
                      const SizedBox(width: 6),
                      const Text(
                        "Logify",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Login to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),

                  const SizedBox(height: 50),

                  /// EMPLOYEE ID FIELD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Employee ID", style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _empIdController,
                    decoration: _inputDeco("Enter employee ID", Icons.badge),
                    validator: (v) =>
                        v!.isEmpty ? "Employee ID cannot be empty" : null,
                  ),

                  const SizedBox(height: 20),

                  /// PASSWORD FIELD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Password", style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "********",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "Password cannot be empty" : null,
                  ),

                  const SizedBox(height: 30),

                  /// LOGIN BUTTON (Your exact style)
                  GestureDetector(
                    onTap: _handleLogin,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EB657),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _empIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
