import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pure Black & White DNA
  static const FlexScheme _scheme = FlexScheme.greys;

  static ThemeData get dark {
    return FlexThemeData.dark(
      scheme: _scheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 0, // No color blending, pure greys
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 0,
        useTextTheme: true,
        defaultRadius: 12.0, // Matches your screenshot's sharper corners
        inputDecoratorRadius: 12.0,
        inputDecoratorUnfocusedHasBorder: true, // Always show border
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        fabUseShape: true,
        interactionEffects: true,
      ),
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      fontFamily:
          GoogleFonts.inter().fontFamily, // 'Inter' is the cleanest pro font
      // Manual Overrides for the "Obsidian" look
      scaffoldBackground: const Color(0xFF000000), // Pitch Black
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: const Color(0xFF111111), // Slightly lighter for cards
    );
  }

  // Keep light theme just so code doesn't break, but we focus on Dark
  static ThemeData get light => FlexThemeData.light(scheme: _scheme);
}
