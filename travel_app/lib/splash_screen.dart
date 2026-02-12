import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:travel_app/pages/signup.dart';

class AnimatedSplashScreenWidget extends StatelessWidget {
  const AnimatedSplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset(
          'assets/animation_123.json',
          fit: BoxFit.contain,
        ),
      ),
      nextScreen: const SignUp(),
      splashIconSize: 300,
      backgroundColor: Colors.white,
      duration: 6000,
      splashTransition: SplashTransition.fadeTransition,
      animationDuration: const Duration(milliseconds: 1000),
      pageTransitionType: PageTransitionType.fade,
      curve: Curves.easeInOut,

    );
  }
}