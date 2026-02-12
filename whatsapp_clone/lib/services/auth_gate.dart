import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../views/home/home_page.dart';
import '../views/auth/phone_login_page.dart';

import '../views/splash/loading_screen.dart';
import '../widgets/call_invitation_wrapper.dart';
import 'notification_service.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangeProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          final userProfileAsyncValue = ref.watch(currentUserProvider);

          return userProfileAsyncValue.when(
            data: (userModel) {
              NotificationService().saveTokenToDatabase();
              return CallInvitationWrapper(
                userId: userModel.id,
                userName: userModel.name.isNotEmpty ? userModel.name : "User",
                child: const HomePage(),
              );
            },
            loading: () => const LoadingScreen(),
            error: (err, stack) {
              // Should allow user to enter even if profile not loaded?
              // Or maybe just show loading.
              // If error is "Permission denied" or "doc not found", we might want to handle it.
              // For now, minimal fallback
              return CallInvitationWrapper(
                userId: user.uid,
                userName: "User",
                child: const HomePage(),
              );
            },
          );
        }
        return const PhoneLoginPage();
      },
      loading: () => const LoadingScreen(),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
