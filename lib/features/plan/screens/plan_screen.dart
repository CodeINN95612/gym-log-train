import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/exercise_picker_sheet.dart';
import '../providers/plan_provider.dart';

class PlanScreen extends StatefulWidget {
  final Trainee trainee;

  const PlanScreen({super.key, required this.trainee});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trainee.name}\'s Plan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Tap an inactive day to enable it. Tap an active day to expand/collapse.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: 7,
                    itemBuilder: (_, i) {
                      final day = provider.planDayForWeekday(i);
                      final isActive = day != null;
                      final exercises =
                          isActive ? provider.exercisesForDay(day.id!) : [];
                      final isExpanded = isActive && _expanded.contains(day.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () async {
                                if (!isActive) {
                                  final newDay = await provider.addDay(i);
                                  if (newDay?.id != null) {
                                    setState(() => _expanded.add(newDay!.id!));
                                  }
                                } else {
                                  setState(() {
                                    if (_expanded.contains(day.id)) {
                                      _expanded.remove(day.id);
                                    } else {
                                      _expanded.add(day.id!);
                                    }
                                  });
                                }
                              },
                              leading: Text(
                                du.weekdayName(i),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                ),
                              ),
                              title: isActive
                                  ? Text(day.label?.isNotEmpty == true
                                      ? day.label!
                                      : '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}')
                                  : const Text('Rest',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic)),
                              trailing: isActive
                                  ? Icon(isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more)
                                  : const Icon(Icons.add, color: Colors.grey),
                            ),
                            if (isExpanded && isActive) ...[
                              const Divider(height: 1),
                              ...exercises.map((pde) => ListTile(
                                    dense: true,
                                    title: Text(pde.exercise?.name ?? ''),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle_outline,
                                          size: 20),
                                      onPressed: () => provider.removeExercise(
                                          pde.id!, day.id!),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Add Exercise'),
                                        onPressed: () async {
                                          final ex =
                                              await showExercisePickerSheet(
                                                  context);
                                          if (ex != null && context.mounted) {
                                            provider.addExercise(
                                                day.id!, ex.id!);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 16),
                                      label: const Text('Remove Day'),
                                      style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      onPressed: () async {
                                        final confirm = await showConfirmDialog(
                                          context,
                                          title: 'Remove Day',
                                          content:
                                              'Remove ${du.weekdayName(i)} from the plan?',
                                        );
                                        if (confirm && context.mounted) {
                                          setState(() =>
                                              _expanded.remove(day.id));
                                          provider.removeDay(day.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
