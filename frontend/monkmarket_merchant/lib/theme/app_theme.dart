import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color textPrimary = Color(0xFF1A1F1A);
  static const Color textSecondary = Color(0xFF4A5E4C);
  static const Color onSurfaceVariantLight = Color(0xFF4A5E4C);
  static const Color primary = Color(0xFF1A6B3A);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryContainer = Color(0xFFD4EDDA);
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryContainer = Color(0xFFE8F5E9);

  static const Color success = Color(0xFF2D7A4F);
  static const Color successContainer = Color(0xFFDCF0E5);
  static const Color warning = Color(0xFFB45309);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoContainer = Color(0xFFDCEAFE);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F7F5);
  static const Color backgroundLight = Color(0xFFF0F4F1);
  static const Color outlineLight = Color(0xFFCED4CE);
  static const Color outlineVariantLight = Color(0xFFE8EDE8);

  static const Color surfaceDark = Color(0xFF1E2420);
  static const Color surfaceVariantDark = Color(0xFF252D27);
  static const Color backgroundDark = Color(0xFF121812);
  static const Color outlineDark = Color(0xFF3A4A3C);
  static const Color outlineVariantDark = Color(0xFF2A352C);

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.plusJakartaSansTextTheme(base).copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Color(0xFF0A3D1F),
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Color(0xFF0A3D1F),
        surface: surfaceLight,
        onSurface: Color(0xFF1A1F1A),
        surfaceContainerHighest: surfaceVariantLight,
        onSurfaceVariant: Color(0xFF4A5E4C),
        error: error,
        onError: Colors.white,
        errorContainer: errorContainer,
        onErrorContainer: Color(0xFF7F1D1D),
        outline: outlineLight,
        outlineVariant: outlineVariantLight,
        inverseSurface: Color(0xFF2A352C),
        onInverseSurface: Color(0xFFECF3ED),
        inversePrimary: Color(0xFF86D99A),
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarThemeData(
        backgroundColor: surfaceLight,
        foregroundColor: const Color(0xFF1A1F1A),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: outlineLight.withAlpha(128),
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1F1A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1F1A)),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF4A5E4C),
        ),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariantLight,
        space: 1,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4A5E4C),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary);
          }
          return const IconThemeData(color: Color(0xFF4A5E4C));
        }),
        elevation: 3,
        shadowColor: outlineLight.withAlpha(77),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A352C),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF86D99A),
        onPrimary: Color(0xFF0A3D1F),
        primaryContainer: Color(0xFF1A5C30),
        onPrimaryContainer: Color(0xFFD4EDDA),
        secondary: Color(0xFF81C784),
        onSecondary: Color(0xFF0A3D1F),
        secondaryContainer: Color(0xFF1B5E20),
        onSecondaryContainer: Color(0xFFE8F5E9),
        surface: surfaceDark,
        onSurface: Color(0xFFE6EDE7),
        surfaceContainerHighest: surfaceVariantDark,
        onSurfaceVariant: Color(0xFFABBAAD),
        error: Color(0xFFCF6679),
        onError: Color(0xFF7F1D1D),
        outline: outlineDark,
        outlineVariant: outlineVariantDark,
        inverseSurface: Color(0xFFE6EDE7),
        onInverseSurface: Color(0xFF2A352C),
        inversePrimary: primary,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarThemeData(
        backgroundColor: surfaceDark,
        foregroundColor: const Color(0xFFE6EDE7),
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFE6EDE7),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceDark,
        indicatorColor: const Color(0xFF1A5C30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF86D99A),
            );
          }
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFABBAAD),
          );
        }),
      ),
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(15),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration elevatedCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }
}
