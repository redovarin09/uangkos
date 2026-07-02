import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary — Teal Green
  static const Color primary      = Color(0xFF1DB87E);
  static const Color primaryDark  = Color(0xFF158F60);
  static const Color primaryLight = Color(0xFFE8F8F1);

  // Status
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger       = Color(0xFFF43F5E);
  static const Color dangerLight  = Color(0xFFFFE4E8);

  // Light Mode
  static const Color backgroundLight    = Color(0xFFF8FAF9);
  static const Color surfaceLight       = Color(0xFFFFFFFF);
  static const Color cardLight          = Color(0xFFFFFFFF);
  static const Color textPrimaryLight   = Color(0xFF0F1A14);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight       = Color(0xFFE5E7EB);

  // Dark Mode
  static const Color backgroundDark    = Color(0xFF0F1A14);
  static const Color surfaceDark       = Color(0xFF1A2E22);
  static const Color cardDark          = Color(0xFF1F3828);
  static const Color textPrimaryDark   = Color(0xFFF0FDF4);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark       = Color(0xFF2D4A38);
}
