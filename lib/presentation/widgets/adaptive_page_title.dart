import 'package:flutter/material.dart';

/// Keeps page titles on one line while using all available AppBar width.
class AdaptivePageTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AdaptivePageTitle(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: style ??
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.normal),
        ),
      );
}
