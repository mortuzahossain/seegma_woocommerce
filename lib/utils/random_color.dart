import 'package:flutter/material.dart';

final List<Color> _rowColors = [
  Colors.blueAccent,
  Colors.green,
  Colors.deepOrange,
  Colors.teal,
  Colors.purple,
  Colors.indigo,
  Colors.redAccent,
  Colors.amber,
];

Color getRowColor(int index) {
  return _rowColors[index % _rowColors.length];
}
