import 'package:flutter/material.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/pages/post_places.dart';

class TopPlaces extends StatefulWidget {
  const TopPlaces({super.key});

  @override
  State<TopPlaces> createState() => _TopPlacesState();
}

class _TopPlacesState extends State<TopPlaces> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    child: Material(
                      elevation: 3.0,
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
                  SizedBox(width: screenWidth / 5),
                  const Text(
                    'TOP PLACES',
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

            // Top Places List
            Expanded(
              child: Material(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                elevation: 3.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 30.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildPlaceRow([
                          buildPlaceCard('assets/images/india.jpg', 'India', context),
                          buildPlaceCard('assets/images/bali.jpg', 'Bali', context),
                        ]),
                        const SizedBox(height: 20),
                        buildPlaceRow([
                          buildPlaceCard('assets/images/mexico.jpg', 'Mexico', context),
                          buildPlaceCard('assets/images/france.jpg', 'France', context),
                        ]),
                        const SizedBox(height: 20),
                        buildPlaceRow([
                          buildPlaceCard('assets/images/newyork.jpg', 'New York', context),
                          buildPlaceCard('assets/images/dubai.jpg', 'Dubai', context),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPlaceRow(List<Widget> places) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: places,
    );
  }

  Widget buildPlaceCard(String imagePath, String title, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the PostPlaces page and pass data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostPlaces(
              placeName: title,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 3.0,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                imagePath,
                height: 300,
                width: 180,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 265),
              width: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Color.fromARGB(100, 0, 0, 0),
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Pacifico',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}