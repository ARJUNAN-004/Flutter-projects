import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:logify/services/auth_check.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset(
          'assets/animations/animation_intro.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),

      /// Navigate to AuthCheck (same as your Timer-based splash)
      nextScreen: const AuthCheck(),

      splashIconSize: 250,
      backgroundColor: Colors.white,

      /// Duration controls how long splash stays
      duration: 900, // same timing as your Timer(900ms)

      animationDuration: const Duration(milliseconds: 1200),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      curve: Curves.easeInOut,
    );
  }
}