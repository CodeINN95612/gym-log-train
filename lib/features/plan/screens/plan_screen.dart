import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/exercise_picker_sheet.dart';
import '../providers/plan_provider.dart';
import 'clone_plan_sheet.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final lang = context.read<SettingsProvider>().language;
    final provider = context.watch<PlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.planTitle(widget.trainee.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all_outlined),
            tooltip: l10n.tooltipClonePlan,
            onPressed: () => showClonePlanSheet(context, widget.trainee),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.planInstruction,
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
                                du.weekdayNameLocalized(i, lang),
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
                                      : l10n.exerciseCount(exercises.length))
                                  : Text(l10n.rest,
                                      style: const TextStyle(
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
                                        label: Text(l10n.addExercise),
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
                                      label: Text(l10n.removeDay),
                                      style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      onPressed: () async {
                                        final confirm = await showConfirmDialog(
                                          context,
                                          title: l10n.removeDay,
                                          content: l10n.removeDayContent(
                                              du.weekdayNameLocalized(i, lang)),
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
