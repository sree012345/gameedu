import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/community_message.dart';
import '../community_formatters.dart';
import '../community_theme.dart';
import 'audio_message_player.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.onLongPress,
    this.onOpenMedia,
  });

  final CommunityMessage message;
  final bool isMine;

  /// Null when the current user may not delete this message.
  final VoidCallback? onLongPress;
  final VoidCallback? onOpenMedia;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    final textColor = isMine ? Colors.white : CommunityColors.title;
    final mutedColor = isMine ? const Color(0xB3FFFFFF) : CommunityColors.subtitle;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: isMine ? CommunityColors.primary : CommunityColors.soft,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMine ? 18 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 18),
            ),
            border: isMine ? null : communityBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        message.senderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CommunityColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (message.senderIsAdmin) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: CommunityColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: CommunityColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              _buildContent(textColor, mutedColor),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  CommunityFormatters.bubbleTime(message.createdAt),
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor, Color mutedColor) {
    if (message.isDeleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block_rounded, size: 15, color: mutedColor),
          const SizedBox(width: 6),
          Text(
            'This message was deleted',
            style: TextStyle(
              color: mutedColor,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    switch (message.type) {
      case CommunityMessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
        );

      case CommunityMessageType.image:
        return GestureDetector(
          onTap: onOpenMedia,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: message.mediaUrl ?? '',
              width: 220,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 220,
                height: 220,
                color: CommunityColors.soft,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 220,
                height: 220,
                color: CommunityColors.soft,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined,
                    color: CommunityColors.subtitle),
              ),
            ),
          ),
        );

      case CommunityMessageType.video:
        return GestureDetector(
          onTap: onOpenMedia,
          child: Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              color: CommunityColors.title,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.play_circle_fill_rounded,
                color: Colors.white, size: 52),
          ),
        );

      case CommunityMessageType.audio:
        return SizedBox(
          width: 220,
          child: AudioMessagePlayer(
            url: message.mediaUrl ?? '',
            color: isMine ? Colors.white : CommunityColors.primary,
          ),
        );
    }
  }
}
