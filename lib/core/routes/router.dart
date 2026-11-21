/*
 * -----------------------------------------------------------------------------
 * File        : lib/core/routes/app_router.dart
 * Description : Central routing system for Game Edu.
 * Author      : Revolution Games Private Limited
 * -----------------------------------------------------------------------------
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/main.dart';

import 'package:game_edu/student_module/auth/presentation/login_page.dart';
import 'package:game_edu/student_module/create_profile/presentation/create_profile_page.dart';
import 'package:game_edu/student_module/dashboard/presentation/dashboard_page.dart';
import 'package:game_edu/student_module/dashboard/presentation/coming_soon_page.dart';
import 'package:game_edu/student_module/profile/presentation/edit_profile_page.dart';
import 'package:game_edu/student_module/profile/presentation/my_profile_page.dart';
import 'package:game_edu/student_module/splash/presentation/splash_page.dart';

/// Used for RouteAware widgets.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AppRouter {
  AppRouter._();

  // Existing flags retained for AuthWrapper compatibility.
  static bool isTermsRoute = false;
  static bool isResetPasswordRoute = false;
  static bool isLoginRoute = false;
  static bool isAdminLoginRoute = false;

  /// Game Edu routes whose screens are not built yet.
  static final Map<String, String> _comingSoonRoutes = {
    RouterPath.careers: 'Careers',
    RouterPath.courses: 'Courses',
    RouterPath.myLearning: 'My Learning',
    RouterPath.events: 'Events',
    RouterPath.helpSupport: 'Help & Support',
    RouterPath.aboutApp: 'About Game Edu',
    RouterPath.classes: 'Classes',
    RouterPath.assignments: 'Assignments',
    RouterPath.resources: 'Resources',
    RouterPath.community: 'Community',
    RouterPath.message: 'Chat', // left menu -> Chat
    RouterPath.notification: 'Notifications', // dashboard bell
  };

  /// All application navigation comes through here.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String path = Uri.parse(settings.name ?? RouterPath.splash).path;

    final User? user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    debugPrint('========== GAME EDU ROUTER ==========');
    debugPrint('Requested Route: $path');
    debugPrint('Firebase UID: ${user?.uid}');
    debugPrint('Is Logged In: $isLoggedIn');
    debugPrint('=====================================');

    // Routes that do not require login.
    const publicRoutes = {
      RouterPath.splash,
      RouterPath.authWrapper,
      RouterPath.loginStep,
      RouterPath.welcome,
    };

    // Protect all private routes.
    if (!isLoggedIn && !publicRoutes.contains(path)) {
      debugPrint('[AppRouter] Not logged in -> Login');

      return _material(
        settings,
        const LoginPage(),
        name: RouterPath.loginStep,
      );
    }

    // Coming Soon screens for Game Edu.
    final comingSoonTitle = _comingSoonRoutes[path];

    if (comingSoonTitle != null) {
      debugPrint('[AppRouter] Opening ComingSoon: $comingSoonTitle');

      return _material(
        settings,
        ComingSoonPage(title: comingSoonTitle),
        name: path,
      );
    }

    switch (path) {
      // App start: logo, then Login / Create Profile / Dashboard.
      case RouterPath.splash:
        return _material(settings, const SplashPage(), name: path);

    case RouterPath.myProfile:
  return _material(settings, const MyProfilePage(), name: path);
case RouterPath.editProfile:
  return _material(settings, const EditProfilePage(), name: path);
      // Firebase authentication wrapper.
      case RouterPath.authWrapper:
        return _material(
          settings,
          const AuthWrapper(),
          name: RouterPath.authWrapper,
        );

      // Login screen.
      case RouterPath.loginStep:
      case RouterPath.welcome:
        debugPrint('[AppRouter] Opening LoginPage');

        return _material(settings, const LoginPage(), name: path);

      // 3-step profile creation (after register / first login).
      case RouterPath.createProfile:
        debugPrint('[AppRouter] Opening CreateProfilePage');

        return _material(settings, const CreateProfilePage(), name: path);

      // Main Game Edu dashboard.
      case RouterPath.home:
        debugPrint('[AppRouter] Opening DashboardPage');

        return _material(
          settings,
          const DashboardPage(),
          name: RouterPath.home,
        );

      // Unrecognized routes.
      default:
        debugPrint('[AppRouter] Unknown route: $path');

        return _material(settings, const _NotFoundPage(), name: path);
    }
  }

  /// Material route builder.
  static PageRoute<T> _material<T>(
    RouteSettings incoming,
    Widget child, {
    String? name,
  }) {
    final routeName = name ?? incoming.name ?? '';

    updateNotificationPermission(routeName);

    return MaterialPageRoute<T>(
      builder: (_) => child,
      settings: RouteSettings(name: routeName, arguments: incoming.arguments),
    );
  }
}

/// 404 screen.
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Splash decides: Login / Create Profile / Dashboard
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouterPath.splash,
                  (route) => false,
                );
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification permission guard.
class NotificationRouteGuard {
  static bool allowForegroundNotification = false;
}

void updateNotificationPermission(String path) {
  final bool isOnboardingRoute =
      path == RouterPath.welcome ||
      path == RouterPath.loginStep ||
      path == RouterPath.splash ||
      path == RouterPath.authWrapper;

  NotificationRouteGuard.allowForegroundNotification = !isOnboardingRoute;
}