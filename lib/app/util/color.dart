import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  // Primary Colors
  static const Color primary = Color(0xFFBF5656);
  static const Color accent = Color(0xFFE57373);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color progressBackground = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static Color textLabel = Colors.grey.shade600;

  // Icon Colors
  static const Color icon = Colors.grey;
  static Color iconRefresh = Colors.red.shade400;

  // Divider & Border Colors
  static Color divider = Colors.grey.shade200;
  static Color border = Colors.grey.shade300;

  // Shadow
  static Color shadow = Colors.black.withValues(alpha: 0.1);
}
