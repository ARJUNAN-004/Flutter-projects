import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(authService: AuthService(), ref: ref);
});

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final currentUserProvider = StreamProvider<UserModel>((ref) {
  final authService = AuthService(); // Or use a provider for AuthService itself
  return authService.currentUserStream;
});

class AuthController extends StateNotifier<bool> {
  final AuthService _authService;
  final Ref _ref;

  AuthController({required AuthService authService, required Ref ref})
    : _authService = authService,
      _ref = ref,
      super(false); // State represents 'isLoading'

  Stream<User?> get authStateChange => _authService.currentUserStream.map(
    (user) => FirebaseAuth.instance.currentUser,
  );

  void verifyPhoneNumber(BuildContext context, String phoneNumber) {
    state = true; // Loading
    _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId, int? resendToken) {
        state = false;
        // Navigate to OTP Screen with arguments
        // In a clearer architecture, we might callback or use a stream for "navigation events"
        // For now, we assume the UI (LoginPage) handles navigation by passing callbacks,
        // or we use a separate provider for 'verificationId' state.
        // But for this 'Controller' refactor, let's keep it simple:
        // We can expose a provider for 'verificationId'.
      },
      onVerificationFailed: (FirebaseAuthException e) {
        state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification Failed')),
        );
      },
      onVerificationCompleted: (PhoneAuthCredential credential) async {
        state = false;
        await _authService.signInWithCredential(credential);
      },
      onCodeAutoRetrievalTimeout: (String verificationId) {
        state = false;
      },
    );
  }

  Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    state = true;
    try {
      final userCredential = await _authService.signInWithCredential(
        credential,
      );
      state = false;
      return userCredential;
    } catch (e) {
      state = false;
      return null;
    }
  }

  Future<void> saveUserToFirestore(User user, {bool isNewUser = false}) async {
    await _authService.saveUserToFirestore(user, isNewUser: isNewUser);
  }
}
