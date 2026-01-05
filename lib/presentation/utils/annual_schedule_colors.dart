import 'package:flutter/material.dart';

List<Color> buildAnnualScheduleColors(int count) {
  if (count <= 0) return const [];
  return List.generate(count, (index) {
    final hue = (360.0 / count) * index;
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.75).toColor();
  });
}
