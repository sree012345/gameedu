/*
 * -----------------------------------------------------------------------------
 * File        : lib/core/router/app_routes.dart
 * Description : Central route definitions and page resolver used throughout
 *               the application.
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-03-10
 * Last Updated: 2026-03-10
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : AppRoutes
 * Purpose     : Provides route names and resolves widgets for routes.
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:game_edu/core/routes/router_path.dart';

class AppRoutes {
  /// Returns the corresponding page widget for a given route
  static Widget getPage(String route, [String? deepRoute]) {
    switch (route) {
      case RouterPath.moderationQueue:
        return ReportSectionWrapper(initialRoute: Uri.base.toString());
      case RouterPath.auditLogs:
        return AuditSectionWrapper(initialRoute: Uri.base.toString());
      default:
        return const SizedBox.shrink();
    }
  }
}

Route<dynamic> _emptyRoute() {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => const Placeholder(),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

class ReportSectionWrapper extends StatelessWidget {
  final String? initialRoute;

  const ReportSectionWrapper({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: initialRoute ?? '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == RouterPath.reportDetail) {
          final id = uri.queryParameters['reportId'];
          if (id == null || id.isEmpty) return _emptyRoute();
          // TODO: return the report detail page here.
        }
        return null;
      },
    );
  }
}

class AuditSectionWrapper extends StatelessWidget {
  final String? initialRoute;

  const AuditSectionWrapper({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: initialRoute ?? '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == RouterPath.auditReportDetail) {
          final id = uri.queryParameters['reportId'];
          if (id == null || id.isEmpty) return _emptyRoute();
          // TODO: return the audit report detail page here.
        }
        return null;
      },
    );
  }
}

class TournamentSectionWrapper extends StatelessWidget {
  final String? initialRoute;

  const TournamentSectionWrapper({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: initialRoute ?? '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        final params = uri.queryParameters;
        logRoute("INNER NAV → ${settings.name}");

        switch (uri.path) {
          case RouterPath.tournamentDetail:
            logRoute("OPEN DETAIL → id=${params['tournamentId']}");
          case RouterPath.soloRegister:
            logRoute(
              "OPEN SOLO REGISTER → "
              "tId=${params['tournamentId']} dId=${params['divisionId']}",
            );
          case RouterPath.disputeResolution:
            logRoute("OPEN DISPUTE RESOLUTION → tId=${params['tournamentId']}");
          case RouterPath.chooseTeam:
            logRoute(
              "OPEN CHOOSE TEAM → "
              "tId=${params['tournamentId']} dId=${params['divisionId']}",
            );
          case RouterPath.teamRegister:
            logRoute(
              "OPEN TEAM REGISTER → "
              "tId=${params['tournamentId']} "
              "dId=${params['divisionId']} "
              "teamId=${params['teamId']}",
            );
        }
        // TODO: return the real pages for each route above.
        return null;
      },
    );
  }

  void logRoute(String message) {
    debugPrint(" ROUTE: $message");
  }
}