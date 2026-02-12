import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/services/database.dart';
import 'package:travel_app/services/shared_pref.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String? name, profilePic;

  // Get user info from shared preferences
  getUserDetails() async {
    name = await SharedPreferenceHelper().getUserDisplayName();
    profilePic = await SharedPreferenceHelper().getUserProfileUrl();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  /// Show modal to pick image source
 Future<void> pickImageDialog() async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full height if needed
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 10,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fit content naturally
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.green),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

  final TextEditingController placenamecontroller = TextEditingController();
  final TextEditingController citynamecontroller = TextEditingController();
  final TextEditingController captionnamecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 20.0,
                top: 40.0,
              ),
              child: Row(
                children: [
                  Material(
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Home()),
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blue,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 4.5),
                  const Text(
                    'Add Post',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'Poppins',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              elevation: 3.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image upload section
                    selectedImage != null
                        ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: pickImageDialog,
                            child: Center(
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2.0,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 20.0),
                    buildTextInput("Place Name", placenamecontroller),
                    buildTextInput("City Name", citynamecontroller),
                    buildTextArea("Caption", captionnamecontroller),
                    const SizedBox(height: 30.0),

                    // Submit button
                    GestureDetector(
                      onTap: () async {
                        if (selectedImage != null &&
                            placenamecontroller.text.isNotEmpty &&
                            citynamecontroller.text.isNotEmpty &&
                            captionnamecontroller.text.isNotEmpty) {
                          final cloudinary = CloudinaryPublic(
                            'da7qor6kl', // Your Cloudinary cloud name
                            'unsigned', // Your Upload Preset
                            cache: false,
                          );

                          try {
                            CloudinaryResponse response =
                                await cloudinary.uploadFile(
                              CloudinaryFile.fromFile(
                                selectedImage!.path,
                                resourceType: CloudinaryResourceType.Image,
                              ),
                            );

                            final postInfo = {
                              "placeName": placenamecontroller.text,
                              "cityName": citynamecontroller.text,
                              "caption": captionnamecontroller.text,
                              "imageUrl": response.secureUrl,
                              "postedBy": name ?? "Unknown user",
                              "profilePic": profilePic ?? "",
                              "timestamp": FieldValue.serverTimestamp(),
                            };

                            await DatabaseMethods().addPost(postInfo);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  'Post uploaded successfully!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Failed to upload post. Try again.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'All fields are required and an image must be selected!',
                              ),
                            ),
                          );
                        }
                      },
                      child: Center(
                        child: Container(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build text input fields
  Widget buildTextInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $label",
            ),
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }

  // Build text area for caption
  Widget buildTextArea(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'Poppins',
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter $label...",
            ),
          ),
        ),
      ],
    );
  }
}
