import 'package:sqflite/sqflite.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final Database db;

  ExerciseRepository(this.db);

  Future<List<Exercise>> getAll({String? search, String? category}) async {
    String? where;
    List<dynamic>? whereArgs;

    if (search != null && search.isNotEmpty && category != null) {
      where = 'LOWER(name) LIKE ? AND category = ?';
      whereArgs = ['%${search.toLowerCase()}%', category];
    } else if (search != null && search.isNotEmpty) {
      where = 'LOWER(name) LIKE ?';
      whereArgs = ['%${search.toLowerCase()}%'];
    } else if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    }

    final rows = await db.query(
      'exercises',
      where: where,
      whereArgs: whereArgs,
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
