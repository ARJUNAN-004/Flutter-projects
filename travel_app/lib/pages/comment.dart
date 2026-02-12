import 'package:flutter/material.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/services/shared_pref.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentState();
}

class _CommentState extends State<CommentPage> {
  // List to store comments locally
  List<Map<String, String>> comments = [
    {
      'userName': 'User',
      'comment': "We will surely visit the place, it's awesome",
      'avatar': 'assets/images/boy.jpg'
    }
  ];

  final TextEditingController _commentController = TextEditingController();

  String? userProfileUrl;
  String? userName;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  // Fetch user details from shared preferences
  Future<void> getUserDetails() async {
    userProfileUrl = await SharedPreferenceHelper().getUserProfileUrl();
    userName = await SharedPreferenceHelper().getUserDisplayName();
    setState(() {}); // Refresh UI after loading the data
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
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
                SizedBox(width: screenWidth / 7),
                const Text(
                  'Add Comment',
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
          const SizedBox(height: 30.0),
          Expanded(
            child: Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              elevation: 3.0,
              child: Container(
                width: screenWidth,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Material(
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: comment['avatar']!.startsWith('http')
                                        ? Image.network(
                                            comment['avatar']!,
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            comment['avatar']!,
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                    const SizedBox(width: 15.0),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['userName']!,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Poppins',
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: screenWidth / 1.5,
                                          child: Text(
                                            comment['comment']!,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              setState(() {
                                comments.add({
                                  'userName': userName ?? 'You',
                                  'comment': _commentController.text,
                                  'avatar': userProfileUrl != null && userProfileUrl!.isNotEmpty
                                    ? userProfileUrl!
                                    : 'assets/images/boy.jpg',
                                });
                                _commentController.clear();
                              });
                            }
                          },
                          mini: true,
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
