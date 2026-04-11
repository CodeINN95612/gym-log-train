import 'package:flutter/material.dart';
import 'package:gym_train_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/trainee_provider.dart';

class AddTraineeScreen extends StatefulWidget {
  const AddTraineeScreen({super.key});

  @override
  State<AddTraineeScreen> createState() => _AddTraineeScreenState();
}

class _AddTraineeScreenState extends State<AddTraineeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final trainee = await context
        .read<TraineeProvider>()
        .addTrainee(_nameCtrl.text, _notesCtrl.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (trainee != null) Navigator.pop(context, trainee);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newTrainee)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.fieldName,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.fieldNameRequired : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: l10n.fieldNotes,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
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
      ),
    );
  }
}
