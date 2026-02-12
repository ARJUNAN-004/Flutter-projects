import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/pages/login.dart';
import 'package:travel_app/services/auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = "", password = "", name = "";
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController mailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0,
            color: Colors.white
            ),
            
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "Password provided is too weak";
      } else if (e.code == "email-already-in-use") {
        message = "Account already exists";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(message, style: const TextStyle(fontSize: 18.0)),
        ),
      );
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
                  'assets/images/signup.png',
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Signup',
                  style: TextStyle(color: Colors.white, fontSize: 36.0),
                ),
              ),
              const SizedBox(height: 15),

              // Name Field
              formLabel("Name"),
              customTextField(
                controller: namecontroller,
                hintText: "Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Email Field
              formLabel("Email"),
              customTextField(
                controller: mailcontroller,
                hintText: "Email",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  String pattern = r'\w+@\w+\.\w+';
                  if (!RegExp(pattern).hasMatch(value)) {
                    return 'Invalid Email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password Field
              formLabel("Password"),
              customTextField(
                controller: passwordcontroller,
                hintText: "Password",
                obscureText: true,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your password'
                    : null,
              ),
              const SizedBox(height: 20),

              // Sign Up Button
              GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    email = mailcontroller.text.trim();
                    name = namecontroller.text.trim();
                    password = passwordcontroller.text.trim();
                    registration();
                  }
                },
                child: authButton("Sign up", Colors.orange[400]!),
              ),

              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'or',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Google Sign-In Button
              GestureDetector(
                onTap: () {
                  AuthMethods().signInWithGoogle(context);
                },
                child: authButton(
                  "Sign up with Google",
                  Colors.grey[800]!,
                  iconPath: 'assets/images/search.png',
                ),
              ),

              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.orange[400], fontSize: 16.0),
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

  // Helper Widget for Labels
  Padding formLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(195, 255, 255, 255),
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper Widget for Text Fields
  Container customTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
      height: 48,
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
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: iconPath != null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
