import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/exercise_categories.dart';
import '../../../shared/widgets/category_badge.dart';
import '../providers/exercise_provider.dart';
import 'add_exercise_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ExerciseProvider>().load(
          search: _searchCtrl.text,
          category: _selectedCategory,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExerciseSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search exercises…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() => _selectedCategory = null);
                      _applyFilters();
                    },
                  ),
                ),
                ...kExerciseCategories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) {
                          setState(() => _selectedCategory =
                              _selectedCategory == cat ? null : cat);
                          _applyFilters();
                        },
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.exercises.isEmpty
                    ? const Center(
                        child: Text('No exercises found.\nTap + to add one.',
                            textAlign: TextAlign.center),
                      )
                    : ListView.separated(
                        itemCount: provider.exercises.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final ex = provider.exercises[i];
                          return ListTile(
                            title: Text(ex.name),
                            trailing: ExerciseBadges(
                              category: ex.category,
                              muscleFocus: ex.muscleFocus,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
