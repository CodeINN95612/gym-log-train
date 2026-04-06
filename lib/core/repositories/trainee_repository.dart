import 'package:sqflite/sqflite.dart';
import '../models/trainee.dart';

class TraineeRepository {
  final Database db;

  TraineeRepository(this.db);

  Future<List<Trainee>> getAll() async {
    final rows = await db.query('trainees', orderBy: 'name ASC');
    return rows.map(Trainee.fromMap).toList();
  }

  Future<Trainee?> getById(int id) async {
    final rows = await db.query('trainees', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Trainee.fromMap(rows.first);
  }

  Future<int> insert(Trainee trainee) async {
    return db.insert('trainees', trainee.toMap());
  }

  Future<void> update(Trainee trainee) async {
    await db.update(
      'trainees',
      trainee.toMap(),
      where: 'id = ?',
      whereArgs: [trainee.id],
    );
  }

  Future<void> delete(int id) async {
    await db.delete('trainees', where: 'id = ?', whereArgs: [id]);
  }
}
