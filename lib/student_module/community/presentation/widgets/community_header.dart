import 'package:flutter/material.dart';

import '../community_theme.dart';

/// Flat blue app bar (back arrow + bold white title), matching your other
/// screens. Used on the pushed Community screens (create, details, chat,
/// picker). The Community LIST screen does not use it – it relies on the
/// header you already have.
class CommunityHeader extends StatelessWidget {
  const CommunityHeader({
    super.key,
    this.title = '',
    this.subtitle,
    this.titleWidget,
    this.actions = const [],
    this.onTitleTap,
  });

  final String title;
  final String? subtitle;

  /// Custom left-aligned title (used by the chat screen with the avatar).
  final Widget? titleWidget;
  final List<Widget> actions;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final centered = titleWidget == null;

    return Container(
      color: CommunityColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 8, 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: CommunityColors.onPrimary, size: 26),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: InkWell(
                  onTap: onTitleTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: titleWidget ??
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: CommunityColors.onPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                  ),
                ),
              ),
              // Keep a centered title visually centered next to the back arrow.
              if (centered && actions.isEmpty) const SizedBox(width: 48),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
