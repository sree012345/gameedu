/*
 * -----------------------------------------------------------------------------
 * File        : lib/core/routes/app_router.dart
 * Description : Central routing system for the application.
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-03-04
 * -----------------------------------------------------------------------------
 *
 * Class       : AppRouter
 * Purpose     : Handles navigation between application screens
 *
 * Features
 *  - Login route guard
 *  - Onboarding route restriction
 *  - Centralized navigation
 *  - Route observer support
 *  - Notification permission control
 * -----------------------------------------------------------------------------
 */


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/core/firebase/firebase_initialization.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/main.dart';


/// Used for RouteAware widgets
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AppRouter {
  static Future<bool> _isAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = snapshot.data();

    return (data?['type'] ?? '').toString() == 'admin';
  }

  /// Main router entry
  static bool isTermsRoute = false;
  static bool isResetPasswordRoute = false;
  static bool isLoginRoute = false;
  static bool isAdminLoginRoute = false;
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final user = FirebaseInitialization.isFirebaseAppInitialized()
        ? FirebaseAuth.instance.currentUser
        : null;
    final bool isLoggedIn = user != null;
    final uri = Uri.parse(settings.name ?? RouterPath.myProfile);
    final String path = uri.path;
    final Map<String, String> queryParams = uri.queryParameters;
    // Auth Guard
    const publicRoutes = {
      RouterPath.welcome,
      RouterPath.splash,
      RouterPath.authWrapper,
      RouterPath.loginStep,
      RouterPath.onBoarding,
      RouterPath.terms,
      RouterPath.resetPassword,
    };

    if (!isLoggedIn && !publicRoutes.contains(path)) {
      return _material(
        name: RouterPath.welcome,
        settings,
        const Placeholder(),
      );
    }
    if (path == RouterPath.welcome) {
      return _material(
        name: RouterPath.welcome,
        settings,
        const Placeholder(),
      );
    }

  

    const adminRoutes = {
      RouterPath.moderationQueue,
      RouterPath.auditLogs,
      RouterPath.userManagement,
      RouterPath.reportDetail,
      RouterPath.auditReportDetail,
      RouterPath.adminJobManagement,
    };

    if (adminRoutes.contains(path)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) {
          return FutureBuilder<bool>(
            future: _isAdmin(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.data != true) {
                return const _NotFoundPage();
              }

              return const Placeholder();
            },
          );
        },
      );
    }
    switch (path) {
      /// ACTIVE ROUTE
      case RouterPath.myProfile:
      case RouterPath.home:
      case RouterPath.tournaments:
      case RouterPath.coach:
      case RouterPath.explore:
      case RouterPath.live:
      case RouterPath.moderationQueue:
      case RouterPath.auditLogs:
      case RouterPath.userManagement:
      case RouterPath.adminJobManagement:
        return _material(name: path, settings, const Placeholder());
      case RouterPath.authWrapper:
        return _material(
          name: RouterPath.authWrapper,
          settings,
          const AuthWrapper(),
        );
      
      case RouterPath.loginStep:
        return _material(
          name: RouterPath.loginStep,
          settings,
          const Placeholder(),
        );

      // case RouterPath.inviteMembers:
      //   return _material(
      //     name: RouterPath.inviteMembers,
      //     settings,
      //     const InviteMembersPage(),
      //   );
   
   
     

      //  case RouterPath.memberRequest:
      //   final args = settings.arguments as Map<String, dynamic>?;

      //   final String? teamId =
      //       args?["teamId"] ?? queryParams['teamId'];

      //   final int index =
      //       args?["index"] ??
      //       int.tryParse(queryParams['index'] ?? '0') ??
      //       0;

      //   if (teamId == null || teamId.isEmpty) {
      //     return _material(
      //       settings,
      //       const _NotFoundPage(),
      //       name:
      //           "${RouterPath.memberRequest}?teamId=$teamId",
      //     );
      //   }

      //   return _material(
      //     settings,
      //     MemberRequestPage(
      //       teamId: teamId,
      //       index: index,
      //     ),
      //     name:
      //         "${RouterPath.memberRequest}"
      //         "?teamId=$teamId"
      //         "&index=$index",
      //   );
    
      


      case RouterPath.channel:
        return _material(
          settings,
          name: settings.name, // Keep the full URL with query params
          const Placeholder(),
        );
  
  
      case RouterPath.profileIntraction:
        final uri = Uri.parse(settings.name ?? '');
        final profileUserId = uri.queryParameters[':'] ?? '';
        final int tab = int.tryParse(uri.queryParameters['tab'] ?? '0') ?? 0;

        if (profileUserId.isEmpty) {
          return _material(
            settings,
            const _NotFoundPage(),
            name: '${RouterPath.profileIntraction}?:=$profileUserId',
          );
        }

  

  

     

      default:
        // If user is logged in, go home instead of 404
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return _material(
            settings,
            const Placeholder(),
            name: RouterPath.home,
          );
        }
        return _material(settings, const _NotFoundPage());
    }
  }

  // ------------------------------------------------------
  // Material Route Builder
  // ------------------------------------------------------

  static PageRoute _material(
    RouteSettings incoming,
    Widget child, {
    String? name,
  }) {
    final routeName = name ?? incoming.name ?? '';

    /// Update notification permission
    updateNotificationPermission(routeName);

    return MaterialPageRoute(
      builder: (_) => child,
      settings: RouteSettings(
        name: incoming.name,
        arguments: incoming.arguments,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
///
/// 404 Page
///
////////////////////////////////////////////////////////////////

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
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  Navigator.of(context).pushReplacementNamed(RouterPath.home);
                } else {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(RouterPath.welcome);
                }
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
///
/// Notification Permission Guard
///
////////////////////////////////////////////////////////////////

class NotificationRouteGuard {
  static bool allowForegroundNotification = false;
}

void updateNotificationPermission(String path) {
  final bool isOnboardingRoute = path == RouterPath.welcome;

  NotificationRouteGuard.allowForegroundNotification = !isOnboardingRoute;
}
