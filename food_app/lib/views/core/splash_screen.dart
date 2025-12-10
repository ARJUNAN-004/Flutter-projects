import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:food_app/services/auth_check.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF8C42),
            Color(0xFFFF9F5A),
            Color(0xFFFFB347),
          ],
        ),
      ),

      child: AnimatedSplashScreen(

        backgroundColor: Colors.transparent,

        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// Smooth upward movement
            Transform.translate(
              offset: const Offset(0, -20),
              child: SizedBox(
                height: 350,     // Perfect visual size for your 1330px Lottie
                child: Lottie.asset(
                  'assets/animations/food.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Subtle fade-in brand name
            const Text(
              "FoodyTime",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Delicious food delivered fast",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),

        nextScreen:  AuthCheck(),

        splashIconSize: 600,

        /// Perfect smooth timing values
        duration: 1800,               // Slightly faster / smoother
        animationDuration: Duration(
          milliseconds: 1500,          // More natural fade
        ),

        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        curve: Curves.easeOutCubic,    // much smoother easing
      ),
    );
  }
}
