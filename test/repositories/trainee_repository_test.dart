import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gym_train_log/core/models/trainee.dart';
import 'package:gym_train_log/core/repositories/trainee_repository.dart';
import '../helpers/db_test_helper.dart';

void main() {
  late Database db;
  late TraineeRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = TraineeRepository(db);
  });

  tearDown(() => db.close());

  group('TraineeRepository', () {
    test('insert and getAll returns trainee', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.insert(Trainee(name: 'Bob', createdAt: now));

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.name, 'Bob');
    });

    test('getById returns correct trainee', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(Trainee(name: 'Charlie', createdAt: now));

      final t = await repo.getById(id);
      expect(t, isNotNull);
      expect(t!.name, 'Charlie');
    });

    test('getById returns null for missing id', () async {
      final t = await repo.getById(999);
      expect(t, isNull);
    });

    test('update changes name', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(Trainee(name: 'Dave', createdAt: now));
      final trainee = await repo.getById(id);
      await repo.update(trainee!.copyWith(name: 'David'));

      final updated = await repo.getById(id);
      expect(updated!.name, 'David');
    });

    test('delete removes trainee', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(Trainee(name: 'Eve', createdAt: now));
      await repo.delete(id);

      final all = await repo.getAll();
      expect(all, isEmpty);
    });

    test('delete cascades to sessions', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final traineeId =
          await repo.insert(Trainee(name: 'Frank', createdAt: now));

      await db.insert('sessions', {
        'trainee_id': traineeId,
        'date': '2024-01-01',
        'started_at': now,
      });

      await repo.delete(traineeId);

      final sessions = await db.query('sessions');
      expect(sessions, isEmpty);
    });

    test('getAll returns sorted by name', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.insert(Trainee(name: 'Zara', createdAt: now));
      await repo.insert(Trainee(name: 'Alice', createdAt: now));
      await repo.insert(Trainee(name: 'Mike', createdAt: now));

      final all = await repo.getAll();
      expect(all.map((t) => t.name).toList(), ['Alice', 'Mike', 'Zara']);
    });
  });
}
