import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/routes/router_path.dart';
import '../../bloc/dashboard_bloc.dart';

List<BoxShadow> _cardShadow() => [
  BoxShadow(
    color: AppPalette.buttonShadowColor.withValues(alpha: 0.7),
    blurRadius: 14,
    offset: const Offset(0, 5),
  ),
];

/// Home tab. Lists are empty for now (empty states only).
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final bloc = context.read<DashboardBloc>();
        final user = state.user;

        void open(String route) => bloc.add(DashboardRouteRequested(route));
        void goTab(int index) => bloc.add(DashboardTabChanged(index));

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user == null ? 'Hi there' : 'Hi, ${user.firstName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.authTextPrimaryColor,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Ready to learn something new?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPalette.authTextSecondaryColor,
                ),
              ),
              if (user != null && user.college.isNotEmpty) ...[
                const SizedBox(height: 14),
                _CollegeChip(name: user.college),
              ],
              const SizedBox(height: 16),
              _ContinueLearningCard(onBrowse: () => goTab(DashboardTab.courses)),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Live Class Today',
                onViewAll: () => open(RouterPath.classes),
              ),
              const SizedBox(height: 10),
              const _EmptyCard(
                icon: Icons.videocam_off_outlined,
                title: 'No live classes today',
                subtitle: 'Classes scheduled for you will show up here.',
              ),
              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Upcoming Events',
                onViewAll: () => goTab(DashboardTab.events),
              ),
              const SizedBox(height: 10),
              const _EmptyCard(
                icon: Icons.event_busy_outlined,
                title: 'No upcoming events',
                subtitle: 'Events and hackathons will show up here.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CollegeChip extends StatelessWidget {
  const _CollegeChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.primaryBlue.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 20,
              color: AppPalette.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.authTextPrimaryColor,
              ),
            ),
          ),
          const Icon(
            Icons.check_rounded,
            size: 22,
            color: AppPalette.successColor,
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppPalette.primaryButtonGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'No Classes in progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a course and pick up where you left off.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppPalette.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: AppPalette.white,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onBrowse,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Text(
                        'Browse Classes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: AppPalette.overlayWhite20,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.view_in_ar_rounded,
              size: 42,
              color: AppPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppPalette.authTextPrimaryColor,
            ),
          ),
        ),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'View all',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppPalette.primaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.authCardSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.primaryBlue.withValues(alpha: 0.10),
            ),
            child: Icon(icon, color: AppPalette.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.authTextPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppPalette.authTextSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
