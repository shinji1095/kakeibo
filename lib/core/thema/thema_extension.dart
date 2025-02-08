import 'package:flutter/material.dart';

extension ThemeTextStyles on BuildContext {
  TextStyle get headline1 => Theme.of(this).textTheme.displayLarge!;
  TextStyle get headline2 => Theme.of(this).textTheme.displayMedium!;
  TextStyle get bodyText1 => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyText2 => Theme.of(this).textTheme.bodyMedium!;
}

extension ThemeColors on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
}
