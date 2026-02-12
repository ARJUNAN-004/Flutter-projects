import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';

// Screen for Phone Number Authentication
class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  // final AuthService _authService = AuthService(); // Removed, use Controller
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // Keep for now for Web specific flow if needed, or move to Controller later

  bool _isLoading = false;
  bool _isOtpSent = false;

  String? _verificationId;
  ConfirmationResult? _confirmationResult;

  Country _selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "India",
    e164Key: "",
  );

  // Verify phone number
  void _verifyPhoneNumber() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid phone number")),
      );
      return;
    }

    // Remove any non-digit characters from the phone number
    String sanitizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    String fullPhoneNumber = "+${_selectedCountry.phoneCode}$sanitizedPhone";

    // Check Controller Loading State?
    // For now, local loading state is fine for UI feedback, but we could listen to provider.
    setState(() => _isLoading = true);

    if (kIsWeb) {
      try {
        final result = await _auth.signInWithPhoneNumber(fullPhoneNumber);
        if (!mounted) return;
        setState(() {
          _confirmationResult = result;
          _isOtpSent = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("OTP Sent!")));
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Verification Failed: $e")));
      }
    } else {
      // Use Controller for Mobile
      // But Controller.verifyPhoneNumber requires context for SnackBar (which I passed).
      // And it has hardcoded callbacks.
      // To properly integrate, I should pass the callbacks to the controller or Refactor Controller to return a Stream/Future.
      // Given the time, I will stick to existing logic but replace 'signIn with credential' part.
      // Actually, let's try to use the controller's verifyPhoneNumber if it matches logic.
      // The controller's verifyPhoneNumber is a bit rigid (calls state = true).
      // Let's call _auth.verifyPhoneNumber here but use Controller for the final SignIn.

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification Failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("OTP Sent!")));
        },
      );
    }
  }

  // Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final authController = ref.read(authControllerProvider.notifier);

    final userCredential = await authController.signInWithCredential(
      credential,
    );

    if (userCredential != null) {
      // Check if new user and save
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      await authController.saveUserToFirestore(
        userCredential.user!,
        isNewUser: isNewUser,
      );

      // AuthGate will handle navigation
      if (mounted) {
        // Optional: Show success message
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Sign In Failed")));
      }
    }
  }

  // Verify OTP entered by user
  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) return;
    if (kIsWeb && _confirmationResult == null) return;
    if (!kIsWeb && _verificationId == null) return;

    setState(() => _isLoading = true);
    final authController = ref.read(authControllerProvider.notifier);

    if (kIsWeb) {
      if (_confirmationResult == null) return;
      try {
        UserCredential userCredential = await _confirmationResult!.confirm(otp);
        // Save user using Controller
        await authController.saveUserToFirestore(
          userCredential.user!,
          isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
        );

        if (mounted) {
          // Success logic managed or navigation follows
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Invalid OTP: $e")));
        }
      }
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _signInWithCredential(credential);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/verification.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                "Phone Verification",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "We will send you a one-time password to this mobile number",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isOtpSent) ...[
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          countryListTheme: CountryListThemeData(
                            backgroundColor: theme.scaffoldBackgroundColor,
                            textStyle: TextStyle(color: colorScheme.onSurface),
                            searchTextStyle: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                            inputDecoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPhoneNumber,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Next"),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: "Enter OTP",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Verify"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
