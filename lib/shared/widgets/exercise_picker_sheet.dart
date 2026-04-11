import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/models/exercise.dart';
import '../../core/providers/settings_provider.dart';
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
      final lang = context.read<SettingsProvider>().language;
      context.read<ExerciseProvider>().load(language: lang);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    decoration: InputDecoration(
                      hintText: l10n.searchExercises,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.newExerciseButton),
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
                ? Center(child: Text(l10n.noExercisesInPicker))
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
