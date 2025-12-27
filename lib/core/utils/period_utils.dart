DateTime truncateDate(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime currentPeriodStart(DateTime start, int length, DateTime today) {
  final normalizedStart = truncateDate(start);
  final normalizedToday = truncateDate(today);
  final safeLength = length <= 0 ? 35 : length;

  if (normalizedToday.isBefore(normalizedStart)) {
    return normalizedStart;
  }

  final diffDays = normalizedToday.difference(normalizedStart).inDays;
  final offset = diffDays ~/ safeLength;
  return normalizedStart.add(Duration(days: offset * safeLength));
}