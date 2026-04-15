import 'package:flutter_test/flutter_test.dart';
import 'package:gym_train_log/core/utils/weight_utils.dart';

void main() {
  group('kgToUnit', () {
    test('returns kg unchanged when unit is kg', () {
      expect(kgToUnit(80.0, WeightUnit.kg), closeTo(80.0, 0.0001));
    });

    test('converts 1 kg to lbs correctly', () {
      expect(kgToUnit(1.0, WeightUnit.lbs), closeTo(2.20462, 0.0001));
    });

    test('converts 100 kg to lbs', () {
      expect(kgToUnit(100.0, WeightUnit.lbs), closeTo(220.462, 0.001));
    });

    test('returns null for null input with lbs', () {
      expect(kgToUnit(null, WeightUnit.lbs), isNull);
    });

    test('returns null for null input with kg', () {
      expect(kgToUnit(null, WeightUnit.kg), isNull);
    });
  });

  group('unitToKg', () {
    test('returns kg unchanged when unit is kg', () {
      expect(unitToKg(80.0, WeightUnit.kg), closeTo(80.0, 0.0001));
    });

    test('converts 1 lbs to kg correctly', () {
      expect(unitToKg(1.0, WeightUnit.lbs), closeTo(0.453592, 0.0001));
    });

    test('converts 22 lbs to kg', () {
      // 22 * 0.453592 = 9.979024
      expect(unitToKg(22.0, WeightUnit.lbs), closeTo(9.979024, 0.0001));
    });

    test('returns null for null input with lbs', () {
      expect(unitToKg(null, WeightUnit.lbs), isNull);
    });

    test('returns null for null input with kg', () {
      expect(unitToKg(null, WeightUnit.kg), isNull);
    });
  });

  group('roundTo1dp', () {
    test('rounds 9.979 down to 10.0', () {
      expect(roundTo1dp(9.979024), closeTo(10.0, 0.0001));
    });

    test('rounds 9.95 up to 10.0', () {
      expect(roundTo1dp(9.95), closeTo(10.0, 0.0001));
    });

    test('leaves already-rounded value unchanged', () {
      expect(roundTo1dp(80.5), closeTo(80.5, 0.0001));
    });

    test('handles zero', () {
      expect(roundTo1dp(0.0), closeTo(0.0, 0.0001));
    });

    test('rounds 45.449 to 45.4', () {
      expect(roundTo1dp(45.449), closeTo(45.4, 0.0001));
    });
  });

  group('formatWeight', () {
    test('formats kg to 1dp string', () {
      expect(formatWeight(80.0, WeightUnit.kg), '80.0');
    });

    test('formats lbs conversion from 80 kg to 1dp string', () {
      // 80 * 2.20462 = 176.3696 → 176.4
      expect(formatWeight(80.0, WeightUnit.lbs), '176.4');
    });

    test('returns empty string for null kg', () {
      expect(formatWeight(null, WeightUnit.kg), '');
    });

    test('returns empty string for null lbs', () {
      expect(formatWeight(null, WeightUnit.lbs), '');
    });

    test('round-trip: 22 lbs stored as kg displays back within 0.1 lbs', () {
      // User enters 22 lbs → stored as kg (rounded to 1dp) → displayed as lbs
      final kg = roundTo1dp(unitToKg(22.0, WeightUnit.lbs)!); // 10.0
      final backToLbs = kgToUnit(kg, WeightUnit.lbs)!; // 10.0 * 2.20462 = 22.0462
      expect(backToLbs, closeTo(22.0, 0.1));
    });
  });

  group('unitLabel', () {
    test('returns kg for WeightUnit.kg', () {
      expect(unitLabel(WeightUnit.kg), 'kg');
    });

    test('returns lbs for WeightUnit.lbs', () {
      expect(unitLabel(WeightUnit.lbs), 'lbs');
    });
  });
}
