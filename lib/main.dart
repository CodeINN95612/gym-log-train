import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'features/exercises/providers/exercise_provider.dart';
import 'features/trainees/providers/trainee_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Warm up the database connection before the first frame.
  await DatabaseHelper.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()..load()),
        ChangeNotifierProvider(create: (_) => TraineeProvider()..load()),
      ],
      child: const GymTrainLogApp(),
    ),
  );
}
