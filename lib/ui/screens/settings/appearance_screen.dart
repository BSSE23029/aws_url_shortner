import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/physics_button.dart';
import '../../../providers/theme_provider.dart';

class AppearanceScreen extends ConsumerStatefulWidget {
  const AppearanceScreen({super.key});

  @override
  ConsumerState<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends ConsumerState<AppearanceScreen> {
  late double _tempTextScale;
  late double _tempIconScale;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(themeProvider);
    _tempTextScale = current.textScale;
    _tempIconScale = current.iconScale;
  }

  void _applyChanges() {
    final notifier = ref.read(themeProvider.notifier);
    notifier.updateTextScale(_tempTextScale);
    notifier.updateIconScale(_tempIconScale);
    setState(() => _hasChanges = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Interface Updated"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      title: "PREFERENCES",
      enableBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Typography
            _buildSectionHeader("TYPOGRAPHY SCALE", theme),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        PhosphorIconsRegular.textT,
                        size: 16,
                        color: theme.disabledColor,
                      ),
                      Expanded(
                        child: Slider(
                          value: _tempTextScale,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          activeColor: accentColor,
                          inactiveColor: theme.disabledColor.withValues(
                            alpha: 0.1,
                          ),
                          onChanged: (val) => setState(() {
                            _tempTextScale = val;
                            _hasChanges = true;
                          }),
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${_tempTextScale.toStringAsFixed(1)}x",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sample: The quick brown fox jumps over the lazy dog.",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14 * _tempTextScale,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, delay: 100.ms).fadeIn(),

            const SizedBox(height: 32),

            // 2. Density / Icons
            _buildSectionHeader("INTERFACE DENSITY", theme),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        PhosphorIconsRegular.cornersIn,
                        size: 20,
                        color: theme.disabledColor,
                      ),
                      Expanded(
                        child: Slider(
                          value: _tempIconScale,
                          min: 0.8,
                          max: 1.3,
                          divisions: 5,
                          activeColor: accentColor,
                          inactiveColor: theme.disabledColor.withValues(
                            alpha: 0.1,
                          ),
                          onChanged: (val) => setState(() {
                            _tempIconScale = val;
                            _hasChanges = true;
                          }),
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${_tempIconScale.toStringAsFixed(1)}x",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // MOCK TOOLBAR PREVIEW
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMockIcon(PhosphorIconsRegular.house),
                        _buildMockIcon(PhosphorIconsRegular.magnifyingGlass),
                        _buildMockIcon(PhosphorIconsRegular.bell),
                        _buildMockIcon(PhosphorIconsRegular.user),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, delay: 200.ms).fadeIn(),

            const SizedBox(height: 48),

            // Apply Button
            PhysicsButton(
              onPressed: _hasChanges ? _applyChanges : null,
              backgroundColor: _hasChanges
                  ? accentColor
                  : theme.disabledColor.withValues(alpha: 0.1),
              textColor: _hasChanges
                  ? theme.colorScheme.surface
                  : theme.disabledColor,
              child: Text(_hasChanges ? "APPLY CHANGES" : "NO CHANGES"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockIcon(IconData icon) {
    // This widget scales precisely with the slider
    return Icon(
      icon,
      size: 24.0 * _tempIconScale,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
