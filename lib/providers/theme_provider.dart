import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The Data Model
class ThemeSettings {
  final ThemeMode mode; // System, Light, Dark
  final double textScale;
  final double iconScale;

  const ThemeSettings({
    this.mode = ThemeMode.system, // Default to Device Settings
    this.textScale = 1.0,
    this.iconScale = 1.0,
  });

  ThemeSettings copyWith({
    ThemeMode? mode,
    double? textScale,
    double? iconScale,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      textScale: textScale ?? this.textScale,
      iconScale: iconScale ?? this.iconScale,
    );
  }
}

// 2. The Notifier
class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Mode (0: System, 1: Light, 2: Dark)
    // If null, default to 0 (System)
    // final modeIndex = prefs.getInt('theme_mode') ?? 0;
    final modeIndex = prefs.getInt('theme_mode') ?? 1;

    ThemeMode mode = ThemeMode.system;
    if (modeIndex == 1) mode = ThemeMode.light;
    if (modeIndex == 2) mode = ThemeMode.dark;

    final tScale = prefs.getDouble('text_scale') ?? 1.0;
    final iScale = prefs.getDouble('icon_scale') ?? 1.0;

    state = ThemeSettings(mode: mode, textScale: tScale, iconScale: iScale);
  }

  // Cycles: System -> Light -> Dark -> System
  Future<void> cycleTheme() async {
    ThemeMode newMode;
    int saveVal;

    if (state.mode == ThemeMode.system) {
      newMode = ThemeMode.light;
      saveVal = 1;
    } else if (state.mode == ThemeMode.light) {
      newMode = ThemeMode.dark;
      saveVal = 2;
    } else {
      newMode = ThemeMode.system;
      saveVal = 0;
    }

    state = state.copyWith(mode: newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', saveVal);
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
