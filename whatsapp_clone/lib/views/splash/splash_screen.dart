import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:whatsapp_clone_ui/views/onboarding/onboarding_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset(
          isDark
              ? 'assets/animations/black_splash_screen.json'
              : 'assets/animations/white_splash_screen.json',
          width: 500,
          height: 500,
          fit: BoxFit.contain,
        ),
      ),

      /// Navigate to AuthCheck (same as your Timer-based splash)
      nextScreen: const OnboardingPage(),

      splashIconSize: 300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      /// Duration controls how long splash stays
      duration: 1500, // same timing as your Timer(900ms)

      animationDuration: const Duration(milliseconds: 1500),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      curve: Curves.easeInOut,
    );
  }
}
