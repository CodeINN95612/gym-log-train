import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../plan/providers/plan_provider.dart';
import '../../plan/screens/plan_screen.dart';
import '../../sessions/providers/session_provider.dart';
import '../../sessions/screens/new_session_screen.dart';
import '../../sessions/screens/session_detail_screen.dart';
import '../../sessions/screens/session_history_screen.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/screens/progress_screen.dart';
import '../providers/trainee_provider.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../core/services/export_import_service.dart';
import '../../../shared/widgets/import_preview_dialog.dart';

class TraineeOverviewScreen extends StatelessWidget {
  final Trainee trainee;

  const TraineeOverviewScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlanProvider(trainee.id!)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(trainee.id!)..loadSessions(),
        ),
      ],
      child: _TraineeOverviewBody(trainee: trainee),
    );
  }
}

class _TraineeOverviewBody extends StatelessWidget {
  final Trainee trainee;

  const _TraineeOverviewBody({required this.trainee});

  Future<void> _handleExport(BuildContext context) async {
    try {
      await ExportImportService().exportTrainee(trainee.id!);
    } on ExportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Export failed: ${e.message}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    ImportPreview? preview;
    try {
      preview = await ExportImportService().pickAndPreviewImport();
    } on ImportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not read file: ${e.message}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    if (preview == null || !context.mounted) return;

    final confirmed = await showImportPreviewDialog(context, preview);
    if (!confirmed || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Importing…'),
        ]),
      ),
    );

    ImportResult result;
    try {
      result = await ExportImportService().executeImport(preview);
    } on ImportException catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Import failed: ${e.message}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      final exMsg = result.exercisesCreated > 0
          ? ', created ${result.exercisesCreated} exercise(s)'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Imported ${result.traineesImported} trainee(s)$exMsg.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = context.watch<PlanProvider>();
    final sessionProvider = context.watch<SessionProvider>();

    final recentSessions = sessionProvider.sessions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(trainee.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export trainee',
            onPressed: () => _handleExport(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import trainee',
            onPressed: () => _handleImport(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete trainee',
            onPressed: () async {
              final confirm = await showConfirmDialog(
                context,
                title: 'Delete Trainee',
                content:
                    'Delete "${trainee.name}" and all their sessions and plan data? This cannot be undone.',
                confirmLabel: 'Delete',
              );
              if (confirm && context.mounted) {
                await context
                    .read<TraineeProvider>()
                    .deleteTrainee(trainee.id!);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (trainee.notes?.isNotEmpty == true) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(trainee.notes!),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Session'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<SessionProvider>(),
                        child: NewSessionScreen(trainee: trainee),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Progress'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) =>
                            ProgressProvider(trainee.id!)..load(),
                        child: ProgressScreen(trainee: trainee),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Weekly plan summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Plan',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<PlanProvider>(),
                      child: PlanScreen(trainee: trainee),
                    ),
                  ),
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
          planProvider.isLoading
              ? const LinearProgressIndicator()
              : _WeeklyPlanSummary(planProvider: planProvider),

          const SizedBox(height: 24),

          // Recent sessions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Sessions',
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<SessionProvider>(),
                      child: SessionHistoryScreen(trainee: trainee),
                    ),
                  ),
                ),
                child: const Text('See All'),
              ),
            ],
          ),
          if (sessionProvider.isLoading)
            const LinearProgressIndicator()
          else if (recentSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No sessions yet.', style: TextStyle(color: Colors.grey)),
            )
          else
            ...recentSessions.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.date),
                  subtitle: Text(s.isInProgress ? 'In Progress' : 'Completed'),
                  trailing: s.isInProgress
                      ? const Chip(
                          label: Text('Active',
                              style: TextStyle(fontSize: 11)),
                          backgroundColor: Colors.orange,
                          labelStyle: TextStyle(color: Colors.white),
                          visualDensity: VisualDensity.compact,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(
                            value: context.read<SessionProvider>(),
                          ),
                        ],
                        child: SessionDetailScreen(
                          sessionId: s.id!,
                          trainee: trainee,
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

class _WeeklyPlanSummary extends StatelessWidget {
  final PlanProvider planProvider;

  const _WeeklyPlanSummary({required this.planProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(7, (i) {
        final day = planProvider.planDayForWeekday(i);
        final exercises = day != null ? planProvider.exercisesForDay(day.id!) : [];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: SizedBox(
            width: 40,
            child: Text(
              du.weekdayShort(i),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: day != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ),
          title: Text(
            day != null
                ? (day.label?.isNotEmpty == true
                    ? day.label!
                    : '${exercises.length} exercise${exercises.length == 1 ? '' : 's'}')
                : 'Rest',
            style: TextStyle(
              color: day != null ? null : Colors.grey,
              fontStyle: day != null ? null : FontStyle.italic,
            ),
          ),
        );
      }),
    );
  }
}
