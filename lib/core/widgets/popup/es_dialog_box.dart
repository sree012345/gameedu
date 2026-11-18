/*
 * -----------------------------------------------------------------------------
 * File        : lib\core\widgets\popup\es_dialog_box.dart
 * Description : EsDialogBox - handles core functionality
 * Author      : Revolution Games Private Limited
 * Created On  : 2026-04-24
 * Last Updated: 2026-04-24
 * -----------------------------------------------------------------------------
 * © 2025 Revolution Games Private Limited. All rights reserved.
 * -----------------------------------------------------------------------------
 *
 * Class       : EsDialogBox
 * Purpose     : Manages EsDialogBox operations overall the module
 * -----------------------------------------------------------------------------
 */

import 'package:flutter/material.dart';
import 'package:game_edu/common/theme/app_palette.dart';
import 'package:game_edu/core/widgets/base/card_container.dart';

class EsDialogBox extends StatelessWidget {
  final Widget child;

  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool barrierDismissible;

  const EsDialogBox({
    super.key,
    required this.child,
    this.width,
    this.padding,
    this.barrierDismissible = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Widget child,
    double? width,
    EdgeInsetsGeometry? padding,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => EsDialogBox(
        width: width,
        padding: padding,
        barrierDismissible: barrierDismissible,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPalette.cardSurfaceColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.dividerColor),
      ),
      child: CardContainer(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width ?? 350),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child, // 👈 YOU CONTROL EVERYTHING INSIDE
          ),
        ),
      ),
    );
  }
}
