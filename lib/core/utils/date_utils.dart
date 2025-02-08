class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
}