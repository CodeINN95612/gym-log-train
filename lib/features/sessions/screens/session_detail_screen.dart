import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/exercise_log_block.dart';
import '../../../shared/widgets/exercise_picker_sheet.dart';
import '../providers/session_provider.dart';

class SessionDetailScreen extends StatelessWidget {
  final int sessionId;
  final Trainee trainee;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.trainee,
  });

  @override
  Widget build(BuildContext context) {
    return _SessionDetailBody(sessionId: sessionId, trainee: trainee);
  }
}

class _SessionDetailBody extends StatefulWidget {
  final int sessionId;
  final Trainee trainee;

  const _SessionDetailBody(
      {required this.sessionId, required this.trainee});

  @override
  State<_SessionDetailBody> createState() => _SessionDetailBodyState();
}

class _SessionDetailBodyState extends State<_SessionDetailBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SessionProvider>()
          .loadSessionDetail(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionProvider = context.watch<SessionProvider>();
    final session = sessionProvider.activeSession;
    final isInProgress = session?.isInProgress ?? false;
    final canDelete =
        session != null && sessionProvider.canDelete(session);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session != null
                ? l10n.sessionTitle(session.date)
                : l10n.sessionTitleGeneric),
            if (session != null)
              Text(
                isInProgress ? l10n.sessionInProgress : l10n.sessionCompleted,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isInProgress ? Colors.orange : Colors.green,
                ),
              ),
          ],
        ),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.tooltipDeleteSession,
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: l10n.deleteSessionTitle,
                  content: l10n.deleteSessionContent,
                );
                if (confirm && context.mounted) {
                  await context
                      .read<SessionProvider>()
                      .deleteSession(widget.sessionId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: sessionProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      if (sessionProvider.sessionExercises.isEmpty &&
                          !sessionProvider.isLoading)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              l10n.noExercisesInSession,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ...sessionProvider.sessionExercises.map((se) {
                        final sets =
                            sessionProvider.setsByExerciseId[se.id!] ?? [];
                        return ExerciseLogBlock(
                          sessionExercise: se,
                          sets: sets,
                          readOnly: !isInProgress,
                          sessionId: widget.sessionId,
                        );
                      }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isInProgress
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addExercise),
                        onPressed: () async {
                          final ex =
                              await showExercisePickerSheet(context);
                          if (ex != null && context.mounted) {
                            context
                                .read<SessionProvider>()
                                .addExerciseToSession(
                                    widget.sessionId, ex.id!);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: Text(l10n.endSession),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await showConfirmDialog(
                            context,
                            title: l10n.endSession,
                            content: l10n.endSessionContent,
                            confirmLabel: l10n.endSession,
                            confirmColor:
                                Theme.of(context).colorScheme.primary,
                          );
                          if (confirm && context.mounted) {
                            context
                                .read<SessionProvider>()
                                .endSession(widget.sessionId);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
