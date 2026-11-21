import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/routes/router_path.dart';
import 'package:game_edu/init_dependencies.dart';

import '../bloc/dashboard_bloc.dart';
import 'views/home_tab.dart';
import 'widgets/dashboard_bottom_nav.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/logout_dialog.dart';

/// Home dashboard: header + tabs + bottom navigation + left menu.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) =>
          serviceLocator<DashboardBloc>()..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  static const List<String> _titles = [
    'Game Edu',
    'Courses',
    'Events',
    'Community',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Open a screen requested by the bloc
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (p, c) => c.route != null && p.route != c.route,
          listener: (context, state) =>
              Navigator.of(context).pushNamed(state.route!),
        ),
        // Logged out -> login screen, clear the whole stack
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == DashboardStatus.loggedOut,
          listener: (context, state) => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(RouterPath.loginStep, (route) => false),
        ),
        // One-shot messages
        BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (p, c) => c.message != null && p.message != c.message,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppPalette.authTextPrimaryColor,
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final bloc = context.read<DashboardBloc>();

          return PopScope(
            // Back on another tab -> go to Home first
            canPop: state.tabIndex == DashboardTab.home,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) bloc.add(const DashboardTabChanged(DashboardTab.home));
            },
            child: Scaffold(
              drawer: DashboardDrawer(onLogout: () => confirmLogout(context)),
              bottomNavigationBar: DashboardBottomNav(
                currentIndex: state.tabIndex,
                onChanged: (i) => bloc.add(DashboardTabChanged(i)),
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      DashboardHeader(
                        title: _titles[state.tabIndex],
                        onBellTap: () => bloc.add(
                          const DashboardRouteRequested(RouterPath.notification),
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: state.tabIndex,
                          children: const [
                            HomeTab(),
                            _TabPlaceholder(
                              icon: Icons.menu_book_outlined,
                              title: 'Courses',
                            ),
                            _TabPlaceholder(
                              icon: Icons.calendar_today_outlined,
                              title: 'Events',
                            ),
                            _TabPlaceholder(
                              icon: Icons.groups_outlined,
                              title: 'Community',
                            ),
                            _TabPlaceholder(
                              icon: Icons.person_outline_rounded,
                              title: 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (state.status == DashboardStatus.loggingOut)
                    Positioned.fill(
                      child: Stack(
                        children: [
                          ModalBarrier(
                            dismissible: false,
                            color: AppPalette.authTextPrimaryColor.withValues(
                              alpha: 0.35,
                            ),
                          ),
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppPalette.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.primaryBlue.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 40, color: AppPalette.primaryBlue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming soon',
              style: TextStyle(
                fontSize: 14,
                color: AppPalette.authTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
