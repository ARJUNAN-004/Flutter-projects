import 'package:flutter/material.dart';
import 'package:travel_app/pages/comment.dart';

class PostPlaces extends StatefulWidget {
  final String placeName;
  final String imagePath;

  const PostPlaces({super.key, required this.placeName, required this.imagePath});

  @override
  State<PostPlaces> createState() => _PostPlacesState();
}

class _PostPlacesState extends State<PostPlaces> {
  bool isLiked = false;
  int likeCount = 0;

  @override
  Widget build(BuildContext context) {
    // Mock Post Data
    final Map<String, String> post = {
      "postedBy": "Anonymous",
      "profilePic": "assets/images/anonymous.jpg", // Ensure this file exists!
      "caption": "${widget.placeName} is a must-visit destination! The sights, culture, and atmosphere are unforgettable!",
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.placeName),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Material(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset('assets/images/anonymous.jpg'
                      ,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                  title: Text(
                    post['postedBy']!,
                    style: const TextStyle(
                      fontFamily: 'Gendy',
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Image
                Image.asset(
                  widget.imagePath,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 260,
                      child: Center(child: Icon(Icons.broken_image, size: 60)),
                    );
                  },
                ),

                // Caption and Action Buttons
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            widget.placeName,
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
                        post['caption']!,
                        style: const TextStyle(fontFamily: 'Gendy', fontSize: 15),
                      ),
                      const SizedBox(height: 12),

                      // Like, Comment, Share row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Like Button
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

                          // Comment Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CommentPage(),
                                ),
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

                          // Share Button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your post has been shared!'),
                                  duration: Duration(seconds: 2),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
