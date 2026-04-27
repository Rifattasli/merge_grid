import 'package:flutter/material.dart';

final class AppColors {
  static const Color cream = Color(0xFFFDF7EE);
  static const Color warmCream = Color(0xFFF7E9D5);
  static const Color peach = Color(0xFFF4B183);
  static const Color coral = Color(0xFFEA7A63);
  static const Color butter = Color(0xFFF2C96B);
  static const Color sage = Color(0xFF8BB79B);
  static const Color teal = Color(0xFF5A9A9C);
  static const Color cocoa = Color(0xFF5B4334);
  static const Color cocoaSoft = Color(0xFF866A58);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color surfaceAlt = Color(0xFFF9F0E2);
  static const Color outline = Color(0xFFE7D1B6);
  static const Color shadow = Color(0x1F8F5D3B);
  static const Color scrim = Color(0x8A402D22);
}

final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

final class AppRadii {
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999;
}

final class AppTheme {
  static ThemeData build() {
    final ColorScheme colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.coral,
          primary: AppColors.coral,
          secondary: AppColors.peach,
          surface: AppColors.surface,
          brightness: Brightness.light,
        ).copyWith(
          onPrimary: Colors.white,
          onSecondary: AppColors.cocoa,
          onSurface: AppColors.cocoa,
          error: const Color(0xFFB54A36),
          onError: Colors.white,
        );

    final TextTheme textTheme = ThemeData.light().textTheme.copyWith(
      displayMedium: const TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.8,
        color: AppColors.cocoa,
      ),
      displaySmall: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
        color: AppColors.cocoa,
      ),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.cocoa,
      ),
      headlineSmall: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.cocoa,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.cocoa,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.cocoa,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.35,
        color: AppColors.cocoaSoft,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.3,
        color: AppColors.cocoaSoft,
      ),
      labelLarge: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.cocoa,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.cocoaSoft,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.cocoaSoft,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.cocoa,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.cocoa,
          side: const BorderSide(color: AppColors.outline, width: 1.3),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          backgroundColor: AppColors.surface.withValues(alpha: 0.72),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.coral
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.peach
              : AppColors.outline;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cocoa,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
