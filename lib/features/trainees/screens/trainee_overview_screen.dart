import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/providers/settings_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    try {
      await ExportImportService().exportTrainee(trainee.id!);
    } on ExportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.exportFailed(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    ImportPreview? preview;
    try {
      preview = await ExportImportService().pickAndPreviewImport();
    } on ImportException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.couldNotReadFile(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
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
      builder: (_) => AlertDialog(
        content: Row(children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text(l10n.importing),
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
        content: Text(l10n.importFailed(e.message)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.unexpectedError(e.toString())),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }

    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      final exMsg = result.exercisesCreated > 0
          ? l10n.importCreatedExercises(result.exercisesCreated)
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importSuccess(result.traineesImported, exMsg))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = context.read<SettingsProvider>().language;
    final planProvider = context.watch<PlanProvider>();
    final sessionProvider = context.watch<SessionProvider>();

    final recentSessions = sessionProvider.sessions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(trainee.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.tooltipExportTrainee,
            onPressed: () => _handleExport(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: l10n.tooltipImportTrainee,
            onPressed: () => _handleImport(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.tooltipDeleteTrainee,
            onPressed: () async {
              final confirm = await showConfirmDialog(
                context,
                title: l10n.deleteTraineeTitle,
                content: l10n.deleteTraineeContent(trainee.name),
                confirmLabel: l10n.delete,
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
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.startSession),
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
                  label: Text(l10n.progress),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.weeklyPlan,
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
                child: Text(l10n.edit),
              ),
            ],
          ),
          planProvider.isLoading
              ? const LinearProgressIndicator()
              : _WeeklyPlanSummary(planProvider: planProvider, lang: lang),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.recentSessions,
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
                child: Text(l10n.seeAll),
              ),
            ],
          ),
          if (sessionProvider.isLoading)
            const LinearProgressIndicator()
          else if (recentSessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noSessionsYet,
                  style: const TextStyle(color: Colors.grey)),
            )
          else
            ...recentSessions.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.date),
                  subtitle: Text(s.isInProgress ? l10n.inProgress : l10n.completed),
                  trailing: s.isInProgress
                      ? Chip(
                          label: Text(l10n.active,
                              style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.orange,
                          labelStyle: const TextStyle(color: Colors.white),
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
  final String lang;

  const _WeeklyPlanSummary({required this.planProvider, required this.lang});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              du.weekdayShortLocalized(i, lang),
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
                    : l10n.exerciseCount(exercises.length))
                : l10n.rest,
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
