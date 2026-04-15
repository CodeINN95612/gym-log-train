import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/models/set_entry.dart';
import '../../core/utils/weight_utils.dart';
import '../../features/sessions/providers/session_provider.dart';

class SetRowWidget extends StatefulWidget {
  final SetEntry set;
  final bool readOnly;
  final WeightUnit weightUnit;
  final bool showWeight;
  final bool showReps;
  final bool showDuration;

  const SetRowWidget({
    super.key,
    required this.set,
    this.readOnly = false,
    this.weightUnit = WeightUnit.kg,
    this.showWeight = true,
    this.showReps = true,
    this.showDuration = false,
  });

  @override
  State<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends State<SetRowWidget> {
  late TextEditingController _repsCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _durationCtrl;
  late FocusNode _repsFocus;
  late FocusNode _weightFocus;
  late FocusNode _durationFocus;

  @override
  void initState() {
    super.initState();
    _repsCtrl = TextEditingController(
        text: widget.set.reps?.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: widget.set.weightKg != null
            ? formatWeight(widget.set.weightKg, widget.weightUnit)
            : '');
    _durationCtrl = TextEditingController(
        text: widget.set.durationSeconds?.toString() ?? '');
    _repsFocus = FocusNode()..addListener(_onRepsFocusChange);
    _weightFocus = FocusNode()..addListener(_onWeightFocusChange);
    _durationFocus = FocusNode()..addListener(_onDurationFocusChange);
  }

  @override
  void didUpdateWidget(SetRowWidget old) {
    super.didUpdateWidget(old);
    if (!_repsFocus.hasFocus) {
      _repsCtrl.text = widget.set.reps?.toString() ?? '';
    }
    if (old.weightUnit != widget.weightUnit) {
      // Unit changed — convert whatever is currently displayed, even if focused.
      final raw = double.tryParse(_weightCtrl.text);
      if (raw != null) {
        final asKg = unitToKg(raw, old.weightUnit)!;
        _weightCtrl.text = formatWeight(asKg, widget.weightUnit);
      }
    } else if (!_weightFocus.hasFocus) {
      // Normal data sync — only skip if user is actively typing.
      _weightCtrl.text = widget.set.weightKg != null
          ? formatWeight(widget.set.weightKg, widget.weightUnit)
          : '';
    }
    if (!_durationFocus.hasFocus) {
      _durationCtrl.text = widget.set.durationSeconds?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    _weightCtrl.dispose();
    _durationCtrl.dispose();
    _repsFocus.dispose();
    _weightFocus.dispose();
    _durationFocus.dispose();
    super.dispose();
  }

  void _onRepsFocusChange() {
    if (!_repsFocus.hasFocus) _saveSet();
  }

  void _onWeightFocusChange() {
    if (!_weightFocus.hasFocus) _saveSet();
  }

  void _onDurationFocusChange() {
    if (!_durationFocus.hasFocus) _saveSet();
  }

  void _saveSet() {
    final reps = int.tryParse(_repsCtrl.text);
    final weightRaw = double.tryParse(_weightCtrl.text);
    final weight = weightRaw != null
        ? roundTo1dp(unitToKg(weightRaw, widget.weightUnit)!)
        : null;
    final duration = int.tryParse(_durationCtrl.text);
    context.read<SessionProvider>().updateSet(widget.set.copyWith(
          reps: reps,
          weightKg: weight,
          durationSeconds: duration,
          clearReps: _repsCtrl.text.isEmpty,
          clearWeightKg: _weightCtrl.text.isEmpty,
          clearDurationSeconds: _durationCtrl.text.isEmpty,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '${widget.set.setNumber}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        if (widget.showWeight) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _fieldInput(
              controller: _weightCtrl,
              focusNode: _weightFocus,
              hint: unitLabel(widget.weightUnit),
              readOnly: widget.readOnly,
            ),
          ),
        ],
        if (widget.showReps) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _fieldInput(
              controller: _repsCtrl,
              focusNode: _repsFocus,
              hint: 'reps',
              readOnly: widget.readOnly,
            ),
          ),
        ],
        if (widget.showDuration) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _fieldInput(
              controller: _durationCtrl,
              focusNode: _durationFocus,
              hint: 'sec',
              readOnly: widget.readOnly,
            ),
          ),
        ],
        if (!widget.readOnly) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
            tooltip: 'Delete set',
            onPressed: () {
              context.read<SessionProvider>().deleteSet(
                    widget.set.id!,
                    widget.set.sessionExerciseId,
                  );
            },
          ),
        ],
      ],
    );
  }

  Widget _fieldInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool readOnly,
  }) {
    if (readOnly) {
      return Text(
        controller.text.isEmpty ? '—' : controller.text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      );
    }
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      ),
      onEditingComplete: _saveSet,
    );
  }
}
