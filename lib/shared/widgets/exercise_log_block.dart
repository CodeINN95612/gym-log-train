import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/session_exercise.dart';
import '../../core/models/set_entry.dart';
import '../../core/utils/weight_utils.dart';
import '../../features/sessions/providers/session_provider.dart';
import 'category_badge.dart' show ExerciseBadges;
import 'confirm_dialog.dart';
import 'set_row_widget.dart';

class ExerciseLogBlock extends StatefulWidget {
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
  State<ExerciseLogBlock> createState() => _ExerciseLogBlockState();
}

class _ExerciseLogBlockState extends State<ExerciseLogBlock> {
  WeightUnit _unit = WeightUnit.kg;

  @override
  Widget build(BuildContext context) {
    final ex = widget.sessionExercise.exercise;
    final bool showWeight;
    final bool showReps;
    final bool showDuration;
    if (!widget.readOnly) {
      showWeight = true;
      showReps = true;
      showDuration = true;
    } else {
      showWeight = widget.sets.any((s) => s.weightKg != null);
      showReps = widget.sets.any((s) => s.reps != null);
      showDuration = widget.sets.any((s) => s.durationSeconds != null);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name + delete button
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
                if (!widget.readOnly)
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
                              widget.sessionExercise.id!,
                              widget.sessionId,
                            );
                      }
                    },
                  ),
              ],
            ),
            if (widget.sets.isNotEmpty || !widget.readOnly) ...[
              const SizedBox(height: 8),
              // Column headers
              Row(
                children: [
                  const SizedBox(width: 28),
                  if (showWeight) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _UnitToggle(
                        unit: _unit,
                        onToggle: (u) => setState(() => _unit = u),
                      ),
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
                  if (!widget.readOnly) const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 4),
              ...widget.sets.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SetRowWidget(
                      set: s,
                      readOnly: widget.readOnly,
                      weightUnit: _unit,
                      showWeight: showWeight,
                      showReps: showReps,
                      showDuration: showDuration,
                    ),
                  )),
            ],
            if (!widget.readOnly) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Set'),
                  onPressed: () async {
                    await context
                        .read<SessionProvider>()
                        .addSet(widget.sessionExercise.id!);
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

/// Inline kg / lbs toggle shown in the weight column header.
class _UnitToggle extends StatelessWidget {
  final WeightUnit unit;
  final ValueChanged<WeightUnit> onToggle;

  const _UnitToggle({required this.unit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _label('kg', WeightUnit.kg, primary),
        const Text(' · ',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        _label('lbs', WeightUnit.lbs, primary),
      ],
    );
  }

  Widget _label(String text, WeightUnit value, Color primary) {
    final active = unit == value;
    return GestureDetector(
      onTap: active ? null : () => onToggle(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
