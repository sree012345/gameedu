
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
import 'package:game_edu/student_module/dashboard/presentation/dashboard_page.dart';
import 'package:game_edu/student_module/dashboard/presentation/coming_soon_page.dart';

/// Used for RouteAware widgets.
final RouteObserver<PageRoute> routeObserver =
    RouteObserver<PageRoute>();

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
  };

  /// All application navigation comes through here.
  static Route<dynamic>? onGenerateRoute(
    RouteSettings settings,
  ) {
    final String path =
        Uri.parse(settings.name ?? RouterPath.authWrapper).path;

    final User? user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    debugPrint('========== GAME EDU ROUTER ==========');
    debugPrint('Requested Route: $path');
    debugPrint('Firebase UID: ${user?.uid}');
    debugPrint('Is Logged In: $isLoggedIn');
    debugPrint('=====================================');

    // Authentication routes that do not require login.
    const publicRoutes = {
      RouterPath.authWrapper,
      RouterPath.loginStep,
      RouterPath.welcome,
    };

    // Protect all private routes.
    if (!isLoggedIn && !publicRoutes.contains(path)) {
      debugPrint(
        '[AppRouter] Not logged in -> AuthWrapper',
      );

      return _material(
        settings,
        const AuthWrapper(),
        name: RouterPath.authWrapper,
      );
    }

    // Coming Soon screens for Game Edu.
    final comingSoonTitle = _comingSoonRoutes[path];

    if (comingSoonTitle != null) {
      debugPrint(
        '[AppRouter] Opening ComingSoon: $comingSoonTitle',
      );

      return _material(
        settings,
        ComingSoonPage(title: comingSoonTitle),
        name: path,
      );
    }

    switch (path) {
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

        return _material(
          settings,
          const LoginPage(),
          name: path,
        );

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

        return _material(
          settings,
          const _NotFoundPage(),
          name: path,
        );
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
      settings: RouteSettings(
        name: routeName,
        arguments: incoming.arguments,
      ),
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
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final user =
                    FirebaseAuth.instance.currentUser;

                Navigator.of(context)
                    .pushNamedAndRemoveUntil(
                  user != null
                      ? RouterPath.authWrapper
                      : RouterPath.loginStep,
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
      path == RouterPath.authWrapper;

  NotificationRouteGuard.allowForegroundNotification =
      !isOnboardingRoute;
}
