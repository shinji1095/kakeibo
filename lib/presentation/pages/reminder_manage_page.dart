import 'package:flutter/material.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/widgets/placeholder_page.dart';

class ReminderManagePage extends StatelessWidget {
  const ReminderManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.reminderManageTitle,
      message: l10n.reminderManagePlaceholder,
    );
  }
}
