import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/utils/period_utils.dart';

void main() {
  group('truncateDate', () {
    test('removes time components', () {
      final input = DateTime(2024, 1, 2, 15, 30, 45);
      final result = truncateDate(input);
      expect(result, DateTime(2024, 1, 2));
    });
  });

  group('currentPeriodStart', () {
    test('uses start when today is before start', () {
      final start = DateTime(2024, 1, 10);
      final today = DateTime(2024, 1, 5);
      expect(currentPeriodStart(start, 35, today), DateTime(2024, 1, 10));
    });

    test('stays in first period within length', () {
      final start = DateTime(2024, 1, 1);
      final today = DateTime(2024, 2, 4); // 34 days later
      expect(currentPeriodStart(start, 35, today), DateTime(2024, 1, 1));
    });

    test('moves to next period on boundary', () {
      final start = DateTime(2024, 1, 1);
      final today = DateTime(2024, 2, 5); // 35 days later
      expect(currentPeriodStart(start, 35, today), DateTime(2024, 2, 5));
    });

    test('defaults to 35 when length is invalid', () {
      final start = DateTime(2024, 1, 1);
      final today = DateTime(2024, 2, 5);
      expect(currentPeriodStart(start, 0, today), DateTime(2024, 2, 5));
    });
  });

  group('buildPeriodRanges', () {
    test('returns chronological ranges ending at current', () {
      final currentStart = DateTime(2024, 2, 5);
      final ranges = buildPeriodRanges(currentStart, 35, 3);

      expect(ranges.length, 3);
      expect(ranges.first.start, currentStart.subtract(const Duration(days: 70)));
      expect(ranges[1].start, currentStart.subtract(const Duration(days: 35)));
      expect(ranges.last.start, currentStart);
      expect(ranges.last.end, currentStart.add(const Duration(days: 35)));
    });

    test('returns empty list when count is zero', () {
      final ranges = buildPeriodRanges(DateTime(2024, 1, 1), 35, 0);
      expect(ranges, isEmpty);
    });
  });
}
