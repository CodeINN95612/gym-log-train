import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/exercise.dart';
import '../../features/exercises/providers/exercise_provider.dart';
import '../../features/exercises/screens/add_exercise_screen.dart';
import 'category_badge.dart';

Future<Exercise?> showExercisePickerSheet(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => ChangeNotifierProvider.value(
      value: context.read<ExerciseProvider>(),
      child: const _ExercisePickerSheet(),
    ),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet();

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseProvider>();
    final filtered = provider.exercises.where((e) {
      if (_search.isEmpty) return true;
      return e.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search exercises…',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    final newEx = await showAddExerciseSheet(context);
                    if (newEx != null && context.mounted) {
                      Navigator.pop(context, newEx);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: filtered.isEmpty
                ? const Center(child: Text('No exercises found'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final ex = filtered[i];
                      return ListTile(
                        title: Text(ex.name),
                        trailing: CategoryBadge(category: ex.category),
                        onTap: () => Navigator.pop(context, ex),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
