import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/trainee.dart';
import '../../../shared/widgets/pr_card.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  final Trainee trainee;

  const ProgressScreen({super.key, required this.trainee});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle(trainee.name))),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.sessionCount == 0
              ? Center(child: Text(l10n.noSessionData))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _StatsStrip(provider: provider),
                    const SizedBox(height: 24),
                    if (provider.prCards.isNotEmpty) ...[
                      Text(l10n.personalRecords,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.prCards.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (_, i) =>
                              PrCardWidget(pr: provider.prCards[i]),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (provider.distinctExercises.isNotEmpty) ...[
                      Text(l10n.exerciseProgressTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _ExerciseSelector(provider: provider),
                      const SizedBox(height: 12),
                      _MetricSelector(provider: provider),
                      const SizedBox(height: 12),
                      _ProgressChart(provider: provider),
                    ],
                  ],
                ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final ProgressProvider provider;

  const _StatsStrip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            _stat(context, '${provider.sessionCount}', l10n.statSessions),
            _divider(theme),
            _stat(context, '${provider.exerciseCount}', l10n.statExercises),
            if (provider.firstDate != null) ...[
              _divider(theme),
              _stat(context, _formatDate(provider.firstDate!), l10n.statSince),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );

  Widget _divider(ThemeData theme) => Container(
        width: 1,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: theme.colorScheme.outlineVariant,
      );

  String _formatDate(String d) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(d);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return d;
    }
  }
}

class _ExerciseSelector extends StatelessWidget {
  final ProgressProvider provider;

  const _ExerciseSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.distinctExercises.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final ex = provider.distinctExercises[i];
          final selected = provider.selectedExerciseId == ex.id;
          return FilterChip(
            label: Text(ex.name),
            selected: selected,
            onSelected: (_) => provider.selectExercise(ex.id!),
          );
        },
      ),
    );
  }
}

class _MetricSelector extends StatelessWidget {
  final ProgressProvider provider;

  const _MetricSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      ProgressMetric.weight: l10n.metricWeight,
      ProgressMetric.reps: l10n.metricReps,
      ProgressMetric.estimated1rm: l10n.metricEstimated1rm,
      ProgressMetric.duration: l10n.metricDuration,
    };
    final available = provider.availableMetrics();
    if (available.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: ProgressMetric.values
          .where((m) => available.contains(m))
          .map((m) => ChoiceChip(
                label: Text(labels[m]!),
                selected: provider.selectedMetric == m,
                onSelected: (_) => provider.selectMetric(m),
              ))
          .toList(),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final ProgressProvider provider;

  const _ProgressChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final points = provider.chartPoints;
    if (points.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(l10n.noDataForMetric)),
      );
    }

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY).abs() * 0.1 + 1;

    return SizedBox(
      height: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 24, 8),
          child: LineChart(
            LineChartData(
              minY: minY - yPadding,
              maxY: maxY + yPadding,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: spots.length > 6
                        ? (spots.length / 5).ceilToDouble()
                        : 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= points.length) {
                        return const SizedBox.shrink();
                      }
                      final date = points[idx].date;
                      final parts = date.split('-');
                      if (parts.length < 3) return const SizedBox.shrink();
                      return Text('${parts[1]}/${parts[2]}',
                          style: const TextStyle(fontSize: 9));
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha(30),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
