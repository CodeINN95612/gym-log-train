import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/exercise_log_block.dart';
import '../../../shared/widgets/exercise_picker_sheet.dart';
import '../../../shared/widgets/rest_timer_widget.dart';
import '../providers/session_provider.dart';
import '../providers/timer_provider.dart';

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
    return ChangeNotifierProvider(
      create: (_) => TimerProvider(),
      child: _SessionDetailBody(sessionId: sessionId, trainee: trainee),
    );
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
            Text(session != null ? 'Session ${session.date}' : 'Session'),
            if (session != null)
              Text(
                isInProgress ? '● In Progress' : '✓ Completed',
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
              tooltip: 'Delete session',
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: 'Delete Session',
                  content:
                      'Delete this session and all its logged sets? This cannot be undone.',
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
                if (isInProgress) const RestTimerWidget(),
                Expanded(
                  child: ListView(
                    children: [
                      if (sessionProvider.sessionExercises.isEmpty && !sessionProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No exercises added yet.\nTap "Add Exercise" to start.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
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
                        label: const Text('Add Exercise'),
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
                        label: const Text('End Session'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          final confirm = await showConfirmDialog(
                            context,
                            title: 'End Session',
                            content: 'Mark this session as completed?',
                            confirmLabel: 'End Session',
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
