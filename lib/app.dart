import 'package:flutter/material.dart';
import 'features/exercises/screens/exercise_library_screen.dart';
import 'features/trainees/screens/trainee_list_screen.dart';

class GymTrainLogApp extends StatelessWidget {
  const GymTrainLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTrainLog',
      debugShowCheckedModeBanner: false,
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Trainees',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
        ],
      ),
    );
  }
}
