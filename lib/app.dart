import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/settings_provider.dart';
import 'features/exercises/screens/exercise_library_screen.dart';
import 'features/trainees/screens/trainee_list_screen.dart';

class GymTrainLogApp extends StatelessWidget {
  const GymTrainLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsProvider>().locale;
    return MaterialApp(
      title: 'GymTrainLog',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatefulWidget {
  const _RootScaffold();

  @override
  State<_RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<_RootScaffold> {
  int _currentIndex = 0;

  static const _screens = [
    TraineeListScreen(),
    ExerciseLibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: l10n.navTrainees,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: l10n.navExercises,
          ),
        ],
      ),
    );
  }
}
