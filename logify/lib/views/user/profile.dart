// lib/views/user/profile.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:logify/services/database_service.dart';

class ProfilePage extends StatefulWidget {
  final String employeeDocId;
  const ProfilePage({super.key, required this.employeeDocId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double screenWidth = 0;
  String birth = "Date of Birth";
  String? profilePic;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  Color primary = const Color(0xff0eb657);
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection("Employee").doc(widget.employeeDocId).get();
    if (doc.exists) {
      setState(() {
        profilePic = doc['profilePic'];
        firstNameController.text = doc['firstName'] ?? "";
        lastNameController.text = doc['lastName'] ?? "";
        addressController.text = doc['address'] ?? "";
        birth = doc['birthDate'] ?? "Date of Birth";
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> pickUploadProfilePic() async {
    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xff0eb657))));
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 512, maxWidth: 512, imageQuality: 85);
      if (image == null) {
        Navigator.pop(context);
        _showSnack("No image selected.");
        return;
      }

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/da7qor6kl/image/upload");
      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = "attendence"
        ..files.add(await http.MultipartFile.fromPath("file", image.path));
      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);
      if (data["secure_url"] == null) throw "Upload failed";
      final uploadedUrl = data["secure_url"];
      setState(() => profilePic = uploadedUrl);
      await _db.updateProfilePic(widget.employeeDocId, uploadedUrl);
      Navigator.pop(context);
      _showSnack("Profile picture updated!", success: true);
    } catch (e) {
      Navigator.pop(context);
      _showSnack("Error: $e");
    }
  }

  Future<void> saveProfile() async {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    final addr = addressController.text.trim();
    if (first.isEmpty) return _showSnack("Enter First Name!");
    if (last.isEmpty) return _showSnack("Enter Last Name!");
    if (birth == "Date of Birth") return _showSnack("Select Date of Birth!");
    if (addr.isEmpty) return _showSnack("Enter Address!");
    await _db.updateProfile(widget.employeeDocId, {"firstName": first, "lastName": last, "birthDate": birth, "address": addr});
    _showSnack("Profile updated!", success: true);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 40),
          GestureDetector(
            onTap: pickUploadProfilePic,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
              child: profilePic == null || profilePic == "" ? const Icon(Icons.person, size: 80, color: Colors.white) : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(profilePic!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 20),
          Text("Profile", style: TextStyle(fontFamily: 'Poppins', fontSize: screenWidth / 20)),
          const SizedBox(height: 30),
          textField("First Name", "Enter First Name", firstNameController),
          textField("Last Name", "Enter Last Name", lastNameController),
          Align(alignment: Alignment.centerLeft, child: Text("Date of Birth", style: TextStyle(fontFamily: "Poppins", fontSize: screenWidth / 28, color: Colors.black87))),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1950), lastDate: DateTime.now());
              if (picked != null) setState(() => birth = DateFormat("MM/dd/yyyy").format(picked));
            },
            child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.only(left: 12), height: 55, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.black54)), alignment: Alignment.centerLeft, child: Text(birth, style: TextStyle(color: birth == "Date of Birth" ? Colors.black26 : Colors.black87, fontFamily: 'Poppins', fontSize: screenWidth / 28)))),
          textField("Address", "Enter Address", addressController),
          GestureDetector(onTap: saveProfile, child: Container(margin: const EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20), height: 55, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(30)), alignment: Alignment.center, child: Text("SAVE", style: TextStyle(color: Colors.white, fontFamily: "Poppins", fontSize: screenWidth / 26)))),

        ]),
      ),
    );
  }

  Widget textField(String title, String hint, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontFamily: "Poppins", fontSize: screenWidth / 28, color: Colors.black87)),
      const SizedBox(height: 6),
      TextFormField(controller: controller, cursorColor: Colors.black54, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.black26, fontFamily: "Poppins", fontSize: screenWidth / 28), enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)), focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)))),
      const SizedBox(height: 12)
    ]);
  }

  void _showSnack(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)), backgroundColor: success ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating, elevation: 8, margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.all(16)));
  }
}
