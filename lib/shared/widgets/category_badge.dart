import 'package:flutter/material.dart';

const _categoryColors = <String, Color>{
  'Push': Color(0xFFEF9A9A),
  'Pull': Color(0xFF90CAF9),
  'Hinge': Color(0xFFA5D6A7),
  'Squat': Color(0xFFCE93D8),
  'Lunge': Color(0xFFFFCC80),
  'Core': Color(0xFF80DEEA),
  'Cardio': Color(0xFFF48FB1),
  'Full Body': Color(0xFFFFE082),
  'Other': Color(0xFFB0BEC5),
};

const _focusColors = <String, Color>{
  'Chest': Color(0xFFEF9A9A),
  'Upper Back': Color(0xFF90CAF9),
  'Lower Back': Color(0xFF80CBC4),
  'Shoulders': Color(0xFFFFCC80),
  'Biceps': Color(0xFFA5D6A7),
  'Triceps': Color(0xFFCE93D8),
  'Quads': Color(0xFFB39DDB),
  'Hamstrings': Color(0xFF80DEEA),
  'Glutes': Color(0xFFF48FB1),
  'Calves': Color(0xFFFFE082),
  'Abs': Color(0xFF80CBC4),
  'Obliques': Color(0xFFBCAAA4),
  'Other': Color(0xFFB0BEC5),
};

/// Shows the movement pattern badge.
class CategoryBadge extends StatelessWidget {
  final String? category;

  const CategoryBadge({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    if (category == null) return const SizedBox.shrink();
    final color = _categoryColors[category] ?? _categoryColors['Other']!;
    return _badge(category!, color);
  }
}

/// Shows movement pattern + muscle focus as two small badges.
class ExerciseBadges extends StatelessWidget {
  final String? category;
  final String? muscleFocus;

  const ExerciseBadges({super.key, this.category, this.muscleFocus});

  @override
  Widget build(BuildContext context) {
    if (category == null && muscleFocus == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        if (category != null)
          _badge(
            category!,
            _categoryColors[category] ?? _categoryColors['Other']!,
          ),
        if (muscleFocus != null)
          _badge(
            muscleFocus!,
            _focusColors[muscleFocus] ?? _focusColors['Other']!,
          ),
      ],
    );
  }
}

Widget _badge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(45),
        border: Border.all(color: color.withAlpha(130)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color.withAlpha(230),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
