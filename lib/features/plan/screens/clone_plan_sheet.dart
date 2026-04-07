import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/trainee.dart';
import '../../../core/repositories/plan_repository.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../features/trainees/providers/trainee_provider.dart';
import '../providers/plan_provider.dart';

Future<void> showClonePlanSheet(BuildContext context, Trainee currentTrainee) {
  final planProvider = context.read<PlanProvider>();
  final traineeProvider = context.read<TraineeProvider>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: planProvider),
        ChangeNotifierProvider.value(value: traineeProvider),
      ],
      child: _ClonePlanSheet(currentTrainee: currentTrainee),
    ),
  );
}

class _ClonePlanSheet extends StatefulWidget {
  final Trainee currentTrainee;
  const _ClonePlanSheet({required this.currentTrainee});

  @override
  State<_ClonePlanSheet> createState() => _ClonePlanSheetState();
}

class _ClonePlanSheetState extends State<_ClonePlanSheet> {
  Map<int, List<Map<String, int>>>? _summaries;
  bool _cloning = false;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    final db = await DatabaseHelper.instance.database;
    final repo = PlanRepository(db);
    final summaries = await repo.getPlanSummariesAll();
    if (mounted) setState(() => _summaries = summaries);
  }

  String _formatSummary(List<Map<String, int>> days) {
    if (days.isEmpty) return 'No plan configured';
    final totalExercises = days.fold(0, (sum, d) => sum + d['count']!);
    final dayNames = days.map((d) => du.weekdayName(d['weekday']!)).join(', ');
    return '$dayNames · $totalExercises exercise${totalExercises == 1 ? '' : 's'}';
  }

  Future<void> _clone(Trainee source) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clone plan?'),
        content: Text(
          'This will replace ${widget.currentTrainee.name}\'s entire plan with ${source.name}\'s plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clone'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _cloning = true);
    await context.read<PlanProvider>().cloneFrom(source.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trainees = context
        .watch<TraineeProvider>()
        .trainees
        .where((t) => t.id != widget.currentTrainee.id)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              'Clone plan from…',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Replaces ${widget.currentTrainee.name}\'s current plan.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const Divider(height: 1),
          if (_cloning)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (trainees.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No other trainees found.')),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: trainees.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final trainee = trainees[i];
                  final days = _summaries?[trainee.id] ?? [];
                  final hasplan = _summaries != null && days.isNotEmpty;

                  return ListTile(
                    title: Text(trainee.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: _summaries == null
                        ? const Text('Loading…')
                        : Text(
                            _formatSummary(days),
                            style: TextStyle(
                              color: hasplan
                                  ? null
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontStyle: hasplan
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                    trailing: hasplan
                        ? const Icon(Icons.arrow_forward_ios, size: 16)
                        : null,
                    enabled: hasplan,
                    onTap: hasplan ? () => _clone(trainee) : null,
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
