import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:gym_train_log/core/models/exercise.dart';
import 'package:gym_train_log/core/repositories/exercise_repository.dart';
import '../helpers/db_test_helper.dart';

void main() {
  late Database db;
  late ExerciseRepository repo;

  setUp(() async {
    db = await openTestDatabase();
    repo = ExerciseRepository(db);
  });

  tearDown(() => db.close());

  group('ExerciseRepository', () {
    test('insert increases count by 1', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final before = (await repo.getAll()).length;
      await repo.insert(Exercise(name: '__TestEx_Unique__', createdAt: now));
      final after = (await repo.getAll()).length;
      expect(after, before + 1);
    });

    test('getById returns correct exercise', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(
          Exercise(name: '__TestEx_ById__', category: 'Core', createdAt: now));
      final ex = await repo.getById(id);
      expect(ex, isNotNull);
      expect(ex!.name, '__TestEx_ById__');
      expect(ex.category, 'Core');
    });

    test('insert duplicate name throws DatabaseException', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.insert(Exercise(name: '__TestEx_Dup__', createdAt: now));
      expect(
        () => repo.insert(Exercise(name: '__TestEx_Dup__', createdAt: now)),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('search filters by name case-insensitively', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.insert(Exercise(
          name: '__TestEx_Zap_One__', category: 'Push', createdAt: now));
      await repo.insert(Exercise(
          name: '__TestEx_Zap_Two__', category: 'Pull', createdAt: now));
      await repo.insert(
          Exercise(name: '__TestEx_Other__', category: 'Core', createdAt: now));

      final results = await repo.getAll(search: '__testex_zap_');
      expect(results.length, 2);
      expect(results.map((e) => e.name).toSet(),
          {'__TestEx_Zap_One__', '__TestEx_Zap_Two__'});
    });

    test('category filter works', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      // Use a unique category name that won't match seeds
      await repo.insert(Exercise(
          name: '__TestEx_CatA__', category: '__UniqueTestCat__', createdAt: now));
      await repo.insert(Exercise(
          name: '__TestEx_CatB__', category: '__UniqueTestCat__', createdAt: now));
      await repo.insert(
          Exercise(name: '__TestEx_CatC__', category: 'Core', createdAt: now));

      final results = await repo.getAll(category: '__UniqueTestCat__');
      expect(results.length, 2);
    });

    test('search and category combined', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await repo.insert(Exercise(
          name: '__TestEx_Combo_Legs__',
          category: '__ComboTestCat__',
          createdAt: now));
      await repo.insert(Exercise(
          name: '__TestEx_Combo_Arms__',
          category: '__ComboTestCat__',
          createdAt: now));
      await repo.insert(Exercise(
          name: '__TestEx_Combo_Other__',
          category: 'Cardio',
          createdAt: now));

      final results =
          await repo.getAll(search: '__testex_combo_', category: '__ComboTestCat__');
      expect(results.length, 2);
    });

    test('delete removes exercise', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(
          Exercise(name: '__TestEx_Delete__', category: 'Arms', createdAt: now));
      await repo.delete(id);
      final ex = await repo.getById(id);
      expect(ex, isNull);
    });
  });
}
