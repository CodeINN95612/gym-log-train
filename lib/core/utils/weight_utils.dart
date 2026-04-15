enum WeightUnit { kg, lbs }

const double _kgToLbs = 2.20462;
const double _lbsToKg = 0.453592;

/// Convert a kg value to the target unit. Returns null if [kg] is null.
double? kgToUnit(double? kg, WeightUnit unit) {
  if (kg == null) return null;
  return unit == WeightUnit.kg ? kg : kg * _kgToLbs;
}

/// Convert a value in [unit] back to kg. Returns null if [value] is null.
double? unitToKg(double? value, WeightUnit unit) {
  if (value == null) return null;
  return unit == WeightUnit.kg ? value : value * _lbsToKg;
}

/// Round to 1 decimal place (used for kg storage and display).
double roundTo1dp(double value) => (value * 10).round() / 10.0;

/// Format a kg value for display in the given unit, rounded to 1 dp.
/// Returns an empty string for null.
String formatWeight(double? kg, WeightUnit unit) {
  if (kg == null) return '';
  return roundTo1dp(kgToUnit(kg, unit)!).toStringAsFixed(1);
}

/// Label string for the unit, e.g. "kg" or "lbs".
String unitLabel(WeightUnit unit) => unit == WeightUnit.kg ? 'kg' : 'lbs';
