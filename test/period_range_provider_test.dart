import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

void main() {
  test('periodRangeProvider uses default period length and offset', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final now = DateTime.now();
    final expectedStart = currentPeriodStart(DateTime(now.year, 1, 1), 35, now);

    final range = container.read(periodRangeProvider);
    expect(range.start, expectedStart);
    expect(range.end, expectedStart.add(const Duration(days: 35)));

    container.read(periodOffsetProvider.notifier).state = 1;
    final nextRange = container.read(periodRangeProvider);
    expect(nextRange.start, expectedStart.add(const Duration(days: 35)));
  });
}
