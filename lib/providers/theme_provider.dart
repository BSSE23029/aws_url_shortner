import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The Data Model
class ThemeSettings {
  final Color primaryColor;
  final double textScale;
  final double iconScale;
  final bool isHighContrast;

  const ThemeSettings({
    this.primaryColor = const Color(0xFFFFFFFF), // Default: White/Obsidian
    this.textScale = 1.0,
    this.iconScale = 1.0,
    this.isHighContrast = true,
  });

  ThemeSettings copyWith({
    Color? primaryColor,
    double? textScale,
    double? iconScale,
    bool? isHighContrast,
  }) {
    return ThemeSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      textScale: textScale ?? this.textScale,
      iconScale: iconScale ?? this.iconScale,
      isHighContrast: isHighContrast ?? this.isHighContrast,
    );
  }
}

// 2. The curated Cyberpunk Palette
class AppPalettes {
  static const Color obsidian = Color(0xFFFFFFFF);
  static const Color cyberYellow = Color(0xFFF2FF00);
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color crimsonRed = Color(0xFFFF003C);
  static const Color matrixGreen = Color(0xFF00FF41);
  static const Color electricPurple = Color(0xFFBC13FE);

  static const List<Color> all = [
    obsidian,
    cyberYellow,
    neonCyan,
    crimsonRed,
    matrixGreen,
    electricPurple,
  ];
}

// 3. The Notifier
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final colorVal = prefs.getInt('theme_color') ?? 0xFFFFFFFF;
    final tScale = prefs.getDouble('text_scale') ?? 1.0;
    final iScale = prefs.getDouble('icon_scale') ?? 1.0;

    state = ThemeSettings(
      primaryColor: Color(colorVal),
      textScale: tScale,
      iconScale: iScale,
    );
  }

  Future<void> updateColor(Color color) async {
    state = state.copyWith(primaryColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_color', color.value);
  }

  Future<void> updateTextScale(double scale) async {
    state = state.copyWith(textScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', scale);
  }

  Future<void> updateIconScale(double scale) async {
    state = state.copyWith(iconScale: scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('icon_scale', scale);
  }

  Future<void> reset() async {
    state = const ThemeSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((
  ref,
) {
  return ThemeNotifier();
});
