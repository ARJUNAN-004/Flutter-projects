import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/pages/forgot_password.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/pages/signup.dart';
import 'package:travel_app/services/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userlogin() async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Login Successful", style: TextStyle(fontSize: 20.0,
            color: Colors.white
            )),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } on FirebaseAuthException catch (e) {
        String message = e.code == 'user-not-found'
            ? "No user found for that email."
            : "Incorrect password";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(message, style: const TextStyle(fontSize: 18.0)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(180),
                ),
                child: Image.asset(
                  'assets/images/login.png',
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 40.0),
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              label("Email"),
              inputField(
                controller: mailcontroller,
                hintText: "Email",
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter Email' : null,
              ),
              const SizedBox(height: 20),

              // Password Field
              label("Password"),
              inputField(
                controller: passwordcontroller,
                hintText: "Password",
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter Password' : null,
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPassword()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(right: 30.0, top: 10.0),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              // Sign in Button
              GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    email = mailcontroller.text.trim();
                    password = passwordcontroller.text.trim();
                    userlogin();
                  }
                },
                child: authButton("Sign in", Colors.orange[400]!),
              ),

              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Login with Google Button
              GestureDetector(
                onTap: () {
                  AuthMethods().signInWithGoogle(context);
                },
                child: authButton(
                  "Login with Google",
                  Colors.grey[800]!,
                  iconPath: 'assets/images/search.png',
                ),
              ),

              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                  );
                },
                child: Center(
                  child: Text(
                    'Signup',
                    style:
                        TextStyle(color: Colors.orange[400], fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Label
  Padding label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(195, 255, 255, 255),
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Reusable Input Field
  Container inputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white60),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  // Reusable Auth Button
  Container authButton(String text, Color color, {String? iconPath}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color,
        border: iconPath != null ? Border.all(color: Colors.grey) : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.asset(iconPath, height: 25, width: 25, fit: BoxFit.cover),
              ),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: iconPath != null ? Colors.white : Colors.black,
                  fontSize: 20.0,
                  fontWeight:
                      iconPath != null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
