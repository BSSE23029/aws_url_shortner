import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/physics_button.dart';
import '../../../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return CyberScaffold(
      title: "CUSTOMIZE",
      enableBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Color Palette
            _buildSectionHeader("SYSTEM ACCENT"),
            GlassCard(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: AppPalettes.all.map((color) {
                  final isSelected = settings.primaryColor.value == color.value;
                  return GestureDetector(
                    onTap: () => notifier.updateColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: Colors.white24, width: 1),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.black)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ).animate().slideY(begin: 0.1).fadeIn(),

            const SizedBox(height: 32),

            // 2. Typography
            _buildSectionHeader("TYPOGRAPHY SCALE"),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        PhosphorIconsRegular.textT,
                        size: 16,
                        color: Colors.white54,
                      ),
                      Expanded(
                        child: Slider(
                          value: settings.textScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: settings.primaryColor,
                          inactiveColor: Colors.white10,
                          onChanged: (val) => notifier.updateTextScale(val),
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.textT,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sample Text: The quick brown fox jumps over the lazy dog.",
                    style: TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, delay: 100.ms).fadeIn(),

            const SizedBox(height: 32),

            // 3. UI Density
            _buildSectionHeader("INTERFACE DENSITY"),
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    PhosphorIconsRegular.cornersIn,
                    size: 20,
                    color: Colors.white54,
                  ),
                  Expanded(
                    child: Slider(
                      value: settings.iconScale,
                      min: 0.8,
                      max: 1.3,
                      divisions: 5,
                      activeColor: settings.primaryColor,
                      inactiveColor: Colors.white10,
                      onChanged: (val) => notifier.updateIconScale(val),
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.cornersOut,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, delay: 200.ms).fadeIn(),

            const SizedBox(height: 48),

            PhysicsButton(
              onPressed: () => notifier.reset(),
              backgroundColor: Colors.white10,
              child: const Text(
                "RESET TO DEFAULT",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
