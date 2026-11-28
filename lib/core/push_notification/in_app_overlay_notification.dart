import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';

class InAppOverlayNotification {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String title,
    required String body,
    required VoidCallback onOpen,
  }) {
    debugPrint('🔔 [Overlay] show() called: $title / $body');

    // Replace any banner already on screen (instead of ignoring the new one).
    hide();

    OverlayState? overlay;
    try {
      overlay = Navigator.of(context, rootNavigator: true).overlay;
    } catch (e) {
      debugPrint('🔔 [Overlay] ERROR finding navigator: $e');
    }

    if (overlay == null) {
      debugPrint('🔔 [Overlay] ❌ overlay is null, cannot show');
      return;
    }

    _entry = OverlayEntry(
      builder: (_) => _OverlayBanner(
        title: title,
        body: body,
        onOpen: onOpen,
        onDismiss: hide,
      ),
    );

    overlay.insert(_entry!);
    debugPrint('🔔 [Overlay] ✅ inserted');

    _timer = Timer(const Duration(seconds: 10), hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;

    try {
      _entry?.remove();
    } catch (e) {
      debugPrint('🔔 [Overlay] remove error (ignored): $e');
    }
    _entry = null;
  }
}

class _OverlayBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  const _OverlayBanner({
    required this.title,
    required this.body,
    required this.onOpen,
    required this.onDismiss,
  });

  @override
  State<_OverlayBanner> createState() => _OverlayBannerState();
}

class _OverlayBannerState extends State<_OverlayBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          const minVelocity = 300;

          if (velocity.dx.abs() > minVelocity ||
              velocity.dy.abs() > minVelocity) {
            widget.onDismiss();
          }
        },
        child: SlideTransition(
          position: _offset,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(14),
            color: AppPalette.cardSurfaceColor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppPalette.inputBorderColor,
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  widget.onDismiss();
                  widget.onOpen();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textPrimaryColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppPalette.textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onDismiss();
                          widget.onOpen();
                        },
                        child: const Text(
                          'OPEN',
                          style: TextStyle(color: AppPalette.primaryAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}