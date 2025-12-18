import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class AppTheme {
  // AppTheme.light and AppTheme.dark
  static ThemeData get light =>
      AppTheme.generate(ThemeSettings(), brightness: Brightness.light);
  static ThemeData get dark =>
      AppTheme.generate(ThemeSettings(), brightness: Brightness.dark);

  static ThemeData generate(
    ThemeSettings settings, {
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final surfaceColor = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFF5F5F5);
    final accentColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    // Base Theme
    final base = isDark
        ? FlexThemeData.dark(
            scheme: FlexScheme.greys,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 0,
            primary: Colors.white,
            primaryLightRef: Colors.black, // Reference to light theme primary
            onPrimary: Colors.black,
            scaffoldBackground: bgColor,
            surface: surfaceColor,
            // FIX: Explicitly disable key color seeding to stop the warning
            keyColors: const FlexKeyColors(
              useKeyColors: false,
              useSecondary: false,
              useTertiary: false,
            ),
            subThemesData: const FlexSubThemesData(
              defaultRadius: 12.0,
              inputDecoratorRadius: 12.0,
              inputDecoratorUnfocusedHasBorder: true,
              inputDecoratorFocusedHasBorder: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              fabUseShape: true,
              interactionEffects: true,
            ),
            visualDensity: VisualDensity.standard,
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
          )
        : FlexThemeData.light(
            scheme: FlexScheme.greys,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 0,
            primary: Colors.black,
            onPrimary: Colors.white,
            scaffoldBackground: bgColor,
            surface: surfaceColor,
            // FIX: Disable key colors here too
            keyColors: const FlexKeyColors(
              useKeyColors: false,
              useSecondary: false,
              useTertiary: false,
            ),
            subThemesData: const FlexSubThemesData(
              defaultRadius: 12.0,
              inputDecoratorRadius: 12.0,
              inputDecoratorUnfocusedHasBorder: true,
              inputDecoratorFocusedHasBorder: true,
              inputDecoratorBorderType: FlexInputBorderType.outline,
              fabUseShape: true,
              interactionEffects: true,
            ),
            visualDensity: VisualDensity.standard,
            useMaterial3: true,
            fontFamily: GoogleFonts.inter().fontFamily,
          );

    // Apply Scaling
    final customized = base.copyWith(
      iconTheme: base.iconTheme.copyWith(
        color: accentColor,
        size: 24.0 * settings.iconScale,
      ),
      primaryIconTheme: base.primaryIconTheme.copyWith(color: accentColor),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: textColor.withValues(alpha: 0.5)),
        prefixIconColor: textColor.withValues(alpha: 0.7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: textColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );

    // Manual Text Scaling
    final s = settings.textScale;
    final t = customized.textTheme;

    final scaledTextTheme = TextTheme(
      displayLarge: t.displayLarge?.copyWith(
        fontSize: (t.displayLarge?.fontSize ?? 57) * s,
        color: textColor,
      ),
      displayMedium: t.displayMedium?.copyWith(
        fontSize: (t.displayMedium?.fontSize ?? 45) * s,
        color: textColor,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontSize: (t.headlineMedium?.fontSize ?? 28) * s,
        color: textColor,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontSize: (t.titleLarge?.fontSize ?? 22) * s,
        color: textColor,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontSize: (t.titleMedium?.fontSize ?? 16) * s,
        color: textColor,
      ),
      bodyLarge: t.bodyLarge?.copyWith(
        fontSize: (t.bodyLarge?.fontSize ?? 16) * s,
        color: textColor,
      ),
      bodyMedium: t.bodyMedium?.copyWith(
        fontSize: (t.bodyMedium?.fontSize ?? 14) * s,
        color: textColor,
      ),
      labelLarge: t.labelLarge?.copyWith(
        fontSize: (t.labelLarge?.fontSize ?? 14) * s,
        color: textColor,
      ),
    ).apply(fontFamily: GoogleFonts.inter().fontFamily);

    return customized.copyWith(textTheme: scaledTextTheme);
  }
}
