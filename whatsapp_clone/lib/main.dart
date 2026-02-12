import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/splash/safe_splash_screen.dart';
import 'services/auth_gate.dart';
import 'utils/colors.dart';
import 'providers/theme_provider.dart';
import 'lifecycle_manager.dart';
import 'utils/navigator_key.dart';
import 'services/notification_service.dart';

// App Entry Point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(ProviderScope(child: MyApp(seenOnboarding: seenOnboarding)));
}

// Root Widget of the application
class MyApp extends ConsumerWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return LifecycleManager(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Chathub',
        debugShowCheckedModeBanner: false,
        theme: FlexThemeData.light(
          colors: const FlexSchemeColor(
            primary: AppColors.primaryLight,
            primaryContainer: AppColors.primaryLight,
            secondary: AppColors.accent,
            secondaryContainer: AppColors.accent,
            tertiary: AppColors.primaryLight,
            tertiaryContainer: AppColors.primaryLight,
            appBarColor: AppColors.primaryLight,
            error: AppColors.error,
          ),
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 10,
            blendOnColors: false,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        darkTheme: FlexThemeData.dark(
          colors: const FlexSchemeColor(
            primary: AppColors.primaryDark,
            primaryContainer: AppColors.primaryDark,
            secondary: AppColors.accent,
            secondaryContainer: AppColors.accent,
            tertiary: AppColors.primaryDark,
            tertiaryContainer: AppColors.primaryDark,
            appBarColor: AppColors.primaryDark,
            error: AppColors.error,
          ),
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        themeMode: themeMode,
        // Check if user has seen onboarding
        home: !seenOnboarding ? const SafeSplashScreen() : const AuthGate(),
      ),
    );
  }
}
