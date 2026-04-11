import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

// A known Monday to use as anchor for locale-aware weekday formatting.
final _anchorMonday = DateTime(2023, 1, 2);

String weekdayNameLocalized(int weekday, String locale) {
  return DateFormat('EEEE', locale).format(_anchorMonday.add(Duration(days: weekday)));
}

String weekdayShortLocalized(int weekday, String locale) {
  return DateFormat('E', locale).format(_anchorMonday.add(Duration(days: weekday)));
}

String toDateString(DateTime date) => _dateFormat.format(date);

DateTime fromDateString(String s) => _dateFormat.parse(s);

String weekdayName(int weekday) {
  const names = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  return names[weekday % 7];
}

String weekdayShort(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday % 7];
}

/// Returns weekday index 0=Monday for a given DateTime.
int dartWeekdayToIndex(DateTime date) => date.weekday - 1;
