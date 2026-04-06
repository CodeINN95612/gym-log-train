import 'package:flutter_test/flutter_test.dart';
import 'package:gym_train_log/core/utils/date_utils.dart';

void main() {
  group('toDateString', () {
    test('formats date correctly', () {
      final dt = DateTime(2024, 3, 5);
      expect(toDateString(dt), '2024-03-05');
    });

    test('pads single digit month and day', () {
      final dt = DateTime(2024, 1, 9);
      expect(toDateString(dt), '2024-01-09');
    });
  });

  group('fromDateString', () {
    test('parses YYYY-MM-DD correctly', () {
      final dt = fromDateString('2024-03-05');
      expect(dt.year, 2024);
      expect(dt.month, 3);
      expect(dt.day, 5);
    });

    test('round-trips through toDateString', () {
      final original = DateTime(2025, 12, 31);
      final str = toDateString(original);
      final parsed = fromDateString(str);
      expect(parsed.year, original.year);
      expect(parsed.month, original.month);
      expect(parsed.day, original.day);
    });
  });

  group('weekdayName', () {
    test('returns correct names for 0-6', () {
      expect(weekdayName(0), 'Monday');
      expect(weekdayName(1), 'Tuesday');
      expect(weekdayName(2), 'Wednesday');
      expect(weekdayName(3), 'Thursday');
      expect(weekdayName(4), 'Friday');
      expect(weekdayName(5), 'Saturday');
      expect(weekdayName(6), 'Sunday');
    });

    test('wraps around with modulo', () {
      expect(weekdayName(7), 'Monday');
    });
  });

  group('dartWeekdayToIndex', () {
    test('Monday = 0', () {
      // DateTime.monday = 1
      final monday = DateTime(2024, 3, 4); // a known Monday
      expect(dartWeekdayToIndex(monday), 0);
    });

    test('Sunday = 6', () {
      final sunday = DateTime(2024, 3, 10); // a known Sunday
      expect(dartWeekdayToIndex(sunday), 6);
    });
  });
}
