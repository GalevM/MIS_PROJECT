import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFFE3F2FD);
  static const Color secondary = Color(0xFF2196F3);
  static const Color accent = Color(0xFFFFA000);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color inProgress = Color(0xFF1565C0);
  static const Color inProgressLight = Color(0xFFE3F2FD);
  static const Color error = Color(0xFFC62828);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F4F8);
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textMuted = Color(0xFF546E7A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      cardColor: surface,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        headlineLarge: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textMuted,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.nunito(
          color: textMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(color: const Color(0xFFB0BEC5)),
      ),
      cardTheme: CardThemeData(
        color: AppTheme.surface,
        elevation: 2,
        shadowColor: AppTheme.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: primaryLight,
        labelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF90A4AE),
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFECEFF1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

extension ReportStatusExt on String {
  Color get statusColor {
    switch (this) {
      case 'received':
        return AppTheme.warning;
      case 'in_progress':
        return AppTheme.inProgress;
      case 'resolved':
        return AppTheme.success;
      default:
        return AppTheme.textMuted;
    }
  }

  Color get statusBgColor {
    switch (this) {
      case 'received':
        return AppTheme.warningLight;
      case 'in_progress':
        return AppTheme.inProgressLight;
      case 'resolved':
        return AppTheme.successLight;
      default:
        return AppTheme.background;
    }
  }

  String get statusLabel {
    switch (this) {
      case 'received':
        return 'Примено';
      case 'in_progress':
        return 'Во тек';
      case 'resolved':
        return 'Решено';
      default:
        return 'Непознато';
    }
  }

  String get statusEmoji {
    switch (this) {
      case 'received':
        return '🟡';
      case 'in_progress':
        return '🔵';
      case 'resolved':
        return '🟢';
      default:
        return '⚪';
    }
  }

  String get categoryLabel {
    switch (this) {
      case 'road':
        return 'Дупка на пат';
      case 'garbage':
        return 'Ѓубре';
      case 'lighting':
        return 'Улично светло';
      case 'illegal_dump':
        return 'Дива депонија';
      case 'park':
        return 'Парк / зеленило';
      case 'water':
        return 'Водоснабдување';
      case 'other':
        return 'Друго';
      default:
        return this;
    }
  }

  String get categoryEmoji {
    switch (this) {
      case 'road':
        return '🚧';
      case 'garbage':
        return '🗑️';
      case 'lighting':
        return '💡';
      case 'illegal_dump':
        return '⚠️';
      case 'park':
        return '🌳';
      case 'water':
        return '💧';
      case 'other':
        return '📌';
      default:
        return '📌';
    }
  }
}
