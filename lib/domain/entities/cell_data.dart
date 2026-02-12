import 'package:flutter/material.dart';

enum CellColor { blue, yellow, red }

extension CellColorX on CellColor {
  Color get color {
    switch (this) {
      case CellColor.blue:
        return const Color(0xFF2C8DFF);
      case CellColor.yellow:
        return const Color(0xFFF2C227);
      case CellColor.red:
        return const Color(0xFFF5484A);
    }
  }
}

class CellData {
  const CellData({required this.color, required this.value});

  final CellColor color;
  final int value;
}
