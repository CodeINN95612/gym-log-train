import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _repoUrl = 'https://github.com/CodeINN95612/gym-log-train';
  static const _siteUrl = 'https://codeirnn95612.github.io/gym-log-train';
  static const _privacyUrl = 'https://codeirnn95612.github.io/gym-log-train/privacy-policy';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarAbout)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 64, color: scheme.primary),
              const SizedBox(height: 16),
              Text(
                'GymTrainLog',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.aboutDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon: const Icon(Icons.star_outline),
                label: Text(l10n.starOnGithub),
                onPressed: () => launchUrl(
                  Uri.parse(_repoUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: Text(l10n.website),
                    onPressed: () => launchUrl(
                      Uri.parse(_siteUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  Text('·', style: TextStyle(color: scheme.outlineVariant)),
                  TextButton(
                    child: Text(l10n.privacyPolicy),
                    onPressed: () => launchUrl(
                      Uri.parse(_privacyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'v1.5.0',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.outlineVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
