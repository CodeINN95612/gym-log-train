import 'package:sqflite/sqflite.dart';
import '../models/session.dart';
import '../models/session_exercise.dart';
import '../models/set_entry.dart';

class ProgressDataPoint {
  final String date;
  final double? bestWeight;
  final int? bestReps;
  final int? bestDuration;
  final double? estimated1rm;

  const ProgressDataPoint({
    required this.date,
    this.bestWeight,
    this.bestReps,
    this.bestDuration,
    this.estimated1rm,
  });
}

class SessionRepository {
  final Database db;

  SessionRepository(this.db);

  // ── Sessions ────────────────────────────────────────────────────────────────

  Future<List<Session>> getSessionsForTrainee(int traineeId) async {
    final rows = await db.query(
      'sessions',
      where: 'trainee_id = ?',
      whereArgs: [traineeId],
      orderBy: 'date DESC, started_at DESC',
    );
    return rows.map(Session.fromMap).toList();
  }

  Future<Session?> getById(int id) async {
    final rows =
        await db.query('sessions', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Session.fromMap(rows.first);
  }

  Future<int> insertSession(Session session) async {
    return db.insert('sessions', session.toMap());
  }

  Future<void> updateSession(Session session) async {
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteSession(int id) async {
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  /// Creates a session and optionally copies plan exercises into session_exercises.
  Future<int> startSession({
    required int traineeId,
    int? planDayId,
    required String date,
    required int startedAt,
  }) async {
    return db.transaction((txn) async {
      final sessionId = await txn.insert('sessions', {
        'trainee_id': traineeId,
        'plan_day_id': planDayId,
        'date': date,
        'started_at': startedAt,
      });

      if (planDayId != null) {
        final planExercises = await txn.query(
          'plan_day_exercises',
          where: 'plan_day_id = ?',
          whereArgs: [planDayId],
          orderBy: 'order_index ASC',
        );
        for (final pde in planExercises) {
          await txn.insert('session_exercises', {
            'session_id': sessionId,
            'exercise_id': pde['exercise_id'],
            'order_index': pde['order_index'],
            'notes': pde['notes'],
          });
        }
      }

      return sessionId;
    });
  }

  // ── Session exercises ────────────────────────────────────────────────────────

  Future<List<SessionExercise>> getSessionExercises(int sessionId) async {
    final rows = await db.rawQuery(
      '''
      SELECT se.*, e.name AS exercise_name, e.category AS exercise_category,
             e.muscle_focus AS exercise_muscle_focus, e.created_at AS exercise_created_at
      FROM session_exercises se
      JOIN exercises e ON e.id = se.exercise_id
      WHERE se.session_id = ?
      ORDER BY se.order_index ASC
      ''',
      [sessionId],
    );
    return rows.map(SessionExercise.fromMap).toList();
  }

  Future<int> insertSessionExercise(SessionExercise se) async {
    return db.insert('session_exercises', se.toMap());
  }

  Future<void> deleteSessionExercise(int id) async {
    await db.delete('session_exercises', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countSessionExercises(int sessionId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM session_exercises WHERE session_id = ?',
      [sessionId],
    );
    return result.first['cnt'] as int;
  }

  // ── Sets ─────────────────────────────────────────────────────────────────────

  Future<List<SetEntry>> getSetsForSessionExercise(
      int sessionExerciseId) async {
    final rows = await db.query(
      'sets',
      where: 'session_exercise_id = ?',
      whereArgs: [sessionExerciseId],
      orderBy: 'set_number ASC',
    );
    return rows.map(SetEntry.fromMap).toList();
  }

  Future<int> insertSet(SetEntry set) async {
    return db.insert('sets', set.toMap());
  }

  Future<void> updateSet(SetEntry set) async {
    await db.update('sets', set.toMap(),
        where: 'id = ?', whereArgs: [set.id]);
  }

  Future<void> deleteSet(int id) async {
    await db.delete('sets', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countSets(int sessionExerciseId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM sets WHERE session_exercise_id = ?',
      [sessionExerciseId],
    );
    return result.first['cnt'] as int;
  }

  // ── Progress queries ─────────────────────────────────────────────────────────

  Future<List<ProgressDataPoint>> getProgressData(
      int traineeId, int exerciseId) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        s.date,
        MAX(st.weight_kg) AS best_weight,
        MAX(st.reps) AS best_reps,
        MAX(st.duration_seconds) AS best_duration,
        MAX(st.weight_kg * (1 + st.reps / 30.0)) AS estimated_1rm
      FROM sessions s
      JOIN session_exercises se ON se.session_id = s.id
      JOIN sets st ON st.session_exercise_id = se.id
      WHERE s.trainee_id = ? AND se.exercise_id = ?
      GROUP BY s.id
      ORDER BY s.date ASC, s.started_at ASC
      ''',
      [traineeId, exerciseId],
    );
    return rows
        .map((r) => ProgressDataPoint(
              date: r['date'] as String,
              bestWeight: r['best_weight'] as double?,
              bestReps: (r['best_reps'] as num?)?.toInt(),
              bestDuration: (r['best_duration'] as num?)?.toInt(),
              estimated1rm: r['estimated_1rm'] as double?,
            ))
        .toList();
  }

  /// Returns all exercises a trainee has ever logged, with their all-time PRs.
  Future<List<Map<String, dynamic>>> getPrData(int traineeId) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        e.id AS exercise_id,
        e.name AS exercise_name,
        e.category AS exercise_category,
        MAX(st.weight_kg) AS best_weight,
        MAX(st.reps) AS best_reps,
        MAX(st.duration_seconds) AS best_duration,
        MAX(st.weight_kg * (1 + st.reps / 30.0)) AS estimated_1rm
      FROM sessions s
      JOIN session_exercises se ON se.session_id = s.id
      JOIN exercises e ON e.id = se.exercise_id
      JOIN sets st ON st.session_exercise_id = se.id
      WHERE s.trainee_id = ?
      GROUP BY e.id
      ORDER BY e.name ASC
      ''',
      [traineeId],
    );
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  /// Returns distinct exercises used by a trainee.
  Future<List<Map<String, dynamic>>> getDistinctExercises(
      int traineeId) async {
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT e.id, e.name, e.category
      FROM sessions s
      JOIN session_exercises se ON se.session_id = s.id
      JOIN exercises e ON e.id = se.exercise_id
      WHERE s.trainee_id = ?
      ORDER BY e.name ASC
      ''',
      [traineeId],
    );
    return rows.map((r) => Map<String, dynamic>.from(r)).toList();
  }

  Future<Map<String, dynamic>> getStats(int traineeId) async {
    final sessionCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM sessions WHERE trainee_id = ?',
          [traineeId],
        )) ??
        0;
    final exerciseCount = Sqflite.firstIntValue(await db.rawQuery(
          '''
          SELECT COUNT(DISTINCT se.exercise_id)
          FROM sessions s JOIN session_exercises se ON se.session_id = s.id
          WHERE s.trainee_id = ?
          ''',
          [traineeId],
        )) ??
        0;
    final firstDateRows = await db.rawQuery(
      'SELECT MIN(date) as first_date FROM sessions WHERE trainee_id = ?',
      [traineeId],
    );
    final firstDate = firstDateRows.first['first_date'] as String?;

    return {
      'session_count': sessionCount,
      'exercise_count': exerciseCount,
      'first_date': firstDate,
    };
  }
}
