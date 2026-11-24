import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';

import '../../bloc/dashboard_bloc.dart';
import '../../models/dashboard_user.dart';

/// Left menu. User name / email come from Firebase via [DashboardBloc].
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({super.key, required this.onLogout});

  /// Shows the "Are you sure?" popup (handled by the page).
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Drawer(
      width: (width * 0.8).clamp(280.0, 340.0).toDouble(),
      backgroundColor: AppPalette.authCardSurfaceColor,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(36)),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final bloc = context.read<DashboardBloc>();
          final navigator = Navigator.of(context);

          void select(DashboardMenu item) {
            navigator.pop(); // close the drawer
            bloc.add(DashboardMenuSelected(item));
          }

          _DrawerItem item(
            DashboardMenu menu,
            IconData icon,
            String label, {
            int badge = 0,
          }) {
            return _DrawerItem(
              icon: icon,
              label: label,
              badge: badge,
              selected: state.selectedMenu == menu,
              onTap: () => select(menu),
            );
          }

          return Column(
            children: [
              _DrawerHeader(
                user: state.user,
                onProfileTap: () => select(DashboardMenu.profile),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  children: [
                    item(DashboardMenu.home, Icons.home_outlined, 'Home'),
                    item(DashboardMenu.courses, Icons.layers_outlined, 'Classes'),
                    item(
                      DashboardMenu.myLearning,
                      Icons.smart_display_outlined,
                      'My Learning',
                    ),
                    item(
                      DashboardMenu.events,
                      Icons.calendar_month_outlined,
                      'Events',
                    ),
                    item(
                      DashboardMenu.chat,
                      Icons.chat_bubble_outline_rounded,
                      'Chat',
                      badge: state.unreadChatCount,
                    ),
                    const _DrawerDivider(),
                    item(
                      DashboardMenu.profile,
                      Icons.person_outline_rounded,
                      'Profile',
                    ),
                    item(
                      DashboardMenu.help,
                      Icons.help_outline_rounded,
                      'Help & Support',
                    ),
                    item(
                      DashboardMenu.about,
                      Icons.info_outline_rounded,
                      'About Game Edu',
                    ),
                    const _DrawerDivider(),
                    _LogoutItem(
                      onTap: () {
                        navigator.pop();
                        onLogout();
                      },
                    ),
                  ],
                ),
              ),
              const _BottomWave(),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────── header ─────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user, required this.onProfileTap});

  final DashboardUser? user;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppPalette.headerGradientStart, AppPalette.headerGradientMid],
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: _LogoMark(),
                  ),
                  const SizedBox(height: 18),
                  _ProfileTile(user: user, onTap: onProfileTap),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const CustomPaint(
            size: Size(double.infinity, 36),
            painter: _WavePainter(),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.school_rounded, size: 34, color: AppPalette.white),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            children: [
              TextSpan(text: 'Game ', style: TextStyle(color: AppPalette.white)),
              TextSpan(text: 'Edu', style: TextStyle(color: AppPalette.accentCyan)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.user, required this.onTap});

  final DashboardUser? user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Loading...';
    final contact = user?.contactLine ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.authCardSurfaceColor,
              border: Border.all(color: AppPalette.overlayWhite20, width: 3),
            ),
            child: Text(
              user?.initials ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppPalette.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1.5, height: 42, color: AppPalette.overlayWhite20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.white,
                  ),
                ),
                if (contact.isNotEmpty)
                  Text(
                    contact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppPalette.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: AppPalette.white),
        ],
      ),
    );
  }
}

/// Two layered waves under the header (light blue, then white).
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Path()
      ..moveTo(0, h * 0.6)
      ..cubicTo(w * 0.25, h * 0.05, w * 0.55, h * 0.95, w, h * 0.2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final front = Path()
      ..moveTo(0, h * 0.85)
      ..cubicTo(w * 0.3, h * 0.3, w * 0.6, h * 1.0, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      back,
      Paint()..color = AppPalette.pageGradientStart.withValues(alpha: 0.6),
    );
    canvas.drawPath(front, Paint()..color = AppPalette.authCardSurfaceColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomWave extends StatelessWidget {
  const _BottomWave();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      width: double.infinity,
      child: CustomPaint(painter: _BottomWavePainter()),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.3, h * 1.1, w * 0.6, h * 0.0, w, h * 0.45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final front = Path()
      ..moveTo(0, h * 0.8)
      ..cubicTo(w * 0.35, h * 0.3, w * 0.65, h * 1.0, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      back,
      Paint()..color = AppPalette.pageGradientStart.withValues(alpha: 0.5),
    );
    canvas.drawPath(front, Paint()..color = AppPalette.primaryBlueLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ───────────────────────── items ─────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppPalette.primaryBlueDark
        : AppPalette.authTextPrimaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? AppPalette.buttonShadowColor : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected ? AppPalette.primaryBlue : color,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (badge > 0) _Badge(count: badge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: AppPalette.errorText,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppPalette.white,
        ),
      ),
    );
  }
}

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, thickness: 1.5, color: AppPalette.authDividerColor),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  const _LogoutItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.errorText.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 26, color: AppPalette.errorText),
              SizedBox(width: 18),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.errorText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
