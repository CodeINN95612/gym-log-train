import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/trainee.dart';
import '../../../core/repositories/trainee_repository.dart';

class TraineeProvider extends ChangeNotifier {
  List<Trainee> _trainees = [];
  bool _isLoading = false;
  String? _error;

  List<Trainee> get trainees => _trainees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TraineeRepository? _repo;

  Future<TraineeRepository> _getRepo() async {
    if (_repo == null) {
      final db = await DatabaseHelper.instance.database;
      _repo = TraineeRepository(db);
    }
    return _repo!;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final repo = await _getRepo();
      _trainees = await repo.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Trainee?> addTrainee(String name, String? notes) async {
    try {
      final repo = await _getRepo();
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(
        Trainee(name: name.trim(), notes: notes?.trim(), createdAt: now),
      );
      await load();
      return _trainees.firstWhere((t) => t.id == id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateTrainee(Trainee trainee) async {
    try {
      final repo = await _getRepo();
      await repo.update(trainee);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTrainee(int id) async {
    try {
      final repo = await _getRepo();
      await repo.delete(id);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
