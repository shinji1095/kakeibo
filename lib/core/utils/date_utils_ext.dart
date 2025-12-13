class DateUtilsExt {
  static String ymdJP(DateTime d) => '${d.year}年${d.month}月${d.day}日';
  static DateTime firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  static DateTime lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);
}
