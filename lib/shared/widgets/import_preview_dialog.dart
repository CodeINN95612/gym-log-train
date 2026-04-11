import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';

import '../../core/services/export_import_service.dart';

Future<bool> showImportPreviewDialog(
    BuildContext context, ImportPreview preview) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => _ImportPreviewDialog(preview: preview),
  );
  return result ?? false;
}

class _ImportPreviewDialog extends StatelessWidget {
  final ImportPreview preview;

  const _ImportPreviewDialog({required this.preview});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final traineeNames = preview.traineeNames;
    final showMoreTrainees =
        traineeNames.length > 5 ? traineeNames.length - 5 : 0;
    final visibleTrainees =
        traineeNames.length > 5 ? traineeNames.take(5).toList() : traineeNames;

    final newEx = preview.newExerciseNames;
    final existEx = preview.existingExerciseNames;

    return AlertDialog(
      title: Text(l10n.importPreviewTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.importPreviewTrainees(preview.traineeCount),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...visibleTrainees.map((n) => _BulletItem(n)),
              if (showMoreTrainees > 0)
                _BulletItem(l10n.importPreviewAndMore(showMoreTrainees), muted: true),
              const Divider(height: 24),
              if (newEx.isEmpty && existEx.isEmpty)
                Text(
                  l10n.importPreviewNoExercises,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              if (newEx.isNotEmpty) ...[
                Text(
                  l10n.importPreviewNewExercises(newEx.length),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._limitedBullets(newEx, l10n),
              ],
              if (existEx.isNotEmpty) ...[
                if (newEx.isNotEmpty) const SizedBox(height: 12),
                Text(
                  l10n.importPreviewExistingExercises(existEx.length),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                ..._limitedBullets(existEx, l10n, muted: true),
              ],
              const Divider(height: 24),
              Text(
                l10n.importPreviewWarning,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.importButton),
        ),
      ],
    );
  }

  List<Widget> _limitedBullets(List<String> names, AppLocalizations l10n,
      {bool muted = false}) {
    const max = 10;
    final visible = names.length > max ? names.take(max).toList() : names;
    final overflow = names.length > max ? names.length - max : 0;
    return [
      ...visible.map((n) => _BulletItem(n, muted: muted)),
      if (overflow > 0) _BulletItem(l10n.importPreviewAndMore(overflow), muted: true),
    ];
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool muted;

  const _BulletItem(this.text, {this.muted = false});

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: color)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
