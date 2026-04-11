import 'package:sqflite/sqflite.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final Database db;

  ExerciseRepository(this.db);

  Future<List<Exercise>> getAll({String? search, String? category, String? language}) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (search != null && search.isNotEmpty) {
      conditions.add('LOWER(name) LIKE ?');
      args.add('%${search.toLowerCase()}%');
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (language != null) {
      conditions.add('language = ?');
      args.add(language);
    }

    final where = conditions.isEmpty ? null : conditions.join(' AND ');

    final rows = await db.query(
      'exercises',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return rows.map(Exercise.fromMap).toList();
  }

  Future<Exercise?> getById(int id) async {
    final rows =
        await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Exercise.fromMap(rows.first);
  }

  Future<int> insert(Exercise exercise) async {
    return db.insert('exercises', exercise.toMap());
  }

  Future<void> update(Exercise exercise) async {
    await db.update(
      'exercises',
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }
}
