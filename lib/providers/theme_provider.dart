import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final ThemeMode mode;
  final double textScale;
  final double iconScale;
  // New Settings
  final bool enableHaptics;
  final bool enableAnimations;

  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.textScale = 1.0,
    this.iconScale = 1.0,
    this.enableHaptics = true,
    this.enableAnimations = true,
  });

  ThemeSettings copyWith({
    ThemeMode? mode,
    double? textScale,
    double? iconScale,
    bool? enableHaptics,
    bool? enableAnimations,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      textScale: textScale ?? this.textScale,
      iconScale: iconScale ?? this.iconScale,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableAnimations: enableAnimations ?? this.enableAnimations,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // final modeIndex = prefs.getInt('theme_mode') ?? 0;
    final modeIndex = prefs.getInt('theme_mode') ?? 1;
    ThemeMode mode = ThemeMode.system;
    if (modeIndex == 1) mode = ThemeMode.light;
    if (modeIndex == 2) mode = ThemeMode.dark;

    state = ThemeSettings(
      mode: mode,
      textScale: prefs.getDouble('text_scale') ?? 1.0,
      iconScale: prefs.getDouble('icon_scale') ?? 1.0,
      enableHaptics: prefs.getBool('enable_haptics') ?? true,
      enableAnimations: prefs.getBool('enable_animations') ?? true,
    );
  }

  // ... (Keep existing cycleTheme, updateTextScale, updateIconScale) ...

  Future<void> cycleTheme() async {
    // ... copy existing logic ...
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

  // NEW: Toggle Haptics
  Future<void> toggleHaptics(bool value) async {
    state = state.copyWith(enableHaptics: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_haptics', value);
  }

  // NEW: Toggle Animations
  Future<void> toggleAnimations(bool value) async {
    state = state.copyWith(enableAnimations: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_animations', value);
  }

  // NEW: Hard Reset
  Future<void> reset() async {
    state = const ThemeSettings(); // Back to default
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipe storage
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((
  ref,
) {
  return ThemeNotifier();
});
