import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/presentation/providers/home_provider.dart';
import 'package:kakeibo/presentation/widgets/app_scaffold.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _yen(int v) {
    final sign = v < 0 ? '-' : '';
    final n = v.abs();
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    return '$sign${buf.toString()}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);

    return AppScaffold(
      title: 'ホーム',
      currentIndex: 0,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: statsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, st) => Text('Error: $e'),
            data: (stats) {
              if (stats == null) {
                return Text(
                  '固定支出を設定してください',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                );
              }

              final bonusText = stats.isBonusMonth
                  ? '今月はボーナス月です'
                  : 'ボーナス月まであと${stats.daysUntilNextBonusMonthStart}日';

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bonusText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '今月終了まであと${stats.daysUntilMonthEnd}日',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '差額（先月の収入 - 今月の支出）: ${_yen(stats.diff)}円',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
