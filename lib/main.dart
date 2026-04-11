import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/providers/settings_provider.dart';
import 'features/exercises/providers/exercise_provider.dart';
import 'features/trainees/providers/trainee_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Warm up the database connection before the first frame.
  await DatabaseHelper.instance.database;

  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider()..load(language: settings.language),
        ),
        ChangeNotifierProvider(create: (_) => TraineeProvider()..load()),
      ],
      child: const GymTrainLogApp(),
    ),
  );
}
