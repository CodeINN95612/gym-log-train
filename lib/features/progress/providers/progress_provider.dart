import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/exercise.dart';
import '../../../core/repositories/session_repository.dart';
import '../../../core/utils/weight_utils.dart';

enum ProgressMetric { weight, reps, estimated1rm, duration }

class PrCard {
  final int exerciseId;
  final String exerciseName;
  final String? exerciseCategory;
  final double? bestWeight;
  final int? bestReps;
  final int? bestDuration;
  final double? estimated1rm;

  const PrCard({
    required this.exerciseId,
    required this.exerciseName,
    this.exerciseCategory,
    this.bestWeight,
    this.bestReps,
    this.bestDuration,
    this.estimated1rm,
  });
}

class ChartDataPoint {
  final String date;
  final double value;

  const ChartDataPoint({required this.date, required this.value});
}

class ProgressProvider extends ChangeNotifier {
  final int traineeId;

  int _sessionCount = 0;
  int _exerciseCount = 0;
  String? _firstDate;
  List<PrCard> _prCards = [];
  List<Exercise> _distinctExercises = [];
  int? _selectedExerciseId;
  ProgressMetric _selectedMetric = ProgressMetric.weight;
  List<ChartDataPoint> _chartPoints = [];
  bool _isLoading = false;
  String? _error;
  WeightUnit _weightUnit = WeightUnit.kg;

  int get sessionCount => _sessionCount;
  int get exerciseCount => _exerciseCount;
  String? get firstDate => _firstDate;
  List<PrCard> get prCards => _prCards;
  List<Exercise> get distinctExercises => _distinctExercises;
  int? get selectedExerciseId => _selectedExerciseId;
  ProgressMetric get selectedMetric => _selectedMetric;
  List<ChartDataPoint> get chartPoints => _chartPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WeightUnit get weightUnit => _weightUnit;

  ProgressProvider(this.traineeId);

  SessionRepository? _repo;

  Future<SessionRepository> _getRepo() async {
    if (_repo == null) {
      final db = await DatabaseHelper.instance.database;
      _repo = SessionRepository(db);
    }
    return _repo!;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _weightUnit = prefs.getString('weight_unit') == 'lbs'
          ? WeightUnit.lbs
          : WeightUnit.kg;

      final repo = await _getRepo();

      final stats = await repo.getStats(traineeId);
      _sessionCount = stats['session_count'] as int;
      _exerciseCount = stats['exercise_count'] as int;
      _firstDate = stats['first_date'] as String?;

      final prData = await repo.getPrData(traineeId);
      _prCards = prData
          .map((r) => PrCard(
                exerciseId: r['exercise_id'] as int,
                exerciseName: r['exercise_name'] as String,
                exerciseCategory: r['exercise_category'] as String?,
                bestWeight: r['best_weight'] as double?,
                bestReps: (r['best_reps'] as num?)?.toInt(),
                bestDuration: (r['best_duration'] as num?)?.toInt(),
                estimated1rm: r['estimated_1rm'] as double?,
              ))
          .toList();

      final distinctRows = await repo.getDistinctExercises(traineeId);
      _distinctExercises = distinctRows
          .map((r) => Exercise(
                id: r['id'] as int,
                name: r['name'] as String,
                category: r['category'] as String?,
                createdAt: 0,
              ))
          .toList();

      if (_distinctExercises.isNotEmpty) {
        _selectedExerciseId ??= _distinctExercises.first.id;
        await _loadChartData();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectExercise(int exerciseId) async {
    _selectedExerciseId = exerciseId;
    notifyListeners();
    await _loadChartData();
  }

  Future<void> selectMetric(ProgressMetric metric) async {
    _selectedMetric = metric;
    notifyListeners();
    await _loadChartData();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    if (_weightUnit == unit) return;
    _weightUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_unit', unit == WeightUnit.kg ? 'kg' : 'lbs');
    await _loadChartData(); // re-converts chart points; calls notifyListeners() internally
  }

  Future<void> _loadChartData() async {
    if (_selectedExerciseId == null) return;
    try {
      final repo = await _getRepo();
      final data = await repo.getProgressData(traineeId, _selectedExerciseId!);
      _chartPoints = data
          .map((dp) {
            double? valueKg;
            switch (_selectedMetric) {
              case ProgressMetric.weight:
                valueKg = dp.bestWeight;
              case ProgressMetric.reps:
                valueKg = dp.bestReps?.toDouble();
              case ProgressMetric.estimated1rm:
                valueKg = dp.estimated1rm;
              case ProgressMetric.duration:
                valueKg = dp.bestDuration?.toDouble();
            }
            if (valueKg == null) return null;
            // Apply unit conversion for weight-based metrics; reps/duration are unitless.
            final double displayValue;
            if (_selectedMetric == ProgressMetric.weight ||
                _selectedMetric == ProgressMetric.estimated1rm) {
              displayValue = roundTo1dp(kgToUnit(valueKg, _weightUnit)!);
            } else {
              displayValue = valueKg;
            }
            return ChartDataPoint(date: dp.date, value: displayValue);
          })
          .whereType<ChartDataPoint>()
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Returns which metrics have data for the selected exercise.
  Set<ProgressMetric> availableMetrics() {
    if (_selectedExerciseId == null) return {};
    final pr = _prCards
        .where((c) => c.exerciseId == _selectedExerciseId)
        .firstOrNull;
    if (pr == null) return {};
    final metrics = <ProgressMetric>{};
    if (pr.bestWeight != null) metrics.add(ProgressMetric.weight);
    if (pr.bestReps != null) metrics.add(ProgressMetric.reps);
    if (pr.estimated1rm != null) metrics.add(ProgressMetric.estimated1rm);
    if (pr.bestDuration != null) metrics.add(ProgressMetric.duration);
    return metrics;
  }
}
