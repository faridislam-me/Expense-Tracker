import 'package:intl/intl.dart';

class MonthKeyHelper {
  MonthKeyHelper._();

  static final _monthKeyFormat = DateFormat('yyyy-MM');

  static String current() => _monthKeyFormat.format(DateTime.now());

  static String fromDate(DateTime date) => _monthKeyFormat.format(date);

  static DateTime toDate(String monthKey) {
    final parts = monthKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  static String displayName(String monthKey) {
    final date = toDate(monthKey);
    return DateFormat('MMMM yyyy').format(date);
  }

  static String previous(String monthKey) {
    final date = toDate(monthKey);
    final prev = DateTime(date.year, date.month - 1);
    return fromDate(prev);
  }

  static String next(String monthKey) {
    final date = toDate(monthKey);
    final nxt = DateTime(date.year, date.month + 1);
    return fromDate(nxt);
  }

  static List<String> generateKeys({int count = 12}) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final date = DateTime(now.year, now.month - i);
      return fromDate(date);
    });
  }
}
