import '../models/set_entry.dart';

class PrResult {
  final double? bestWeight;
  final int? bestReps;
  final int? bestDuration;
  final double? estimated1rm;

  const PrResult({
    this.bestWeight,
    this.bestReps,
    this.bestDuration,
    this.estimated1rm,
  });

  bool get hasAnyData =>
      bestWeight != null ||
      bestReps != null ||
      bestDuration != null ||
      estimated1rm != null;
}

PrResult calculatePr(List<SetEntry> sets) {
  if (sets.isEmpty) return const PrResult();

  double? bestWeight;
  int? bestReps;
  int? bestDuration;
  double? estimated1rm;

  for (final s in sets) {
    if (s.weightKg != null) {
      bestWeight =
          bestWeight == null ? s.weightKg : (s.weightKg! > bestWeight ? s.weightKg : bestWeight);
    }
    if (s.reps != null) {
      bestReps = bestReps == null ? s.reps : (s.reps! > bestReps ? s.reps : bestReps);
    }
    if (s.durationSeconds != null) {
      bestDuration = bestDuration == null
          ? s.durationSeconds
          : (s.durationSeconds! > bestDuration ? s.durationSeconds : bestDuration);
    }
    if (s.weightKg != null && s.reps != null) {
      final e1rm = s.weightKg! * (1 + s.reps! / 30.0);
      estimated1rm = estimated1rm == null ? e1rm : (e1rm > estimated1rm ? e1rm : estimated1rm);
    }
  }

  return PrResult(
    bestWeight: bestWeight,
    bestReps: bestReps,
    bestDuration: bestDuration,
    estimated1rm: estimated1rm,
  );
}
