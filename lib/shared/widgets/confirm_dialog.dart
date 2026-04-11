import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? confirmLabel,
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx)!;
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Theme.of(ctx).colorScheme.error,
            ),
            child: Text(confirmLabel ?? l10n.delete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
