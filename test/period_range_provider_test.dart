import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/core/utils/period_utils.dart';
import 'package:kakeibo/presentation/providers/settings_provider.dart';
import 'package:kakeibo/presentation/providers/transactions_provider.dart';

void main() {
  test('periodRangeProvider uses period length and offset', () {
    final notifier = SettingsNotifier();
    notifier.setKakeiboStartDate(DateTime(2024, 1, 1));
    notifier.setPeriodLengthDays(42);

    final container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith((ref) => notifier),
      ],
    );
    addTearDown(container.dispose);

    final expectedStart = currentPeriodStart(
      DateTime(2024, 1, 1),
      42,
      DateTime.now(),
    );

    final range = container.read(periodRangeProvider);
    expect(range.start, expectedStart);
    expect(range.end, expectedStart.add(const Duration(days: 42)));

    container.read(periodOffsetProvider.notifier).state = 1;
    final nextRange = container.read(periodRangeProvider);
    expect(nextRange.start, expectedStart.add(const Duration(days: 42)));
  });
}