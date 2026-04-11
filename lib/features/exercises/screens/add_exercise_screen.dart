import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/exercise_categories.dart';
import '../../../core/models/exercise.dart';
import '../../../core/providers/settings_provider.dart';
import '../providers/exercise_provider.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key});

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedMuscleFocus;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<ExerciseProvider>();
    final lang = context.read<SettingsProvider>().language;
    provider.clearDuplicateError();
    final exercise = await provider.addExercise(
        _nameCtrl.text, _selectedCategory, _selectedMuscleFocus,
        language: lang);
    if (!mounted) return;
    setState(() => _saving = false);
    if (exercise != null) Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<ExerciseProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.newExercise,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.fieldName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldNameRequired : null,
                onChanged: (_) {
                  if (provider.isDuplicate) {
                    provider.clearDuplicateError();
                  }
                },
              ),
              if (provider.isDuplicate) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.duplicateExercise(_nameCtrl.text.trim()),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: l10n.fieldMovementPattern,
                  hintText: l10n.hintMovementPattern,
                  border: const OutlineInputBorder(),
                ),
                items: kExerciseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedMuscleFocus,
                decoration: InputDecoration(
                  labelText: l10n.fieldMuscleFocus,
                  hintText: l10n.hintMuscleFocus,
                  border: const OutlineInputBorder(),
                ),
                items: kMuscleFocus
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedMuscleFocus = v),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Exercise?> showAddExerciseSheet(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => ChangeNotifierProvider.value(
      value: context.read<ExerciseProvider>(),
      child: const AddExerciseSheet(),
    ),
  );
}
