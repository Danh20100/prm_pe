import 'package:intl/intl.dart';

final DateFormat _storedDate = DateFormat('yyyy-MM-dd');
final DateFormat _shownDate = DateFormat('dd/MM/yyyy');

String storeStudentDate(DateTime date) => _storedDate.format(date);

DateTime? parseStoredDate(String value) {
  try {
    return _storedDate.parseStrict(value);
  } on FormatException {
    return null;
  }
}

String formatStudentDate(String stored) {
  final parsed = parseStoredDate(stored);
  if (parsed == null) return stored;
  return _shownDate.format(parsed);
}
