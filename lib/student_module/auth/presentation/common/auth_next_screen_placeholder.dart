import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/buttons/medium_button.dart';
import 'package:game_edu/init_dependencies.dart';
import '../../services/firebase_auth_service.dart';
import '../login_page.dart';

/// Temporary home screen shown after successful sign-in.
/// Replace the call in `AuthNavigator.toHome` with your real home screen.
class AuthNextScreenPlaceholder extends StatefulWidget {
  const AuthNextScreenPlaceholder({super.key});

  @override
  State<AuthNextScreenPlaceholder> createState() =>
      _AuthNextScreenPlaceholderState();
}

class _AuthNextScreenPlaceholderState extends State<AuthNextScreenPlaceholder> {
  final FirebaseAuthService _authService = serviceLocator<FirebaseAuthService>();
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      await _authService.signOut();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log out. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.authTextPrimaryColor,
        ),
      );
      return;
    }

    if (!mounted) return;
    // Back to Login with a fresh AuthBloc, and clear the whole stack.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// Name if we have it (email register), otherwise email or phone.
  String get _displayName {
    final user = _authService.currentUser;
    if (user == null) return '';
    if ((user.displayName ?? '').trim().isNotEmpty) return user.displayName!;
    if ((user.email ?? '').isNotEmpty) return user.email!;
    return user.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName;

    return Scaffold(
      backgroundColor: AppPalette.authCardSurfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Welcome (center)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(
                              text: 'Welcome',
                              style: TextStyle(
                                color: AppPalette.authTextPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (name.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.primaryBlue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Logout (bottom)
              MediumButton(
                text: 'Logout',
                isLoading: _loggingOut,
                onPressed: _logout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}