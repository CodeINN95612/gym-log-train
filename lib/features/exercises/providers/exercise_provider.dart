import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/exercise.dart';
import '../../../core/repositories/exercise_repository.dart';

class ExerciseProvider extends ChangeNotifier {
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;
  bool _isDuplicate = false;

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDuplicate => _isDuplicate;

  ExerciseRepository? _repo;

  Future<ExerciseRepository> _getRepo() async {
    if (_repo == null) {
      final db = await DatabaseHelper.instance.database;
      _repo = ExerciseRepository(db);
    }
    return _repo!;
  }

  Future<void> load({String? search, String? category, String language = 'en'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final repo = await _getRepo();
      _exercises = await repo.getAll(search: search, category: category, language: language);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Exercise?> addExercise(
    String name,
    String? category,
    String? muscleFocus, {
    String language = 'en',
  }) async {
    _isDuplicate = false;
    try {
      final repo = await _getRepo();
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(Exercise(
          name: name.trim(),
          category: category,
          muscleFocus: muscleFocus,
          language: language,
          createdAt: now));
      await load(language: language);
      return await repo.getById(id);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        _isDuplicate = true;
        notifyListeners();
      } else {
        _error = e.toString();
        notifyListeners();
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteExercise(int id) async {
    try {
      final repo = await _getRepo();
      await repo.delete(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearDuplicateError() {
    _isDuplicate = false;
    notifyListeners();
  }
}
