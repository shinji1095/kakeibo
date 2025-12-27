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

List<({DateTime start, DateTime end})> buildPeriodRanges(
  DateTime currentStart,
  int length,
  int count,
) {
  final safeLength = length <= 0 ? 35 : length;
  final safeCount = count <= 0 ? 0 : count;

  return List.generate(safeCount, (i) {
    final stepsFromCurrent = safeCount - 1 - i;
    final start = currentStart.subtract(Duration(days: safeLength * stepsFromCurrent));
    final end = start.add(Duration(days: safeLength));
    return (start: start, end: end);
  });
}

List<({DateTime start, DateTime end})> buildWeekRanges(
  DateTime baseStart,
  DateTime anchorDate,
  int count,
) {
  final safeCount = count <= 0 ? 0 : count;
  if (safeCount == 0) return const [];

  final normalizedStart = truncateDate(baseStart);
  final normalizedAnchor = truncateDate(anchorDate);
  final diffDays = normalizedAnchor.difference(normalizedStart).inDays;
  final weekIndex = diffDays < 0 ? 0 : diffDays ~/ 7;
  final currentWeekStart = normalizedStart.add(Duration(days: weekIndex * 7));

  return List.generate(safeCount, (i) {
    final stepsFromCurrent = safeCount - 1 - i;
    final start = currentWeekStart.subtract(Duration(days: 7 * stepsFromCurrent));
    final end = start.add(const Duration(days: 7));
    return (start: start, end: end);
  });
}
