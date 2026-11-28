import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_edu/init_dependencies.dart';

import '../../bloc/community_chat/community_chat_bloc.dart';
import '../../data/models/community_message.dart';
import '../../data/models/community_model.dart';
import '../community_formatters.dart';
import '../community_navigator.dart';
import '../community_theme.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/community_avatar.dart';
import '../widgets/community_header.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/message_bubble.dart';

class CommunityChatScreen extends StatelessWidget {
  const CommunityChatScreen({
    super.key,
    required this.communityId,
  });

  final String communityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CommunityChatBloc>()..add(CommunityChatStarted(communityId)),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityChatBloc, CommunityChatState>(
      listenWhen: (previous, current) =>
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          (current.infoMessage != null &&
              previous.infoMessage != current.infoMessage) ||
          (current.hasLeft && !previous.hasLeft),
      listener: (context, state) {
        final text = state.errorMessage ?? state.infoMessage;
        if (text != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        }
        // Left the community: close the chat and go back to the list.
        if (state.hasLeft) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final community = state.community;
        return Scaffold(
          backgroundColor: CommunityColors.background,
          body: Column(
            children: [
              CommunityHeader(
                actions: [
                  if (community != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: CommunityColors.onPrimary),
                      onSelected: (value) => _onMenu(context, value, state),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'info', child: Text('Community info')),
                        const PopupMenuItem(value: 'clear', child: Text('Clear chat')),
                        if (!state.isAdmin)
                          const PopupMenuItem(
                            value: 'leave',
                            child: Text('Leave community',
                                style: TextStyle(color: CommunityColors.danger)),
                          ),
                      ],
                    ),
                ],
                onTitleTap: community == null
                    ? null
                    : () => CommunityNavigator.openDetails(context, community.id),
                titleWidget: Row(
                  children: [
                    CommunityAvatar(imageUrl: community?.imageUrl, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community?.name ?? 'Community',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            community == null
                                ? ''
                                : '${community.memberCount} members · tap for info',
                            style: const TextStyle(
                                color: Color(0xCCFFFFFF), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(context, state)),
              if (state.isSending) const LinearProgressIndicator(minHeight: 3),
              if (state.status == CommunityChatStatus.success) _buildFooter(context, state),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(
    BuildContext context,
    String value,
    CommunityChatState state,
  ) async {
    final bloc = context.read<CommunityChatBloc>();
    final community = state.community;
    if (community == null) return;

    switch (value) {
      case 'info':
        CommunityNavigator.openDetails(context, community.id);
      case 'clear':
        final clear = await showConfirmDialog(
          context,
          title: 'Clear chat?',
          message: 'All messages will be removed from your chat. '
              'Other members will still see them.',
          confirmLabel: 'Clear',
        );
        if (clear) bloc.add(const CommunityChatCleared());
      case 'leave':
        final leave = await showConfirmDialog(
          context,
          title: 'Leave community?',
          message: 'You will no longer receive messages from '
              '"${community.name}". The admin can add you again.',
          confirmLabel: 'Leave',
        );
        if (leave) bloc.add(const CommunityChatLeft());
    }
  }

  Widget _buildFooter(BuildContext context, CommunityChatState state) {
    if (!state.canSend) {
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: CommunityColors.border)),
        ),
        child: const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: CommunityColors.subtitle),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Only admin can send messages',
                    style: TextStyle(color: CommunityColors.subtitle),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bloc = context.read<CommunityChatBloc>();
    return ChatInputBar(
      enabled: !state.isSending,
      onSendText: (text) => bloc.add(CommunityChatTextSent(text)),
      onSendMedia: (CommunityMessageType type, File file) =>
          bloc.add(CommunityChatMediaSent(type: type, file: file)),
    );
  }

  Widget _buildBody(BuildContext context, CommunityChatState state) {
    switch (state.status) {
      case CommunityChatStatus.initial:
      case CommunityChatStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case CommunityChatStatus.failure:
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

      case CommunityChatStatus.success:
        if (!state.messagesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.visibleMessages.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.community != null) _CommunityInfoCard(community: state.community!),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  state.canSend ? 'Send the first message' : 'No messages yet',
                  style: const TextStyle(color: CommunityColors.subtitle),
                ),
              ),
            ],
          );
        }
        return _MessageList(state: state);
    }
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state});

  final CommunityChatState state;

  Future<void> _confirmDelete(BuildContext context, CommunityMessage message) async {
    final bloc = context.read<CommunityChatBloc>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete message?',
      message: 'This message will be deleted for everyone in this community.',
    );
    if (confirmed) bloc.add(CommunityChatMessageDeleted(message));
  }

  @override
  Widget build(BuildContext context) {
    final messages = state.visibleMessages;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          context.read<CommunityChatBloc>().add(const CommunityChatLoadMore());
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: messages.length + 1,
        itemBuilder: (context, index) {
          if (index >= messages.length) {
            // Very top of the chat: loader while paging, or the community info.
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (state.hasReachedMax && state.community != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CommunityInfoCard(community: state.community!),
              );
            }
            return const SizedBox.shrink();
          }

          final message = messages[index];
          final older = index + 1 < messages.length ? messages[index + 1] : null;
          final showDate = older == null ||
              !CommunityFormatters.isSameDay(older.createdAt, message.createdAt);

          return Column(
            children: [
              if (showDate) _DateChip(time: message.createdAt),
              MessageBubble(
                message: message,
                isMine: state.isMine(message),
                onLongPress: state.canDelete(message)
                    ? () => _confirmDelete(context, message)
                    : null,
                onOpenMedia: message.type.isMedia && !message.isDeleted
                    ? () => CommunityNavigator.openMedia(context, message)
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Community name + description, shown at the top of the chat.
class _CommunityInfoCard extends StatelessWidget {
  const _CommunityInfoCard({required this.community});

  final CommunityModel community;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CommunityColors.soft,
        borderRadius: BorderRadius.circular(16),
        border: communityBorder,
      ),
      child: Column(
        children: [
          CommunityAvatar(imageUrl: community.imageUrl, size: 64),
          const SizedBox(height: 10),
          Text(
            community.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CommunityColors.title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (community.description.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              community.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CommunityColors.subtitle,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${community.memberCount} members',
            style: const TextStyle(color: CommunityColors.hint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.time});

  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: CommunityColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          CommunityFormatters.dayHeader(time),
          style: const TextStyle(
            color: CommunityColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}