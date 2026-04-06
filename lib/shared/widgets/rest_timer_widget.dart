import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/sessions/providers/timer_provider.dart';

class RestTimerWidget extends StatelessWidget {
  const RestTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final theme = Theme.of(context);

    final minutes = timer.remaining ~/ 60;
    final seconds = timer.remaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      color: theme.colorScheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Circle timer or idle icon
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: timer.isRunning ? timer.progress : 1.0,
                    strokeWidth: 5,
                    backgroundColor:
                        theme.colorScheme.onPrimaryContainer.withAlpha(30),
                    color: timer.isRunning
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onPrimaryContainer.withAlpha(80),
                  ),
                  timer.isRunning
                      ? Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : Icon(
                          Icons.timer_outlined,
                          color: theme.colorScheme.onPrimaryContainer
                              .withAlpha(160),
                          size: 24,
                        ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timer.isRunning ? 'Resting…' : 'Rest Timer',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Preset chips
                  Row(
                    children: [
                      _presetChip(context, timer, 60, '60s'),
                      const SizedBox(width: 4),
                      _presetChip(context, timer, 90, '90s'),
                      const SizedBox(width: 4),
                      _presetChip(context, timer, 120, '2m'),
                      const SizedBox(width: 4),
                      _presetChip(context, timer, 180, '3m'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action buttons column
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!timer.isRunning)
                  FilledButton(
                    onPressed: () => context.read<TimerProvider>().start(),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.onPrimaryContainer,
                      foregroundColor: theme.colorScheme.primaryContainer,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Start', style: TextStyle(fontSize: 13)),
                  )
                else ...[
                  TextButton(
                    onPressed: () =>
                        context.read<TimerProvider>().addThirty(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('+30s',
                        style: TextStyle(fontSize: 12)),
                  ),
                  TextButton(
                    onPressed: () => context.read<TimerProvider>().skip(),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Skip',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip(
      BuildContext context, TimerProvider timer, int seconds, String label) {
    final isSelected = timer.preset == seconds;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.read<TimerProvider>().setPreset(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onPrimaryContainer.withAlpha(35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
