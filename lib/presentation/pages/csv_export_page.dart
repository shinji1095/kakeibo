import 'package:flutter/material.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/presentation/widgets/placeholder_page.dart';

class CsvExportPage extends StatelessWidget {
  const CsvExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(
      title: l10n.csvExportTitle,
      message: l10n.csvExportPlaceholder,
    );
  }
}
