import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../plan/providers/plan_provider.dart';
import '../providers/session_provider.dart';
import 'session_detail_screen.dart';

class NewSessionScreen extends StatelessWidget {
  final Trainee trainee;

  const NewSessionScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekdayIndex = du.dartWeekdayToIndex(today);
    final lang = context.read<SettingsProvider>().language;
    final weekdayLabel = du.weekdayNameLocalized(weekdayIndex, lang);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PlanProvider(trainee.id!)..load(),
        ),
      ],
      child: _NewSessionBody(
        trainee: trainee,
        weekdayIndex: weekdayIndex,
        weekdayLabel: weekdayLabel,
      ),
    );
  }
}

class _NewSessionBody extends StatelessWidget {
  final Trainee trainee;
  final int weekdayIndex;
  final String weekdayLabel;

  const _NewSessionBody({
    required this.trainee,
    required this.weekdayIndex,
    required this.weekdayLabel,
  });

  Future<void> _startSession(BuildContext context, int? planDayId) async {
    final sessionProvider = context.read<SessionProvider>();
    final sessionId = await sessionProvider.startSession(planDayId: planDayId);
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: sessionProvider,
          child: SessionDetailScreen(
            sessionId: sessionId,
            trainee: trainee,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final planProvider = context.watch<PlanProvider>();
    final planDay = planProvider.planDayForWeekday(weekdayIndex);
    final planExercises =
        planDay != null ? planProvider.exercisesForDay(planDay.id!) : [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newSessionTitle(weekdayLabel))),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (planDay != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.todaysPlan,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            planDay.label?.isNotEmpty == true
                                ? planDay.label!
                                : l10n.exerciseCount(planExercises.length),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              icon: const Icon(Icons.playlist_play),
                              label: Text(l10n.useTodaysPlan),
                              onPressed: () =>
                                  _startSession(context, planDay.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adHocSession,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.adHocDescription,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: Text(l10n.startBlankSession),
                            onPressed: () => _startSession(context, null),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
