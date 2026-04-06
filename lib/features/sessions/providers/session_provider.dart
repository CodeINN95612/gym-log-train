import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/session.dart';
import '../../../core/models/session_exercise.dart';
import '../../../core/models/set_entry.dart';
import '../../../core/repositories/session_repository.dart';
import '../../../core/utils/date_utils.dart' as du;

class SessionProvider extends ChangeNotifier {
  final int traineeId;

  List<Session> _sessions = [];
  Session? _activeSession;
  List<SessionExercise> _sessionExercises = [];
  // setsByExerciseId: sessionExercise.id -> sets
  final Map<int, List<SetEntry>> _setsByExerciseId = {};
  bool _isLoading = false;
  String? _error;

  List<Session> get sessions => _sessions;
  Session? get activeSession => _activeSession;
  List<SessionExercise> get sessionExercises => _sessionExercises;
  Map<int, List<SetEntry>> get setsByExerciseId =>
      Map.unmodifiable(_setsByExerciseId);
  bool get isLoading => _isLoading;
  String? get error => _error;

  SessionProvider(this.traineeId);

  SessionRepository? _repo;

  Future<SessionRepository> _getRepo() async {
    if (_repo == null) {
      final db = await DatabaseHelper.instance.database;
      _repo = SessionRepository(db);
    }
    return _repo!;
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final repo = await _getRepo();
      _sessions = await repo.getSessionsForTrainee(traineeId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionDetail(int sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final repo = await _getRepo();
      _activeSession = await repo.getById(sessionId);
      await _refreshSessionExercises(sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshSessionExercises(int sessionId) async {
    final repo = await _getRepo();
    _sessionExercises = await repo.getSessionExercises(sessionId);
    _setsByExerciseId.clear();
    for (final se in _sessionExercises) {
      _setsByExerciseId[se.id!] =
          await repo.getSetsForSessionExercise(se.id!);
    }
  }

  /// Starts a new session. Returns the new session id.
  Future<int> startSession({int? planDayId}) async {
    final repo = await _getRepo();
    final now = DateTime.now();
    final id = await repo.startSession(
      traineeId: traineeId,
      planDayId: planDayId,
      date: du.toDateString(now),
      startedAt: now.millisecondsSinceEpoch,
    );
    await loadSessions();
    return id;
  }

  /// Returns true if a session was started within the last [withinDays] days.
  bool canDelete(Session session, {int withinDays = 3}) {
    final startedAt = session.startedAt;
    if (startedAt == null) return false;
    final age = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(startedAt));
    return age.inDays < withinDays;
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      final repo = await _getRepo();
      await repo.deleteSession(sessionId);
      _activeSession = null;
      _sessionExercises = [];
      _setsByExerciseId.clear();
      await loadSessions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> endSession(int sessionId) async {
    try {
      final repo = await _getRepo();
      final session = await repo.getById(sessionId);
      if (session == null) return;
      final updated =
          session.copyWith(endedAt: DateTime.now().millisecondsSinceEpoch);
      await repo.updateSession(updated);
      _activeSession = updated;
      await loadSessions();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addExerciseToSession(int sessionId, int exerciseId) async {
    try {
      final repo = await _getRepo();
      final currentCount = await repo.countSessionExercises(sessionId);
      final se = SessionExercise(
        sessionId: sessionId,
        exerciseId: exerciseId,
        orderIndex: currentCount,
      );
      await repo.insertSessionExercise(se);
      await _refreshSessionExercises(sessionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSessionExercise(
      int sessionExerciseId, int sessionId) async {
    try {
      final repo = await _getRepo();
      await repo.deleteSessionExercise(sessionExerciseId);
      await _refreshSessionExercises(sessionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Adds a new empty set and returns its id. Caller triggers timer.
  Future<int?> addSet(int sessionExerciseId) async {
    try {
      final repo = await _getRepo();
      final existingSets = _setsByExerciseId[sessionExerciseId] ?? [];
      final setNumber = existingSets.length + 1;
      final id = await repo.insertSet(SetEntry(
        sessionExerciseId: sessionExerciseId,
        setNumber: setNumber,
      ));
      final updated =
          await repo.getSetsForSessionExercise(sessionExerciseId);
      _setsByExerciseId[sessionExerciseId] = updated;
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateSet(SetEntry set) async {
    try {
      final repo = await _getRepo();
      await repo.updateSet(set);
      final updated =
          await repo.getSetsForSessionExercise(set.sessionExerciseId);
      _setsByExerciseId[set.sessionExerciseId] = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSet(int setId, int sessionExerciseId) async {
    try {
      final repo = await _getRepo();
      await repo.deleteSet(setId);
      final updated =
          await repo.getSetsForSessionExercise(sessionExerciseId);
      // Re-number sets after deletion
      _setsByExerciseId[sessionExerciseId] = updated
          .asMap()
          .entries
          .map((e) => e.value.copyWith(setNumber: e.key + 1))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
