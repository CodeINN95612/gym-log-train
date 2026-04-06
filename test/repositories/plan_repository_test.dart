import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gym_train_log/core/models/plan_day.dart';
import 'package:gym_train_log/core/models/plan_day_exercise.dart';
import 'package:gym_train_log/core/repositories/plan_repository.dart';
import '../helpers/db_test_helper.dart';

void main() {
  late Database db;
  late PlanRepository repo;
  late int traineeId;
  late int exerciseId;

  setUp(() async {
    db = await openTestDatabase();
    repo = PlanRepository(db);
    final now = DateTime.now().millisecondsSinceEpoch;
    traineeId = await db.insert('trainees', {'name': 'Tester', 'created_at': now});
    exerciseId = await db.insert('exercises',
        {'name': '__TestExercise_Plan__', 'created_at': now});
  });

  tearDown(() => db.close());

  group('PlanRepository', () {
    test('insertPlanDay and getPlanDaysForTrainee', () async {
      await repo.insertPlanDay(PlanDay(
        traineeId: traineeId,
        weekday: 0,
        label: 'Upper Body',
      ));

      final days = await repo.getPlanDaysForTrainee(traineeId);
      expect(days.length, 1);
      expect(days.first.weekday, 0);
      expect(days.first.label, 'Upper Body');
    });

    test('getPlanDayByWeekday returns correct day', () async {
      await repo.insertPlanDay(PlanDay(traineeId: traineeId, weekday: 2));

      final day = await repo.getPlanDayByWeekday(traineeId, 2);
      expect(day, isNotNull);
      expect(day!.weekday, 2);
    });

    test('insertPlanDayExercise and getPlanDayExercises with join', () async {
      final dayId = await repo
          .insertPlanDay(PlanDay(traineeId: traineeId, weekday: 1));

      await repo.insertPlanDayExercise(PlanDayExercise(
        planDayId: dayId,
        exerciseId: exerciseId,
        orderIndex: 0,
      ));

      final exercises = await repo.getPlanDayExercises(dayId);
      expect(exercises.length, 1);
      expect(exercises.first.exercise?.name, '__TestExercise_Plan__');
    });

    test('deletePlanDay cascades to plan_day_exercises', () async {
      final dayId = await repo
          .insertPlanDay(PlanDay(traineeId: traineeId, weekday: 4));

      await repo.insertPlanDayExercise(PlanDayExercise(
        planDayId: dayId,
        exerciseId: exerciseId,
        orderIndex: 0,
      ));

      await repo.deletePlanDay(dayId);

      final exercises = await repo.getPlanDayExercises(dayId);
      expect(exercises, isEmpty);
    });

    test('deletePlanDayExercise removes only that exercise', () async {
      final dayId = await repo
          .insertPlanDay(PlanDay(traineeId: traineeId, weekday: 3));

      final pdeId = await repo.insertPlanDayExercise(PlanDayExercise(
        planDayId: dayId,
        exerciseId: exerciseId,
        orderIndex: 0,
      ));
      // add second exercise
      final ex2Id = await db.insert('exercises',
          {'name': '__TestExercise_Plan2__', 'created_at': DateTime.now().millisecondsSinceEpoch});
      await repo.insertPlanDayExercise(PlanDayExercise(
        planDayId: dayId,
        exerciseId: ex2Id,
        orderIndex: 1,
      ));

      await repo.deletePlanDayExercise(pdeId);

      final remaining = await repo.getPlanDayExercises(dayId);
      expect(remaining.length, 1);
      expect(remaining.first.exercise?.name, '__TestExercise_Plan2__');
    });
  });
}
