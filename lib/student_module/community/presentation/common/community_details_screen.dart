import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/init_dependencies.dart';
import 'package:game_edu/student_module/community/presentation/community_navigator.dart';

import '../../bloc/community_details/community_details_bloc.dart';
import '../../data/models/community_message.dart';
import '../../data/models/community_model.dart';
import '../../data/models/community_user.dart';
import '../community_theme.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_header.dart';
import '../widgets/confirm_dialog.dart';

class CommunityDetailsScreen extends StatelessWidget {
  const CommunityDetailsScreen({
    super.key,
    required this.communityId,
  });

  final String communityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CommunityDetailsBloc>()..add(CommunityDetailsStarted(communityId)),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityDetailsBloc, CommunityDetailsState>(
      listenWhen: (previous, current) =>
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          (current.infoMessage != null &&
              previous.infoMessage != current.infoMessage),
      listener: (context, state) {
        final text = state.errorMessage ?? state.infoMessage;
        if (text != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: CommunityColors.background,
          body: Column(
            children: [
              CommunityHeader(
                title: 'Community info',
                // Only the admin sees the edit button.
                actions: [
                  if (state.isAdmin && state.community != null)
                    IconButton(
                      tooltip: 'Edit community',
                      icon: const Icon(Icons.edit_rounded,
                          color: CommunityColors.onPrimary),
                      onPressed: state.isUpdating
                          ? null
                          : () => _edit(context, state.community!),
                    ),
                ],
              ),
              if (state.isUpdating) const LinearProgressIndicator(minHeight: 3),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _edit(BuildContext context, CommunityModel community) async {
    final bloc = context.read<CommunityDetailsBloc>();
    final result = await CommunityNavigator.openEdit(context, community);
    if (result == null) return;
    bloc.add(CommunityEdited(
      name: result.name,
      description: result.description,
      newImage: result.newImage,
      removeImage: result.removeImage,
    ));
  }

  Widget _buildBody(BuildContext context, CommunityDetailsState state) {
    switch (state.status) {
      case CommunityDetailsStatus.initial:
      case CommunityDetailsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CommunityDetailsStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              state.errorMessage ?? 'Could not load this community.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: CommunityColors.subtitle),
            ),
          ),
        );

      case CommunityDetailsStatus.success:
        final community = state.community!;
        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _InfoCard(community: community, state: state),
                    TabBar(
                      labelColor: CommunityColors.primary,
                      unselectedLabelColor: CommunityColors.subtitle,
                      indicatorColor: CommunityColors.primary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: [
                        Tab(text: 'Participants (${state.members.length})'),
                        Tab(text: 'Media (${state.visibleMedia.length})'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _ParticipantsTab(community: community, state: state),
                _MediaTab(media: state.visibleMedia),
              ],
            ),
          ),
        );
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.community, required this.state});

  final CommunityModel community;
  final CommunityDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: communityBorder,
        ),
        child: Column(
          children: [
            CommunityAvatar(imageUrl: community.imageUrl, size: 96),
            const SizedBox(height: 14),
            Text(
              community.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CommunityColors.title,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${community.memberCount} members',
              style: const TextStyle(color: CommunityColors.subtitle),
            ),
            if (community.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                community.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CommunityColors.subtitle,
                  height: 1.35,
                ),
              ),
            ],
            const Divider(height: 28, color: CommunityColors.divider),
            if (state.isAdmin)
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeColor: CommunityColors.primary,
                title: const Text(
                  'Participants can send messages',
                  style: TextStyle(
                    color: CommunityColors.title,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  community.participantsCanMessage
                      ? 'Everyone can send messages'
                      : 'Only you (admin) can send messages',
                  style: const TextStyle(color: CommunityColors.subtitle),
                ),
                value: community.participantsCanMessage,
                onChanged: state.isUpdating
                    ? null
                    : (value) => context
                        .read<CommunityDetailsBloc>()
                        .add(CommunityMessagingToggled(value)),
              )
            else
              Row(
                children: [
                  Icon(
                    community.participantsCanMessage
                        ? Icons.chat_bubble_outline_rounded
                        : Icons.lock_outline_rounded,
                    size: 18,
                    color: CommunityColors.subtitle,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      community.participantsCanMessage
                          ? 'Everyone can send messages'
                          : 'Only admin can send messages',
                      style: const TextStyle(color: CommunityColors.subtitle),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsTab extends StatelessWidget {
  const _ParticipantsTab({required this.community, required this.state});

  final CommunityModel community;
  final CommunityDetailsState state;

  Future<void> _addParticipants(BuildContext context) async {
    final bloc = context.read<CommunityDetailsBloc>();
    final ids = await CommunityNavigator.openParticipantPicker(
      context,
      excludeIds: community.participantIds.toSet(),
      title: 'Add participants',
    );
    if (ids != null && ids.isNotEmpty) {
      bloc.add(CommunityParticipantsAdded(ids));
    }
  }

  Future<void> _remove(BuildContext context, CommunityUser user) async {
    final bloc = context.read<CommunityDetailsBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove participant?',
      message: '${user.name} will no longer see this community.',
      confirmLabel: 'Remove',
    );
    if (confirmed) bloc.add(CommunityParticipantRemoved(user.id));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        if (state.isAdmin)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: CommunityColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                leading: const CircleAvatar(
                  backgroundColor: CommunityColors.primary,
                  child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                ),
                title: const Text(
                  'Add participants',
                  style: TextStyle(
                    color: CommunityColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: state.isUpdating ? null : () => _addParticipants(context),
              ),
            ),
          ),
        for (final user in state.members)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: communityBorder,
            ),
            child: ListTile(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              leading:
                  CommunityUserAvatar(name: user.name, photoUrl: user.photoUrl),
              title: Text(
                user.id == state.currentUser?.id ? '${user.name} (You)' : user.name,
                style: const TextStyle(
                  color: CommunityColors.title,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: user.id == community.adminId
                  ? Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CommunityColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          color: CommunityColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : (state.isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.person_remove_alt_1_rounded,
                              color: CommunityColors.danger),
                          onPressed:
                              state.isUpdating ? null : () => _remove(context, user),
                        )
                      : null),
            ),
          ),
      ],
    );
  }
}

class _MediaTab extends StatelessWidget {
  const _MediaTab({required this.media});

  final List<CommunityMessage> media;

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const Center(
        child: Text(
          'No media shared yet',
          style: TextStyle(color: CommunityColors.subtitle),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: media.length,
      itemBuilder: (context, index) {
        final item = media[index];
        return GestureDetector(
          onTap: () => CommunityNavigator.openMedia(context, item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _MediaTile(message: item),
          ),
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.message});

  final CommunityMessage message;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case CommunityMessageType.image:
        return CachedNetworkImage(
          imageUrl: message.mediaUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: CommunityColors.divider),
          errorWidget: (_, __, ___) => Container(
            color: CommunityColors.divider,
            child: const Icon(Icons.broken_image_outlined,
                color: CommunityColors.subtitle),
          ),
        );
      case CommunityMessageType.video:
        return Container(
          color: CommunityColors.title,
          child: const Icon(Icons.play_circle_fill_rounded,
              color: Colors.white, size: 36),
        );
      case CommunityMessageType.audio:
        return Container(
          color: CommunityColors.soft,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack_rounded,
                  color: CommunityColors.primary, size: 30),
              const SizedBox(height: 4),
              Text(
                message.fileName ?? 'Audio',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: CommunityColors.subtitle, fontSize: 11),
              ),
            ],
          ),
        );
      case CommunityMessageType.text:
        return const SizedBox.shrink();
    }
  }
}