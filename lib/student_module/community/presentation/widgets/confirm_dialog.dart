import 'package:flutter/material.dart';

import '../community_theme.dart';

/// Confirmation popup (used before deleting a message / removing a
/// participant). Resolves to `true` only when the user confirms.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        title,
        style: const TextStyle(
          color: CommunityColors.title,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(color: CommunityColors.subtitle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: CommunityColors.danger),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
