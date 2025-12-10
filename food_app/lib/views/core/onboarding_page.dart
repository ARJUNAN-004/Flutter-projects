import 'package:flutter/material.dart';
import 'package:food_app/models/on_bording_model.dart';
import 'package:food_app/utils/consts.dart';
import 'package:food_app/views/pages/food/main_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: imageBackground1,

      body: Stack(
        children: [
          /// Background Pattern
          Positioned.fill(
            child: Image.asset(
              "assets/cartoons/food_pattern.png",
              repeat: ImageRepeat.repeatY,
              color: imageBackground2,
            ),
          ),

          /// Decorative Images
          Positioned(top: -60, left: 0, right: 0, child: Image.asset("assets/cartoons/chef.png")),
          Positioned(top: 140, right: 40, child: Image.asset("assets/cartoons/leaf.png", width: 80)),
          Positioned(top: 360, right: 30, child: Image.asset("assets/cartoons/chili.png", width: 80)),
          Positioned(top: 240, left: -10, child: Image.asset("assets/cartoons/ginger.png", width: 80)),

          /// Bottom container with text + button
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BottomClip(),
              child: Container(
                width: size.width,
                color: Colors.amber[50],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 70),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// PageView Titles
                    SizedBox(
                      height: 170,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: data.length,
                        onPageChanged: (index) => setState(() => _currentIndex = index),
                        itemBuilder: (_, index) => Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                      text: data[index]['title1'],
                                      style: const TextStyle(color: Colors.black)),
                                  TextSpan(
                                      text: data[index]['title2'],
                                      style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data[index]['description']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        data.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentIndex == index ? 22 : 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? Colors.orange : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// "GET STARTED" BUTTON
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                        );
                      },
                      minWidth: 260,
                      height: 60,
                      color: red,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
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

class BottomClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 30);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 30);
    path.quadraticBezierTo(size.width / 2, -30, 0, 30);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
