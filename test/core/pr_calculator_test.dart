import 'package:flutter_test/flutter_test.dart';
import 'package:gym_train_log/core/models/set_entry.dart';
import 'package:gym_train_log/core/utils/pr_calculator.dart';

void main() {
  group('calculatePr', () {
    test('returns empty result for empty list', () {
      final result = calculatePr([]);
      expect(result.bestWeight, isNull);
      expect(result.bestReps, isNull);
      expect(result.bestDuration, isNull);
      expect(result.estimated1rm, isNull);
      expect(result.hasAnyData, isFalse);
    });

    test('calculates best weight from multiple sets', () {
      final sets = [
        SetEntry(sessionExerciseId: 1, setNumber: 1, weightKg: 80),
        SetEntry(sessionExerciseId: 1, setNumber: 2, weightKg: 85),
        SetEntry(sessionExerciseId: 1, setNumber: 3, weightKg: 75),
      ];
      final result = calculatePr(sets);
      expect(result.bestWeight, 85.0);
    });

    test('calculates best reps', () {
      final sets = [
        SetEntry(sessionExerciseId: 1, setNumber: 1, reps: 10),
        SetEntry(sessionExerciseId: 1, setNumber: 2, reps: 8),
        SetEntry(sessionExerciseId: 1, setNumber: 3, reps: 12),
      ];
      final result = calculatePr(sets);
      expect(result.bestReps, 12);
    });

    test('calculates best duration', () {
      final sets = [
        SetEntry(sessionExerciseId: 1, setNumber: 1, durationSeconds: 30),
        SetEntry(sessionExerciseId: 1, setNumber: 2, durationSeconds: 45),
        SetEntry(sessionExerciseId: 1, setNumber: 3, durationSeconds: 40),
      ];
      final result = calculatePr(sets);
      expect(result.bestDuration, 45);
    });

    test('calculates estimated 1RM = weight * (1 + reps/30)', () {
      final sets = [
        // 100 * (1 + 10/30) = 100 * 1.333... = 133.33
        SetEntry(sessionExerciseId: 1, setNumber: 1, weightKg: 100, reps: 10),
        // 90 * (1 + 5/30) = 90 * 1.166... = 105
        SetEntry(sessionExerciseId: 1, setNumber: 2, weightKg: 90, reps: 5),
      ];
      final result = calculatePr(sets);
      expect(result.estimated1rm, closeTo(133.33, 0.01));
    });

    test('ignores null weight or reps for 1RM calculation', () {
      final sets = [
        SetEntry(sessionExerciseId: 1, setNumber: 1, weightKg: 100), // no reps
        SetEntry(sessionExerciseId: 1, setNumber: 2, reps: 10), // no weight
        SetEntry(
            sessionExerciseId: 1,
            setNumber: 3,
            weightKg: 80,
            reps: 5), // valid
      ];
      final result = calculatePr(sets);
      // Only third set contributes: 80 * (1 + 5/30) = 93.33
      expect(result.estimated1rm, closeTo(93.33, 0.01));
    });

    test('handles single set with all fields', () {
      final sets = [
        SetEntry(
          sessionExerciseId: 1,
          setNumber: 1,
          weightKg: 60,
          reps: 8,
          durationSeconds: 30,
        ),
      ];
      final result = calculatePr(sets);
      expect(result.bestWeight, 60.0);
      expect(result.bestReps, 8);
      expect(result.bestDuration, 30);
      expect(result.estimated1rm, closeTo(76.0, 0.01));
      expect(result.hasAnyData, isTrue);
    });

    test('handles mixed null fields gracefully', () {
      final sets = [
        SetEntry(sessionExerciseId: 1, setNumber: 1, durationSeconds: 60),
        SetEntry(sessionExerciseId: 1, setNumber: 2, reps: 15),
      ];
      final result = calculatePr(sets);
      expect(result.bestWeight, isNull);
      expect(result.bestReps, 15);
      expect(result.bestDuration, 60);
      expect(result.estimated1rm, isNull);
    });
  });
}
