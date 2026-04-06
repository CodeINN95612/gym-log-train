import 'package:flutter_test/flutter_test.dart';
import '../helpers/db_test_helper.dart';

void main() {
  group('migrations', () {
    test('creates all 7 tables', () async {
      final db = await openTestDatabase();

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      );
      final tableNames =
          tables.map((r) => r['name'] as String).toSet();

      expect(tableNames, containsAll([
        'exercises',
        'plan_day_exercises',
        'plan_days',
        'session_exercises',
        'sessions',
        'sets',
        'trainees',
      ]));

      await db.close();
    });

    test('foreign keys are enabled', () async {
      final db = await openTestDatabase();

      final result = await db.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], 1);

      await db.close();
    });

    test('seeds exercises on fresh install', () async {
      final db = await openTestDatabase();

      final rows = await db.query('exercises');
      expect(rows.length, greaterThan(60));

      // Spot-check a few across categories
      final names = rows.map((r) => r['name'] as String).toSet();
      expect(names, containsAll(['Bench Press', 'Deadlift', 'Back Squat', 'Plank', 'Running']));

      // Verify category + muscle_focus are populated
      final bench = rows.firstWhere((r) => r['name'] == 'Bench Press');
      expect(bench['category'], 'Push');
      expect(bench['muscle_focus'], 'Chest');

      await db.close();
    });

    test('seed is idempotent — running twice does not duplicate', () async {
      final db = await openTestDatabase();
      final countBefore = (await db.query('exercises')).length;

      // Re-run the seed SQL manually
      await db.execute('''
        INSERT OR IGNORE INTO exercises (name, category, muscle_focus, created_at)
        VALUES ('Bench Press', 'Push', 'Chest', 0)
      ''');

      final countAfter = (await db.query('exercises')).length;
      expect(countAfter, countBefore);

      await db.close();
    });

    test('can insert and retrieve a trainee', () async {
      final db = await openTestDatabase();

      await db.insert('trainees', {
        'name': 'Alice',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final rows = await db.query('trainees');
      expect(rows.length, 1);
      expect(rows.first['name'], 'Alice');

      await db.close();
    });
  });
}
