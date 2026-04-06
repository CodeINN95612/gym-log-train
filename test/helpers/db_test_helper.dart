import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:gym_train_log/core/database/migrations.dart';

Future<Database> openTestDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _runMigrations(db, 0, version);
      },
    ),
  );
  return db;
}

Future<void> _runMigrations(Database db, int from, int to) async {
  for (int v = from + 1; v <= to; v++) {
    final statements = Migrations.scripts[v];
    if (statements != null) {
      for (final sql in statements) {
        await db.execute(sql);
      }
    }
  }
}
