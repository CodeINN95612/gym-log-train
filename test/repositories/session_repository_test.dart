import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gym_train_log/core/models/set_entry.dart';
import 'package:gym_train_log/core/repositories/session_repository.dart';
import '../helpers/db_test_helper.dart';

void main() {
  late Database db;
  late SessionRepository repo;
  late int traineeId;
  late int exerciseId;

  setUp(() async {
    db = await openTestDatabase();
    repo = SessionRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    traineeId = await db.insert('trainees',
        {'name': 'Athlete', 'created_at': now});
    exerciseId = await db.insert('exercises',
        {'name': '__TestExercise_Session__', 'created_at': now});
  });

  tearDown(() => db.close());

  group('SessionRepository — session lifecycle', () {
    test('startSession without plan creates session with no exercises', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.startSession(
        traineeId: traineeId,
        date: '2024-01-01',
        startedAt: now,
      );

      final session = await repo.getById(id);
      expect(session, isNotNull);
      expect(session!.traineeId, traineeId);
      expect(session.endedAt, isNull);

      final exercises = await repo.getSessionExercises(id);
      expect(exercises, isEmpty);
    });

    test('startSession with plan copies exercises', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final planDayId = await db.insert('plan_days', {
        'trainee_id': traineeId,
        'weekday': 0,
      });
      await db.insert('plan_day_exercises', {
        'plan_day_id': planDayId,
        'exercise_id': exerciseId,
        'order_index': 0,
      });

      final sessionId = await repo.startSession(
        traineeId: traineeId,
        planDayId: planDayId,
        date: '2024-01-01',
        startedAt: now,
      );

      final exercises = await repo.getSessionExercises(sessionId);
      expect(exercises.length, 1);
      expect(exercises.first.exerciseId, exerciseId);
    });

    test('endSession sets ended_at', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.startSession(
        traineeId: traineeId,
        date: '2024-01-01',
        startedAt: now,
      );

      final session = await repo.getById(id);
      final ended = now + 3600000;
      await repo.updateSession(session!.copyWith(endedAt: ended));

      final updated = await repo.getById(id);
      expect(updated!.endedAt, ended);
      expect(updated.isInProgress, isFalse);
    });

    test('getSessionsForTrainee orders newest first', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.startSession(
          traineeId: traineeId, date: '2024-01-01', startedAt: now);
      await repo.startSession(
          traineeId: traineeId, date: '2024-03-15', startedAt: now + 1);
      await repo.startSession(
          traineeId: traineeId, date: '2024-02-10', startedAt: now + 2);

      final sessions = await repo.getSessionsForTrainee(traineeId);
      expect(sessions.first.date, '2024-03-15');
      expect(sessions.last.date, '2024-01-01');
    });
  });

  group('SessionRepository — sets', () {
    late int sessionId;
    late int seId;

    setUp(() async {
      final now = DateTime.now().millisecondsSinceEpoch;
      sessionId = await repo.startSession(
        traineeId: traineeId,
        date: '2024-01-01',
        startedAt: now,
      );
      seId = await db.insert('session_exercises', {
        'session_id': sessionId,
        'exercise_id': exerciseId,
        'order_index': 0,
      });
    });

    test('insert and get sets', () async {
      await repo.insertSet(SetEntry(
        sessionExerciseId: seId,
        setNumber: 1,
        weightKg: 100,
        reps: 5,
      ));

      final sets = await repo.getSetsForSessionExercise(seId);
      expect(sets.length, 1);
      expect(sets.first.weightKg, 100.0);
      expect(sets.first.reps, 5);
    });

    test('updateSet changes values', () async {
      final setId = await repo.insertSet(SetEntry(
        sessionExerciseId: seId,
        setNumber: 1,
        weightKg: 80,
        reps: 8,
      ));

      final sets = await repo.getSetsForSessionExercise(seId);
      await repo.updateSet(sets.first.copyWith(weightKg: 90, reps: 6));

      final updated = await repo.getSetsForSessionExercise(seId);
      expect(updated.first.weightKg, 90.0);
      expect(updated.first.reps, 6);
      expect(setId, isNotNull); // suppress unused var warning
    });

    test('deleteSet removes the set', () async {
      final setId = await repo.insertSet(SetEntry(
        sessionExerciseId: seId,
        setNumber: 1,
      ));

      await repo.deleteSet(setId);

      final sets = await repo.getSetsForSessionExercise(seId);
      expect(sets, isEmpty);
    });
  });

  group('SessionRepository — progress queries', () {
    test('getProgressData returns data points sorted by date', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Session 1: 2024-01-01
      final s1Id = await repo.startSession(
          traineeId: traineeId, date: '2024-01-01', startedAt: now);
      final se1Id = await db.insert('session_exercises', {
        'session_id': s1Id,
        'exercise_id': exerciseId,
        'order_index': 0,
      });
      await repo.insertSet(SetEntry(
          sessionExerciseId: se1Id,
          setNumber: 1,
          weightKg: 100,
          reps: 5));

      // Session 2: 2024-02-01 with higher weight
      final s2Id = await repo.startSession(
          traineeId: traineeId, date: '2024-02-01', startedAt: now + 1);
      final se2Id = await db.insert('session_exercises', {
        'session_id': s2Id,
        'exercise_id': exerciseId,
        'order_index': 0,
      });
      await repo.insertSet(SetEntry(
          sessionExerciseId: se2Id,
          setNumber: 1,
          weightKg: 110,
          reps: 3));

      final points = await repo.getProgressData(traineeId, exerciseId);
      expect(points.length, 2);
      expect(points.first.date, '2024-01-01');
      expect(points.first.bestWeight, 100.0);
      expect(points.last.date, '2024-02-01');
      expect(points.last.bestWeight, 110.0);
    });

    test('estimated1rm computed correctly in progress data', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final sId = await repo.startSession(
          traineeId: traineeId, date: '2024-01-01', startedAt: now);
      final seId2 = await db.insert('session_exercises', {
        'session_id': sId,
        'exercise_id': exerciseId,
        'order_index': 0,
      });
      // 100 * (1 + 10/30) = 133.33
      await repo.insertSet(SetEntry(
          sessionExerciseId: seId2,
          setNumber: 1,
          weightKg: 100,
          reps: 10));

      final points = await repo.getProgressData(traineeId, exerciseId);
      expect(points.first.estimated1rm, closeTo(133.33, 0.01));
    });
  });
}

