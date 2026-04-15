import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/session_exercise.dart';
import '../../core/models/set_entry.dart';
import '../../features/sessions/providers/session_provider.dart';
import 'category_badge.dart' show ExerciseBadges;
import 'confirm_dialog.dart';
import 'set_row_widget.dart';

class ExerciseLogBlock extends StatelessWidget {
  final SessionExercise sessionExercise;
  final List<SetEntry> sets;
  final bool readOnly;
  final int sessionId;

  const ExerciseLogBlock({
    super.key,
    required this.sessionExercise,
    required this.sets,
    required this.readOnly,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final ex = sessionExercise.exercise;
    // When editing: always show all three columns so any metric can be filled in.
    // When read-only (completed session): only show columns that have actual data.
    final bool showWeight;
    final bool showReps;
    final bool showDuration;
    if (!readOnly) {
      showWeight = true;
      showReps = true;
      showDuration = true;
    } else {
      showWeight = sets.any((s) => s.weightKg != null);
      showReps = sets.any((s) => s.reps != null);
      showDuration = sets.any((s) => s.durationSeconds != null);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ex?.name ?? 'Exercise',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (ex?.category != null || ex?.muscleFocus != null) ...[
                        const SizedBox(height: 4),
                        ExerciseBadges(
                          category: ex?.category,
                          muscleFocus: ex?.muscleFocus,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!readOnly)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove exercise',
                    onPressed: () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: 'Remove Exercise',
                        content:
                            'Remove "${ex?.name ?? 'this exercise'}" and all its sets?',
                      );
                      if (confirm && context.mounted) {
                        context.read<SessionProvider>().deleteSessionExercise(
                              sessionExercise.id!,
                              sessionId,
                            );
                      }
                    },
                  ),
              ],
            ),
            if (sets.isNotEmpty || !readOnly) ...[
              const SizedBox(height: 8),
              // Column headers
              Row(
                children: [
                  const SizedBox(width: 28),
                  if (showWeight) ...[
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('wt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                  if (showReps) ...[
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('reps',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                  if (showDuration) ...[
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('sec',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ],
                  if (!readOnly) const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 4),
              ...sets.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SetRowWidget(
                      set: s,
                      readOnly: readOnly,
                      showWeight: showWeight,
                      showReps: showReps,
                      showDuration: showDuration,
                    ),
                  )),
            ],
            if (!readOnly) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Set'),
                  onPressed: () async {
                    await context
                        .read<SessionProvider>()
                        .addSet(sessionExercise.id!);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
