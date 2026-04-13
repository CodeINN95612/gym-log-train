import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

// ── Exceptions ────────────────────────────────────────────────────────────────

class ExportException implements Exception {
  final String message;
  const ExportException(this.message);

  @override
  String toString() => 'ExportException: $message';
}

class ImportException implements Exception {
  final String message;
  const ImportException(this.message);

  @override
  String toString() => 'ImportException: $message';
}

// ── Internal DTOs (file-scoped) ───────────────────────────────────────────────

class _ExerciseRef {
  final String name;
  final String? category;
  final String? muscleFocus;

  const _ExerciseRef({required this.name, this.category, this.muscleFocus});
}

class _PlanDayExerciseData {
  final String exerciseName;
  final int orderIndex;
  final String? notes;

  const _PlanDayExerciseData(
      {required this.exerciseName,
      required this.orderIndex,
      this.notes});
}

class _PlanDayData {
  final int weekday;
  final String? label;
  final List<_PlanDayExerciseData> exercises;

  const _PlanDayData(
      {required this.weekday, this.label, required this.exercises});
}

class _SetData {
  final int setNumber;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final bool completed;

  const _SetData(
      {required this.setNumber,
      this.reps,
      this.weightKg,
      this.durationSeconds,
      required this.completed});
}

class _SessionExerciseData {
  final String exerciseName;
  final int orderIndex;
  final String? notes;
  final List<_SetData> sets;

  const _SessionExerciseData(
      {required this.exerciseName,
      required this.orderIndex,
      this.notes,
      required this.sets});
}

class _SessionData {
  final String date;
  final String? notes;
  final int? startedAt;
  final int? endedAt;
  final List<_SessionExerciseData> exercises;

  const _SessionData(
      {required this.date,
      this.notes,
      this.startedAt,
      this.endedAt,
      required this.exercises});
}

class _TraineeImportData {
  final String name;
  final String? notes;
  final int createdAt;
  final List<_ExerciseRef> exercises;
  final List<_PlanDayData> plan;
  final List<_SessionData> sessions;

  const _TraineeImportData(
      {required this.name,
      this.notes,
      required this.createdAt,
      required this.exercises,
      required this.plan,
      required this.sessions});
}

// ── Public result / preview types ────────────────────────────────────────────

class ImportResult {
  final int traineesImported;
  final int exercisesCreated;
  final int exercisesReused;

  const ImportResult({
    required this.traineesImported,
    required this.exercisesCreated,
    required this.exercisesReused,
  });
}

class ImportPreview {
  final List<_TraineeImportData> _trainees;
  final List<String> newExerciseNames;
  final List<String> existingExerciseNames;

  // Private constructor — only ExportImportService creates instances.
  ImportPreview._({
    required List<_TraineeImportData> trainees,
    required this.newExerciseNames,
    required this.existingExerciseNames,
  }) : _trainees = trainees;

  int get traineeCount => _trainees.length;
  List<String> get traineeNames => _trainees.map((t) => t.name).toList();
}

// ── Service ───────────────────────────────────────────────────────────────────

class ExportImportService {
  static const int _currentVersion = 1;

  Future<Database> _db() => DatabaseHelper.instance.database;

  // ── Export ──────────────────────────────────────────────────────────────────

  /// Exports a single trainee and opens the share sheet.
  Future<void> exportTrainee(int traineeId) async {
    try {
      final db = await _db();
      final traineeRows =
          await db.query('trainees', where: 'id = ?', whereArgs: [traineeId]);
      if (traineeRows.isEmpty) throw ExportException('Trainee not found.');

      final traineeJson = await _buildTraineeJson(db, traineeRows.first);
      final payload = _buildPayload([traineeJson]);
      final name = (traineeRows.first['name'] as String?) ?? 'trainee';
      await _sharePayload(payload, _filename('trainee_${_sanitize(name)}'));
    } on ExportException {
      rethrow;
    } catch (e) {
      throw ExportException(e.toString());
    }
  }

  /// Exports all trainees and opens the share sheet.
  Future<void> exportAllTrainees() async {
    try {
      final db = await _db();
      final traineeRows = await db.query('trainees', orderBy: 'name ASC');
      final jsonList = <Map<String, dynamic>>[];
      for (final row in traineeRows) {
        jsonList.add(await _buildTraineeJson(db, row));
      }
      final payload = _buildPayload(jsonList);
      await _sharePayload(payload, _filename('gymtrainlog_all'));
    } on ExportException {
      rethrow;
    } catch (e) {
      throw ExportException(e.toString());
    }
  }

