import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakeibo/app.dart';
import 'package:kakeibo/core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  await configureDependencies(); // set up DI / DB

  runApp(const ProviderScope(child: KakeiboApp()));
}
