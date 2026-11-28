import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/init_dependencies.dart';
import 'package:game_edu/student_module/community/presentation/community_formatters.dart';

import '../../bloc/community_list/community_list_bloc.dart';
import '../../data/models/community_model.dart';
import '../community_navigator.dart';
import '../community_theme.dart';
import '../widgets/community_avatar.dart';

/// Community list – BODY ONLY (no header, no bottom bar), so it can sit inside
/// the screen/tab that already has your header and bottom navigation.
class CommunityListScreen extends StatelessWidget {
  const CommunityListScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CommunityListBloc>()..add(const CommunityListStarted()),
      child: const _CommunityListView(),
    );
  }
}

class _CommunityListView extends StatelessWidget {
  const _CommunityListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityListBloc, CommunityListState>(
      builder: (context, state) {
        switch (state.status) {
          case CommunityListStatus.initial:
          case CommunityListStatus.loading:
            return const Center(child: CircularProgressIndicator());

          case CommunityListStatus.failure:
            return _ErrorView(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () =>
                  context.read<CommunityListBloc>().add(const CommunityListStarted()),
            );

          case CommunityListStatus.success:
            final communities = state.communities;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                if (state.canCreate) const _CreateTile(),
                if (communities.isEmpty)
                  _EmptyView(canCreate: state.canCreate)
                else
                  for (final community in communities)
                    _CommunityCard(
                      community: community,
                      unread: state.unreadFor(community),
                      cleared: state.isCleared(community),
                    ),
              ],
            );
        }
      },
    );
  }
}

class _CreateTile extends StatelessWidget {
  const _CreateTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: CommunityColors.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => CommunityNavigator.openCreate(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.add_circle_rounded, color: Colors.white, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Create new community',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.community,
    required this.unread,
    required this.cleared,
  });

  final CommunityModel community;
  final int unread;

  /// The user cleared this chat: hide the old last message and its time.
  final bool cleared;

  @override
  Widget build(BuildContext context) {
    final preview = cleared
        ? 'No messages yet'
        : (community.lastMessagePreview ??
            (community.description.isEmpty
                ? 'No messages yet'
                : community.description));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: communityBorder,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => CommunityNavigator.openChat(context, community.id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CommunityAvatar(imageUrl: community.imageUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CommunityColors.title,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CommunityColors.subtitle,
                            fontSize: 14,
                            fontWeight:
                                unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        cleared ? '' : CommunityFormatters.listTime(community.lastMessageAt),
                        style: const TextStyle(
                          color: CommunityColors.subtitle,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (unread > 0)
                        Container(
                          constraints:
                              const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: const BoxDecoration(
                            color: CommunityColors.primary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(Icons.groups_rounded,
              size: 64, color: CommunityColors.primary.withOpacity(0.35)),
          const SizedBox(height: 16),
          Text(
            canCreate ? 'No communities yet' : "You haven't joined any community yet",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CommunityColors.title,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            canCreate
                ? 'Create one and add participants.'
                : 'When an admin adds you, it will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: CommunityColors.subtitle),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: CommunityColors.danger),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CommunityColors.subtitle)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}