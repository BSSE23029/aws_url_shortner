import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class AppTheme {
  static ThemeData generate(
    ThemeSettings settings, {
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    // 1. Define the Palette
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final surfaceColor = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFF5F5F5);
    final accentColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white : Colors.black;

    // 2. Base Theme (Fixed for v8.0 compatibility)
    final base = isDark
        ? FlexThemeData.dark(
            scheme: FlexScheme.greys,
            surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: 0,
            primary: Colors.white,
            onPrimary: Colors.black,
            scaffoldBackground: bgColor,
            surface: surfaceColor,
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

    // 3. Safe Component Styling & Text Scaling
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

    // 4. Manual Text Scaling (Safe calculation)
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
      displaySmall: t.displaySmall?.copyWith(
        fontSize: (t.displaySmall?.fontSize ?? 36) * s,
        color: textColor,
      ),
      headlineLarge: t.headlineLarge?.copyWith(
        fontSize: (t.headlineLarge?.fontSize ?? 32) * s,
        color: textColor,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontSize: (t.headlineMedium?.fontSize ?? 28) * s,
        color: textColor,
      ),
      headlineSmall: t.headlineSmall?.copyWith(
        fontSize: (t.headlineSmall?.fontSize ?? 24) * s,
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
      titleSmall: t.titleSmall?.copyWith(
        fontSize: (t.titleSmall?.fontSize ?? 14) * s,
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
      bodySmall: t.bodySmall?.copyWith(
        fontSize: (t.bodySmall?.fontSize ?? 12) * s,
        color: textColor,
      ),
      labelLarge: t.labelLarge?.copyWith(
        fontSize: (t.labelLarge?.fontSize ?? 14) * s,
        color: textColor,
      ),
      labelMedium: t.labelMedium?.copyWith(
        fontSize: (t.labelMedium?.fontSize ?? 12) * s,
        color: textColor,
      ),
      labelSmall: t.labelSmall?.copyWith(
        fontSize: (t.labelSmall?.fontSize ?? 11) * s,
        color: textColor,
      ),
    ).apply(fontFamily: GoogleFonts.inter().fontFamily);

    return customized.copyWith(textTheme: scaledTextTheme);
  }
}