  Future<Map<String, dynamic>> _buildTraineeJson(
      Database db, Map<String, dynamic> traineeRow) async {
    final traineeId = traineeRow['id'] as int;

    // --- Plan ---
    final planDays = await db.query('plan_days',
        where: 'trainee_id = ?',
        whereArgs: [traineeId],
        orderBy: 'weekday ASC');
    final planJson = <Map<String, dynamic>>[];
    for (final day in planDays) {
      final dayId = day['id'] as int;
      final pdeRows = await db.rawQuery(
        '''
        SELECT pde.order_index, pde.notes, e.name AS exercise_name
        FROM plan_day_exercises pde
        JOIN exercises e ON e.id = pde.exercise_id
        WHERE pde.plan_day_id = ?
        ORDER BY pde.order_index ASC
        ''',
        [dayId],
      );
      planJson.add({
        'weekday': day['weekday'],
        'label': day['label'],
        'exercises': pdeRows
            .map((r) => {
                  'exerciseName': r['exercise_name'],
                  'orderIndex': r['order_index'],
                  'notes': r['notes'],
                })
            .toList(),
      });
    }

    // --- Sessions ---
    final sessions = await db.query('sessions',
        where: 'trainee_id = ?',
        whereArgs: [traineeId],
        orderBy: 'date ASC, started_at ASC');
    final sessionsJson = <Map<String, dynamic>>[];
    for (final s in sessions) {
      final sessionId = s['id'] as int;
      final seRows = await db.rawQuery(
        '''
        SELECT se.id AS se_id, se.order_index, se.notes, e.name AS exercise_name
        FROM session_exercises se
        JOIN exercises e ON e.id = se.exercise_id
        WHERE se.session_id = ?
        ORDER BY se.order_index ASC
        ''',
        [sessionId],
      );
      final exercisesJson = <Map<String, dynamic>>[];
      for (final se in seRows) {
        final seId = se['se_id'] as int;
        final sets = await db.query('sets',
            where: 'session_exercise_id = ?',
            whereArgs: [seId],
            orderBy: 'set_number ASC');
        exercisesJson.add({
          'exerciseName': se['exercise_name'],
          'orderIndex': se['order_index'],
          'notes': se['notes'],
          'sets': sets
              .map((st) => {
                    'setNumber': st['set_number'],
                    'reps': st['reps'],
                    'weightKg': st['weight_kg'],
                    'durationSeconds': st['duration_seconds'],
                    'completed': (st['completed'] as int? ?? 1) == 1,
                  })
              .toList(),
        });
      }
      sessionsJson.add({
        'date': s['date'],
        'notes': s['notes'],
        'startedAt': s['started_at'],
        'endedAt': s['ended_at'],
        'exercises': exercisesJson,
      });
    }

    // --- Unique exercises (union of plan + sessions) ---
    final exerciseNames = <String, Map<String, dynamic>>{};
    for (final day in planJson) {
      for (final e in (day['exercises'] as List)) {
        final n = (e['exerciseName'] as String).toLowerCase();
        exerciseNames.putIfAbsent(n, () => {'name': e['exerciseName']});
      }
    }
    for (final s in sessionsJson) {
      for (final e in (s['exercises'] as List)) {
        final n = (e['exerciseName'] as String).toLowerCase();
        if (!exerciseNames.containsKey(n)) {
          exerciseNames[n] = {'name': e['exerciseName']};
        }
      }
    }
    // Fill in category/muscleFocus from DB for each exercise
    final exerciseList = <Map<String, dynamic>>[];
    for (final entry in exerciseNames.values) {
      final rows = await db.rawQuery(
        'SELECT category, muscle_focus FROM exercises WHERE LOWER(name) = LOWER(?) LIMIT 1',
        [entry['name']],
      );
      if (rows.isNotEmpty) {
        exerciseList.add({
          'name': entry['name'],
          'category': rows.first['category'],
          'muscleFocus': rows.first['muscle_focus'],
        });
      } else {
        exerciseList.add({'name': entry['name'], 'category': null, 'muscleFocus': null});
      }
    }

    return {
      'name': traineeRow['name'],
      'notes': traineeRow['notes'],
      'createdAt': traineeRow['created_at'],
      'exercises': exerciseList,
      'plan': planJson,
      'sessions': sessionsJson,
    };
  }

  Map<String, dynamic> _buildPayload(List<Map<String, dynamic>> trainees) => {
        'version': _currentVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'trainees': trainees,
      };

