import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../features/exercises/providers/exercise_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarSettings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          RadioGroup<String>(
            groupValue: settings.language,
            onChanged: (v) => _setLanguage(context, v!),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.langEnglish),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text(l10n.langSpanish),
                  value: 'es',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setLanguage(BuildContext context, String lang) {
    context.read<SettingsProvider>().setLanguage(lang);
    context.read<ExerciseProvider>().load(language: lang);
  }
}
