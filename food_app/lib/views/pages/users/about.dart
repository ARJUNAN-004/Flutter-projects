import 'package:flutter/material.dart';
import 'package:food_app/utils/consts.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: imageBackground1,

      appBar: AppBar(
        backgroundColor:imageBackground1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// App Icon + Title Container
            Center(
              child: Column(
                children: [
                  Container(
                    height: 95,
                    width: 95,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      size: 58,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Food App",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// About Section
            const Text(
              "About Us",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "This Food App helps you explore delicious meals, manage your cart, check favorites, and enjoy a smooth food ordering experience. "
              "Built using Flutter with beautiful UI and fast performance.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            /// Features Section
            const Text(
              "Features",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _featureTile(Icons.restaurant_menu, "Browse delicious food items"),
            _featureTile(Icons.favorite, "Save your favorite meals"),
            _featureTile(Icons.shopping_cart, "Add food to your cart"),
            _featureTile(Icons.delivery_dining, "Fast and reliable delivery"),
            _featureTile(Icons.security, "Secure user login with Supabase"),

            const SizedBox(height: 40),

            /// Developer Info Section
            const Text(
              "Developed By",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Arjunan S",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Text(
            //   "A passionate Flutter developer focused on creating high-quality mobile apps.",
            //   style: TextStyle(
            //     fontSize: 15,
            //     color: Colors.grey.shade600,
            //     height: 1.5,
            //   ),
            // ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.orange.shade100,
            child: Icon(icon, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
