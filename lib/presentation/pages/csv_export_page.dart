import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/core/di/injector.dart';
import 'package:kakeibo/core/localization/app_localizations.dart';
import 'package:kakeibo/domain/entities/transaction.dart';
import 'package:kakeibo/domain/usecases/get_transactions_by_range.dart';
import 'package:kakeibo/presentation/providers/categories_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportPage extends ConsumerStatefulWidget {
  const CsvExportPage({super.key});

  @override
  ConsumerState<CsvExportPage> createState() => _CsvExportPageState();
}

class _CsvExportPageState extends ConsumerState<CsvExportPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isExporting = false;
  String? _exportPath;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickStartDate(AppLocalizations l10n) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _startDate,
      locale: l10n.locale,
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate(AppLocalizations l10n) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _endDate,
      locale: l10n.locale,
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _exportCsv(AppLocalizations l10n) async {
    if (_startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.csvInvalidRange)),
      );
      return;
    }

    if (!sl.isRegistered<GetTransactionsByRange>()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.csvExportUnavailable)),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final use = sl<GetTransactionsByRange>();
      final endExclusive = _endDate.add(const Duration(days: 1));
      final transactions = await use(_startDate, endExclusive);
      final categories = await ref.read(categoriesProvider.future);
      final categoryMap = {
        for (final c in categories)
          if (c.id != null) c.id!: c.name,
      };

      final header = [
        l10n.csvColumnDate,
        l10n.csvColumnCategory,
        l10n.csvColumnType,
        l10n.csvColumnAmount,
        l10n.csvColumnAttribute,
      ];

      final rows = <List<String>>[header];
      for (final tx in transactions) {
        final typeLabel = tx.type == TransactionType.expense ? l10n.typeExpense : l10n.typeIncome;
        final attrLabel = tx.type == TransactionType.expense
            ? l10n.expenseAttributeLabel(tx.expenseAttribute ?? kDefaultExpenseAttribute)
            : '';
        rows.add([
          l10n.formatDate(tx.date),
          categoryMap[tx.categoryId] ?? l10n.categoryFallback(tx.categoryId),
          typeLabel,
          tx.amount.value.toString(),
          attrLabel,
        ]);
      }

      final csv = rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'kakeibo_${_formatDate(_startDate)}_${_formatDate(_endDate)}.csv';
      final file = File(p.join(dir.path, fileName));
      await file.writeAsString(csv, encoding: const Utf8Codec());
      if (!mounted) return;
      setState(() => _exportPath = file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.csvSavedMessage(file.path))),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _shareCsv(AppLocalizations l10n) async {
    final path = _exportPath;
    if (path == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.csvShareWarningTitle),
        content: Text(l10n.csvShareWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.csvShareConfirm),
          ),
        ],
      ),
    );
    if (ok == true) {
      await Share.shareXFiles([XFile(path)]);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  String _escapeCsv(String value) {
    final needsQuote = value.contains(',') || value.contains('"') || value.contains('\n');
    if (!needsQuote) return value;
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.csvExportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.csvRangeTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickStartDate(l10n),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.csvStartDateLabel),
                      child: Text(l10n.formatLongDate(_startDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _pickEndDate(l10n),
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: l10n.csvEndDateLabel),
                      child: Text(l10n.formatLongDate(_endDate)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : () => _exportCsv(l10n),
                      icon: const Icon(Icons.download),
                      label: Text(_isExporting ? l10n.csvExporting : l10n.csvExportButton),
                    ),
                  ),
                  if (_exportPath != null) ...[
                    const SizedBox(height: 12),
                    Text('${l10n.csvFilePathLabel}: $_exportPath'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _shareCsv(l10n),
                        icon: const Icon(Icons.share),
                        label: Text(l10n.csvShareButton),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
