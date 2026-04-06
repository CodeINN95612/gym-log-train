import 'package:flutter/material.dart';
import '../../features/progress/providers/progress_provider.dart';

class PrCardWidget extends StatelessWidget {
  final PrCard pr;

  const PrCardWidget({super.key, required this.pr});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: SizedBox(
        width: 160,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pr.exerciseName,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (pr.bestWeight != null)
                _metricRow('Best Weight', '${pr.bestWeight!.toStringAsFixed(1)} kg'),
              if (pr.estimated1rm != null)
                _metricRow('Est. 1RM', '${pr.estimated1rm!.toStringAsFixed(1)} kg'),
              if (pr.bestReps != null)
                _metricRow('Best Reps', '${pr.bestReps}'),
              if (pr.bestDuration != null)
                _metricRow('Best Duration', _formatDuration(pr.bestDuration!)),
              if (pr.bestWeight == null &&
                  pr.bestReps == null &&
                  pr.bestDuration == null)
                const Text('No data yet', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}
