import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class AppTheme {
  // Legacy constants for backward compatibility (prevents crashes in old widgets)
  static const Color primaryBlue = Color(0xFF232F3E);
  static const Color accentTeal = Color(0xFF00A8E1);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  // The Obsidian/Dark DNA
  static const FlexScheme _scheme = FlexScheme.greys;

  static ThemeData generateDark(ThemeSettings settings) {
    // 1. Generate Base Theme
    final base = FlexThemeData.dark(
      scheme: _scheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 0, // Pure crisp dark
      // Inject User Personalization
      primary: settings.primaryColor,
      primaryLightRef: settings.primaryColor, // Fixes the warning
      onPrimary: Colors.black, // High contrast text on buttons

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

      // Force Obsidian Black
      scaffoldBackground: const Color(0xFF000000),
      surface: const Color(0xFF111111),
    );

    // 2. Safe Font Scaling (Prevents the crash)
    // We explicitly define base sizes so math never fails on null
    final textScale = settings.textScale;

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontSize: (base.textTheme.displayLarge?.fontSize ?? 57) * textScale,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          fontSize: (base.textTheme.displayMedium?.fontSize ?? 45) * textScale,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontSize: (base.textTheme.displaySmall?.fontSize ?? 36) * textScale,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontSize: (base.textTheme.headlineLarge?.fontSize ?? 32) * textScale,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: (base.textTheme.headlineMedium?.fontSize ?? 28) * textScale,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontSize: (base.textTheme.headlineSmall?.fontSize ?? 24) * textScale,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: (base.textTheme.titleLarge?.fontSize ?? 22) * textScale,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: (base.textTheme.titleMedium?.fontSize ?? 16) * textScale,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontSize: (base.textTheme.titleSmall?.fontSize ?? 14) * textScale,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: (base.textTheme.bodyLarge?.fontSize ?? 16) * textScale,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: (base.textTheme.bodyMedium?.fontSize ?? 14) * textScale,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: (base.textTheme.bodySmall?.fontSize ?? 12) * textScale,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: (base.textTheme.labelLarge?.fontSize ?? 14) * textScale,
        ),
      ),
      iconTheme: IconThemeData(
        size: 24.0 * settings.iconScale,
        color: settings.primaryColor,
      ),
    );
  }
}
