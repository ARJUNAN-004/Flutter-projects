import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/pages/add_page.dart';
import 'package:travel_app/pages/comment.dart';
import 'package:travel_app/pages/profile.dart';
import 'package:travel_app/pages/top_places.dart';
import 'package:travel_app/services/database.dart';
import 'package:travel_app/services/shared_pref.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userProfileUrl;
  String? userName;
  String searchQuery = ""; // Store the search input

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/home.png',
                width: screenWidth,
                height: screenHeight / 2.5,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  right: 20.0,
                  left: 20.0,
                ),
                child: Row(
                  children: [
                    Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TopPlaces()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/pin.png',
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddPage()),
                        );
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: 
                        (context)=>ProfilePage()));
                      },
                      child: Material(
                        elevation: 3.0,
                        borderRadius: BorderRadius.circular(60),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: userProfileUrl != null && userProfileUrl!.isNotEmpty
                              ? Image.network(
                                  userProfileUrl!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/boy.jpg',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 160, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Let's Go",
                      style: TextStyle(
                        fontFamily: 'Gendy',
                        color: Colors.white,
                        fontSize: 60,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Travel Community App",
                      style: TextStyle(
                        fontFamily: 'Gendy',
                        color: Color.fromARGB(191, 255, 255, 255),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: screenHeight / 2.7,
                ),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.only(left: 18.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Your Destination',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: DatabaseMethods().getPosts(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];

                    // Extract post details
                    var placeName = post['placeName'].toLowerCase();
                    var cityName = post['cityName'].toLowerCase();
                    var caption = post['caption'].toLowerCase();

                    // Apply search filter
                    if (searchQuery.isNotEmpty &&
                        !(placeName.contains(searchQuery) ||
                          cityName.contains(searchQuery) ||
                          caption.contains(searchQuery))) {
                      return const SizedBox.shrink(); // Hide non-matching posts
                    }

                    return buildPostCard(
                      post['postedBy'],
                      post['profilePic'],
                      post['imageUrl'],
                      post['placeName'],
                      post['cityName'],
                      post['caption'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPostCard(
    String userName,
    String userAvatar,
    String imageUrl,
    String placeName,
    String cityName,
    String caption,
  ) {
    int likeCount = 0;
    bool isLiked = false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  userAvatar,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'Gendy',
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Image.network(
              imageUrl,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        "$placeName, $cityName",
                        style: const TextStyle(
                          fontFamily: 'Gendy',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    style: const TextStyle(fontFamily: 'Gendy', fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLiked = !isLiked;
                                likeCount += isLiked ? 1 : -1;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_outline,
                                  color: isLiked ? Colors.redAccent : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text("$likeCount Like"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CommentPage()),
                              );
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.comment_outlined, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("Comment"),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your file has been shared!'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.share_outlined, color: Colors.grey),
                                SizedBox(width: 4),
                                Text("Share"),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}