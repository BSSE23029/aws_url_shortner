import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void _log(String message) {
  if (kDebugMode) {
    print("🟡 [THEME] $message");
  }
}

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
    _log("🔧 ThemeNotifier initialized");
    _log(
      "📋 Initial state: mode=${state.mode.name}, textScale=${state.textScale}, iconScale=${state.iconScale}",
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _log("💾 LOAD SETTINGS: Loading theme preferences from storage");
    final prefs = await SharedPreferences.getInstance();
    _log("✅ SharedPreferences instance obtained");

    // final modeIndex = prefs.getInt('theme_mode') ?? 0;
    final modeIndex = prefs.getInt('theme_mode') ?? 1;
    _log("🎨 Theme mode index from storage: $modeIndex");
    ThemeMode mode = ThemeMode.system;
    if (modeIndex == 1) mode = ThemeMode.light;
    if (modeIndex == 2) mode = ThemeMode.dark;
    _log("🎨 Resolved theme mode: ${mode.name}");

    final textScale = prefs.getDouble('text_scale') ?? 1.0;
    final iconScale = prefs.getDouble('icon_scale') ?? 1.0;
    final haptics = prefs.getBool('enable_haptics') ?? true;
    final animations = prefs.getBool('enable_animations') ?? true;

    _log("🔤 Text scale: $textScale");
    _log("🔤 Icon scale: $iconScale");
    _log("📣 Haptics enabled: $haptics");
    _log("✨ Animations enabled: $animations");

    state = ThemeSettings(
      mode: mode,
      textScale: textScale,
      iconScale: iconScale,
      enableHaptics: haptics,
      enableAnimations: animations,
    );
    _log("✅ Theme settings loaded and state updated");
  }

  // ... (Keep existing cycleTheme, updateTextScale, updateIconScale) ...

  Future<void> cycleTheme() async {
    _log("🔄 CYCLE THEME: Cycling theme mode");
    _log("🎨 Current mode: ${state.mode.name}");
    // ... copy existing logic ...
    ThemeMode newMode;
    int saveVal;
    if (state.mode == ThemeMode.system) {
      newMode = ThemeMode.light;
      saveVal = 1;
      _log("➡️ Switching: system → light");
    } else if (state.mode == ThemeMode.light) {
      newMode = ThemeMode.dark;
      saveVal = 2;
      _log("➡️ Switching: light → dark");
    } else {
      newMode = ThemeMode.system;
      saveVal = 0;
      _log("➡️ Switching: dark → system");
    }
    _log("🔄 Updating state with new mode: ${newMode.name}");
    state = state.copyWith(mode: newMode);
    _log("💾 Persisting to SharedPreferences (value: $saveVal)");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', saveVal);
    _log("✅ Theme mode cycled successfully");
  }

  Future<void> updateTextScale(double scale) async {
    _log("🔤 UPDATE TEXT SCALE: Changing text scale");
    _log("📊 Current scale: ${state.textScale}");
    _log("📊 New scale: $scale");
    state = state.copyWith(textScale: scale);
    _log("🔄 State updated");
    _log("💾 Persisting to SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', scale);
    _log("✅ Text scale updated successfully");
  }

  Future<void> updateIconScale(double scale) async {
    _log("🔤 UPDATE ICON SCALE: Changing icon scale");
    _log("📊 Current scale: ${state.iconScale}");
    _log("📊 New scale: $scale");
    state = state.copyWith(iconScale: scale);
    _log("🔄 State updated");
    _log("💾 Persisting to SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('icon_scale', scale);
    _log("✅ Icon scale updated successfully");
  }

  // NEW: Toggle Haptics
  Future<void> toggleHaptics(bool value) async {
    _log("📣 TOGGLE HAPTICS: Changing haptics setting");
    _log("🔄 Current: ${state.enableHaptics} → New: $value");
    state = state.copyWith(enableHaptics: value);
    _log("🔄 State updated");
    _log("💾 Persisting to SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_haptics', value);
    _log("✅ Haptics setting updated successfully");
  }

  // NEW: Toggle Animations
  Future<void> toggleAnimations(bool value) async {
    _log("✨ TOGGLE ANIMATIONS: Changing animations setting");
    _log("🔄 Current: ${state.enableAnimations} → New: $value");
    state = state.copyWith(enableAnimations: value);
    _log("🔄 State updated");
    _log("💾 Persisting to SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_animations', value);
    _log("✅ Animations setting updated successfully");
  }

  // NEW: Hard Reset
  Future<void> reset() async {
    _log("🧹 RESET: Performing hard reset of theme settings");
    _log("📋 Current settings before reset:");
    _log("  - Mode: ${state.mode.name}");
    _log("  - Text scale: ${state.textScale}");
    _log("  - Icon scale: ${state.iconScale}");
    _log("  - Haptics: ${state.enableHaptics}");
    _log("  - Animations: ${state.enableAnimations}");
    _log("🔄 Resetting to default state");
    state = const ThemeSettings(); // Back to default
    _log("💾 Clearing all SharedPreferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Wipe storage
    _log("✅ Theme settings reset completed");
    _log("📋 Default settings restored:");
    _log("  - Mode: ${state.mode.name}");
    _log("  - Text scale: ${state.textScale}");
    _log("  - Icon scale: ${state.iconScale}");
    _log("  - Haptics: ${state.enableHaptics}");
    _log("  - Animations: ${state.enableAnimations}");
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((
  ref,
) {
  _log("🔧 Creating ThemeNotifier provider");
  return ThemeNotifier();
});