  Future<void> _sharePayload(
      Map<String, dynamic> payload, String filename) async {
    final tmpDir = await getTemporaryDirectory();
    final file = File('${tmpDir.path}/$filename');
    try {
      await file.writeAsString(jsonEncode(payload));
      await Share.shareXFiles([XFile(file.path)], subject: filename);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  String _filename(String base) {
    final date = DateTime.now();
    final d =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return '${base}_$d.json';
  }

  String _sanitize(String name) {
    final s = name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final collapsed = s.replaceAll(RegExp(r'_+'), '_');
    final trimmed = collapsed.length > 40 ? collapsed.substring(0, 40) : collapsed;
    return trimmed.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  // ── Import ──────────────────────────────────────────────────────────────────

  /// Opens a file picker, parses the JSON, and returns a preview.
  /// Returns null if the user cancels.
  Future<ImportPreview?> pickAndPreviewImport() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) throw ImportException('Could not access the selected file.');

    String content;
    try {
      content = await File(path).readAsString();
    } catch (e) {
      throw ImportException('Could not read file: $e');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw ImportException('File is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw ImportException('Unexpected file structure.');
    }

    _validateVersion(decoded);
    final trainees = _parsePayload(decoded);

    // Collect all unique exercise names across all trainees
    final allRefs = <String, _ExerciseRef>{};
    for (final t in trainees) {
      for (final e in t.exercises) {
        allRefs.putIfAbsent(e.name.toLowerCase(), () => e);
      }
    }

    if (allRefs.isEmpty) {
      return ImportPreview._(
          trainees: trainees, newExerciseNames: [], existingExerciseNames: []);
    }

    final db = await _db();
    final lowerNames = allRefs.keys.toList();
    final placeholders = List.filled(lowerNames.length, '?').join(', ');
    final existingRows = await db.rawQuery(
      'SELECT LOWER(name) AS ln FROM exercises WHERE LOWER(name) IN ($placeholders)',
      lowerNames,
    );
    final existingSet = existingRows.map((r) => r['ln'] as String).toSet();

    final newNames = <String>[];
    final existingNames = <String>[];
    for (final entry in allRefs.entries) {
      if (existingSet.contains(entry.key)) {
        existingNames.add(entry.value.name);
      } else {
        newNames.add(entry.value.name);
      }
    }

    return ImportPreview._(
      trainees: trainees,
      newExerciseNames: newNames..sort(),
      existingExerciseNames: existingNames..sort(),
    );
  }

  /// Executes the import. Wraps everything in a single transaction.
  Future<ImportResult> executeImport(ImportPreview preview) async {
    final db = await _db();

    // Collect all unique exercise refs
    final allRefs = <String, _ExerciseRef>{};
    for (final t in preview._trainees) {
      for (final e in t.exercises) {
        allRefs.putIfAbsent(e.name.toLowerCase(), () => e);
      }
    }

    return db.transaction((txn) async {
      // 1. Upsert exercises
      final nameToId = <String, int>{};
      int created = 0;
      int reused = 0;
      for (final entry in allRefs.entries) {
        final rows = await txn.rawQuery(
          'SELECT id FROM exercises WHERE LOWER(name) = ? LIMIT 1',
          [entry.key],
        );
        if (rows.isNotEmpty) {
          nameToId[entry.key] = rows.first['id'] as int;
          reused++;
        } else {
          final id = await txn.insert('exercises', {
            'name': entry.value.name,
            'category': entry.value.category,
            'muscle_focus': entry.value.muscleFocus,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          });
          nameToId[entry.key] = id;
          created++;
        }
      }

      // 2. Insert each trainee with all nested data
      for (final t in preview._trainees) {
        final traineeId = await txn.insert('trainees', {
          'name': t.name,
          'notes': t.notes,
          'created_at': t.createdAt,
        });

        // Plan days
        for (final day in t.plan) {
          final planDayId = await txn.insert('plan_days', {
            'trainee_id': traineeId,
            'weekday': day.weekday,
            'label': day.label,
          });
          for (final pde in day.exercises) {
            final exId = nameToId[pde.exerciseName.toLowerCase()];
            if (exId == null) continue;
            await txn.insert('plan_day_exercises', {
              'plan_day_id': planDayId,
              'exercise_id': exId,
              'order_index': pde.orderIndex,
              'notes': pde.notes,
            });
          }
        }

        // Sessions
        for (final s in t.sessions) {
          final sessionId = await txn.insert('sessions', {
            'trainee_id': traineeId,
            'plan_day_id': null,
            'date': s.date,
            'notes': s.notes,
            'started_at': s.startedAt,
            'ended_at': s.endedAt,
          });
          for (final se in s.exercises) {
            final exId = nameToId[se.exerciseName.toLowerCase()];
            if (exId == null) continue;
            final seId = await txn.insert('session_exercises', {
              'session_id': sessionId,
              'exercise_id': exId,
              'order_index': se.orderIndex,
              'notes': se.notes,
            });
            for (final st in se.sets) {
              await txn.insert('sets', {
                'session_exercise_id': seId,
                'set_number': st.setNumber,
                'reps': st.reps,
                'weight_kg': st.weightKg,
                'duration_seconds': st.durationSeconds,
                'completed': st.completed ? 1 : 0,
              });
            }
          }
        }
      }

      return ImportResult(
        traineesImported: preview._trainees.length,
        exercisesCreated: created,
        exercisesReused: reused,
      );
    });
  }

  // ── Parsing helpers ──────────────────────────────────────────────────────────

  void _validateVersion(Map<String, dynamic> json) {
    if (!json.containsKey('version')) {
      throw ImportException('Missing version field.');
    }
    if (json['version'] != _currentVersion) {
      throw ImportException(
          'Unsupported file version: ${json['version']}. This app supports version $_currentVersion only.');
    }
    if (json['trainees'] is! List) {
      throw ImportException('Invalid structure: "trainees" must be a list.');
    }
  }

  List<_TraineeImportData> _parsePayload(Map<String, dynamic> json) {
    final traineeList = json['trainees'] as List;
    final result = <_TraineeImportData>[];
    for (var i = 0; i < traineeList.length; i++) {
      final t = traineeList[i];
      if (t is! Map<String, dynamic>) {
        throw ImportException('Invalid trainee at index $i: expected an object.');
      }
      result.add(_parseTrainee(t, i));
    }
    return result;
  }

  _TraineeImportData _parseTrainee(Map<String, dynamic> t, int idx) {
    final name = t['name'];
    if (name is! String || name.isEmpty) {
      throw ImportException('Trainee[$idx]: "name" must be a non-empty string.');
    }

    final createdAt = t['createdAt'];
    if (createdAt is! int) {
      throw ImportException('Trainee[$idx]: "createdAt" must be an integer.');
    }

    // Exercises
    final exercises = <_ExerciseRef>[];
    final exList = t['exercises'];
    if (exList is List) {
      for (var j = 0; j < exList.length; j++) {
        final e = exList[j];
        if (e is! Map<String, dynamic>) continue;
        final eName = e['name'];
        if (eName is! String || eName.isEmpty) continue;
        exercises.add(_ExerciseRef(
          name: eName,
          category: e['category'] as String?,
          muscleFocus: e['muscleFocus'] as String?,
        ));
      }
    }

    // Plan
    final plan = <_PlanDayData>[];
    final planList = t['plan'];
    if (planList is List) {
      for (final d in planList) {
        if (d is! Map<String, dynamic>) continue;
        final weekday = d['weekday'];
        if (weekday is! int) continue;
        final dayExercises = <_PlanDayExerciseData>[];
        final deList = d['exercises'];
        if (deList is List) {
          for (final de in deList) {
            if (de is! Map<String, dynamic>) continue;
            final deName = de['exerciseName'];
            if (deName is! String || deName.isEmpty) continue;
            dayExercises.add(_PlanDayExerciseData(
              exerciseName: deName,
              orderIndex: (de['orderIndex'] as int?) ?? 0,
              notes: de['notes'] as String?,
            ));
          }
        }
        plan.add(_PlanDayData(
          weekday: weekday,
          label: d['label'] as String?,
          exercises: dayExercises,
        ));
      }
    }

    // Sessions
    final sessions = <_SessionData>[];
    final sessList = t['sessions'];
    if (sessList is List) {
      for (final s in sessList) {
        if (s is! Map<String, dynamic>) continue;
        final date = s['date'];
        if (date is! String || date.isEmpty) continue;
        final sessExercises = <_SessionExerciseData>[];
        final seList = s['exercises'];
        if (seList is List) {
          for (final se in seList) {
            if (se is! Map<String, dynamic>) continue;
            final seName = se['exerciseName'];
            if (seName is! String || seName.isEmpty) continue;
            final sets = <_SetData>[];
            final setList = se['sets'];
            if (setList is List) {
              for (final st in setList) {
                if (st is! Map<String, dynamic>) continue;
                final setNum = st['setNumber'];
                if (setNum is! int) continue;
                sets.add(_SetData(
                  setNumber: setNum,
                  reps: st['reps'] as int?,
                  weightKg: (st['weightKg'] as num?)?.toDouble(),
                  durationSeconds: st['durationSeconds'] as int?,
                  completed: (st['completed'] as bool?) ?? true,
                ));
              }
            }
            sessExercises.add(_SessionExerciseData(
              exerciseName: seName,
              orderIndex: (se['orderIndex'] as int?) ?? 0,
              notes: se['notes'] as String?,
              sets: sets,
            ));
          }
        }
        sessions.add(_SessionData(
          date: date,
          notes: s['notes'] as String?,
          startedAt: s['startedAt'] as int?,
          endedAt: s['endedAt'] as int?,
          exercises: sessExercises,
        ));
      }
    }

    return _TraineeImportData(
      name: name,
      notes: t['notes'] as String?,
      createdAt: createdAt,
      exercises: exercises,
      plan: plan,
      sessions: sessions,
    );
  }
}
