import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/plan_day.dart';
import '../../../core/models/plan_day_exercise.dart';
import '../../../core/repositories/plan_repository.dart';

class PlanProvider extends ChangeNotifier {
  final int traineeId;

  List<PlanDay> _planDays = [];
  // Map of planDayId -> exercises
  final Map<int, List<PlanDayExercise>> _exercises = {};
  bool _isLoading = false;
  String? _error;

  List<PlanDay> get planDays => _planDays;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PlanProvider(this.traineeId);

  PlanRepository? _repo;

  Future<PlanRepository> _getRepo() async {
    if (_repo == null) {
      final db = await DatabaseHelper.instance.database;
      _repo = PlanRepository(db);
    }
    return _repo!;
  }

  PlanDay? planDayForWeekday(int weekday) {
    try {
      return _planDays.firstWhere((d) => d.weekday == weekday);
    } catch (_) {
      return null;
    }
  }

  List<PlanDayExercise> exercisesForDay(int planDayId) =>
      _exercises[planDayId] ?? [];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final repo = await _getRepo();
      _planDays = await repo.getPlanDaysForTrainee(traineeId);
      _exercises.clear();
      for (final day in _planDays) {
        _exercises[day.id!] = await repo.getPlanDayExercises(day.id!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlanDay?> addDay(int weekday) async {
    final existing = planDayForWeekday(weekday);
    if (existing != null) return existing;
    try {
      final repo = await _getRepo();
      final id = await repo.insertPlanDay(
        PlanDay(traineeId: traineeId, weekday: weekday),
      );
      await load();
      return _planDays.firstWhere((d) => d.id == id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> removeDay(int planDayId) async {
    try {
      final repo = await _getRepo();
      await repo.deletePlanDay(planDayId);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addExercise(int planDayId, int exerciseId) async {
    try {
      final repo = await _getRepo();
      final currentCount = await repo.countPlanDayExercises(planDayId);
      await repo.insertPlanDayExercise(PlanDayExercise(
        planDayId: planDayId,
        exerciseId: exerciseId,
        orderIndex: currentCount,
      ));
      final updated = await repo.getPlanDayExercises(planDayId);
      _exercises[planDayId] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeExercise(int planDayExerciseId, int planDayId) async {
    try {
      final repo = await _getRepo();
      await repo.deletePlanDayExercise(planDayExerciseId);
      final updated = await repo.getPlanDayExercises(planDayId);
      _exercises[planDayId] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
