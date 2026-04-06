import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _repoUrl = 'https://github.com/CodeINN95612/gym-log-train';
  static const _siteUrl = 'https://codeirnn95612.github.io/gym-log-train';
  static const _privacyUrl = 'https://codeirnn95612.github.io/gym-log-train/privacy-policy';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
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
                'A simple tool for personal trainers\nto track their trainees\' progress.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon: const Icon(Icons.star_outline),
                label: const Text('Star on GitHub'),
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
                    child: const Text('Website'),
                    onPressed: () => launchUrl(
                      Uri.parse(_siteUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  Text('·', style: TextStyle(color: scheme.outlineVariant)),
                  TextButton(
                    child: const Text('Privacy Policy'),
                    onPressed: () => launchUrl(
                      Uri.parse(_privacyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'v1.1.0',
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
