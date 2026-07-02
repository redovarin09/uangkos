import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uang_kos/core/constants/app_colors.dart';

abstract class AppTheme {
  // ─── Text Theme ────────────────────────────────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) {
    final b = GoogleFonts.plusJakartaSansTextTheme();
    return TextTheme(
      displayLarge:  b.displayLarge?.copyWith(color: primary, fontWeight: FontWeight.w700),
      headlineLarge: b.headlineLarge?.copyWith(color: primary, fontWeight: FontWeight.w700),
      headlineMedium:b.headlineMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleLarge:    b.titleLarge?.copyWith(color: primary, fontWeight: FontWeight.w700),
      titleMedium:   b.titleMedium?.copyWith(color: primary, fontWeight: FontWeight.w600),
      titleSmall:    b.titleSmall?.copyWith(color: secondary, fontWeight: FontWeight.w500),
      bodyLarge:     b.bodyLarge?.copyWith(color: primary),
      bodyMedium:    b.bodyMedium?.copyWith(color: secondary),
      labelLarge:    b.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w600),
      labelMedium:   b.labelMedium?.copyWith(color: secondary),
    );
  }

  // ─── Public Getters ─────────────────────────────────────────────
  static ThemeData get light => _build(
    scheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.warning,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      outline: AppColors.dividerLight,
      outlineVariant: AppColors.dividerLight,
      surfaceContainerLowest: AppColors.backgroundLight,
    ),
    bg: AppColors.backgroundLight,
    card: AppColors.cardLight,
    navBg: AppColors.surfaceLight,
    fill: AppColors.backgroundLight,
    divider: AppColors.dividerLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    overlay: SystemUiOverlayStyle.dark,
  );

  static ThemeData get dark => _build(
    scheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.warning,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      outline: AppColors.dividerDark,
      outlineVariant: AppColors.dividerDark,
      surfaceContainerLowest: AppColors.backgroundDark,
    ),
    bg: AppColors.backgroundDark,
    card: AppColors.cardDark,
    navBg: AppColors.surfaceDark,
    fill: AppColors.surfaceDark,
    divider: AppColors.dividerDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    overlay: SystemUiOverlayStyle.light,
  );

  // ─── Builder ────────────────────────────────────────────────────
  static ThemeData _build({
    required ColorScheme scheme,
    required Color bg,
    required Color card,
    required Color navBg,
    required Color fill,
    required Color divider,
    required Color textPrimary,
    required Color textSecondary,
    required SystemUiOverlayStyle overlay,
  }) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: bg,
        textTheme: _textTheme(textPrimary, textSecondary),

        appBarTheme: AppBarTheme(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          systemOverlayStyle: overlay,
        ),

        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: divider),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: navBg,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 12,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 11,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        ),

        dividerTheme:
            DividerThemeData(color: divider, thickness: 1, space: 1),

        snackBarTheme: SnackBarThemeData(
          // Selalu pakai bg gelap agar kontras di kedua mode
          backgroundColor: AppColors.textPrimaryLight,
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.all(16),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary
                : textSecondary,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : divider,
          ),
        ),
      );
}
