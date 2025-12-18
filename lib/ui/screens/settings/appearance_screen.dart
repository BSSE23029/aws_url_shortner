import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_switch.dart';
import '../../../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      title: "PREFERENCES",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Toggles (Haptics / Animations)
            _buildHeader("INTERACTION", txtColor),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  CyberSwitch(
                    title: "Haptic Feedback",
                    subtitle: "Vibration on interactions",
                    icon: PhosphorIconsRegular.vibrate,
                    value: settings.enableHaptics,
                    onChanged: (val) => notifier.toggleHaptics(val),
                  ),
                  Divider(height: 1, color: txtColor.withValues(alpha: 0.1)),
                  CyberSwitch(
                    title: "UI Animations",
                    subtitle: "Smooth transitions and effects",
                    icon: PhosphorIconsRegular.filmStrip,
                    value: settings.enableAnimations,
                    onChanged: (val) => notifier.toggleAnimations(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Sliders
            _buildHeader("SCALING", txtColor),
            GlassCard(
              child: Column(
                children: [
                  _buildSlider(
                    "Text Size",
                    settings.textScale,
                    0.8,
                    1.4,
                    (v) => notifier.updateTextScale(v),
                    txtColor,
                  ),
                  const SizedBox(height: 24),
                  _buildSlider(
                    "Icon Density",
                    settings.iconScale,
                    0.8,
                    1.3,
                    (v) => notifier.updateIconScale(v),
                    txtColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // 3. Reset
            PhysicsButton(
              onPressed: () async {
                await notifier.reset();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Settings Reset to Default"),
                      backgroundColor: txtColor.withValues(alpha: 0.9),
                    ),
                  );
                }
              },
              icon: PhosphorIconsRegular.arrowClockwise,
              child: const Text("RESET TO DEFAULTS"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color.withValues(alpha: 0.7))),
            Text(
              "${value.toStringAsFixed(1)}x",
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 5,
          activeColor: color,
          inactiveColor: color.withValues(alpha: 0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
