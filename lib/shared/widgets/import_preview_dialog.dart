import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final traineeNames = preview.traineeNames;
    final showMoreTrainees =
        traineeNames.length > 5 ? traineeNames.length - 5 : 0;
    final visibleTrainees =
        traineeNames.length > 5 ? traineeNames.take(5).toList() : traineeNames;

    final newEx = preview.newExerciseNames;
    final existEx = preview.existingExerciseNames;

    return AlertDialog(
      title: const Text('Import Preview'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${preview.traineeCount} trainee${preview.traineeCount == 1 ? '' : 's'} will be imported:',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...visibleTrainees.map((n) => _BulletItem(n)),
              if (showMoreTrainees > 0)
                _BulletItem(
                  'and $showMoreTrainees more…',
                  muted: true,
                ),
              const Divider(height: 24),
              if (newEx.isEmpty && existEx.isEmpty)
                Text(
                  'No exercises referenced.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              if (newEx.isNotEmpty) ...[
                Text(
                  '${newEx.length} new exercise${newEx.length == 1 ? '' : 's'} will be created:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ..._limitedBullets(newEx, theme),
              ],
              if (existEx.isNotEmpty) ...[
                if (newEx.isNotEmpty) const SizedBox(height: 12),
                Text(
                  '${existEx.length} exercise${existEx.length == 1 ? '' : 's'} already exist and will be reused:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                ..._limitedBullets(existEx, theme, muted: true),
              ],
              const Divider(height: 24),
              Text(
                'This cannot be undone.',
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Import'),
        ),
      ],
    );
  }

  List<Widget> _limitedBullets(List<String> names, ThemeData theme,
      {bool muted = false}) {
    const max = 10;
    final visible = names.length > max ? names.take(max).toList() : names;
    final overflow = names.length > max ? names.length - max : 0;
    return [
      ...visible.map((n) => _BulletItem(n, muted: muted)),
      if (overflow > 0) _BulletItem('and $overflow more…', muted: true),
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
