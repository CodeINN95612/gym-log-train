import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'migrations.dart';

class DatabaseHelper {
  static const int _currentVersion = 5;
  static DatabaseHelper? _instance;
  static Database? _db;

  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gym_train_log.db');

    return openDatabase(
      path,
      version: _currentVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await db.rawQuery('PRAGMA journal_mode = WAL');
      },
      onCreate: (db, version) async {
        await _runMigrations(db, 0, version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _runMigrations(db, oldVersion, newVersion);
      },
    );
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
}
