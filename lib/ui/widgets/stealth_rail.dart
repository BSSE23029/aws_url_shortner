import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Needed for theme toggle
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../providers/theme_provider.dart';

class StealthRail extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const StealthRail({super.key, required this.navigationShell});

  @override
  ConsumerState<StealthRail> createState() => _StealthRailState();
}

class _StealthRailState extends ConsumerState<StealthRail> {
  bool _isManuallyCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final themeMode = ref.watch(themeProvider).mode;

    // Check if effectively dark for the icon toggle
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Auto-collapse logic
    final isCompact = width < 1100 || _isManuallyCollapsed;
    final railWidth = isCompact
        ? 72.0
        : 250.0; // Reduced compact width slightly for cleaner look

    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.1);
    final bgColor = theme.scaffoldBackgroundColor.withValues(alpha: 0.85);
    final txtColor = theme.colorScheme.onSurface;

    final idx = widget.navigationShell.currentIndex;
    // 0=Dash, 1=Stats, 2=Prefs, 3=Profile

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: railWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: bgColor,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
            child: Column(
              crossAxisAlignment: isCompact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // --- HEADER ---
                GestureDetector(
                  onTap: () {
                    // Toggle collapse on logo tap for quick access
                    setState(
                      () => _isManuallyCollapsed = !_isManuallyCollapsed,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: isCompact
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsBold.linkSimpleHorizontal,
                        size: 28,
                        color: txtColor,
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            "Rad Link",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: txtColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // --- NAVIGATION ---
                _RailItem(
                  icon: PhosphorIconsRegular.squaresFour,
                  label: "Dashboard",
                  isSelected: idx == 0,
                  isCompact: isCompact,
                  onTap: () => _onTap(0),
                ),
                const SizedBox(height: 8),
                _RailItem(
                  icon: PhosphorIconsRegular.chartLineUp,
                  label: "Analytics",
                  isSelected: idx == 1,
                  isCompact: isCompact,
                  onTap: () => _onTap(1),
                ),

                const Spacer(),

                // --- SYSTEM FOOTER ---

                // 1. Theme Toggle
                _RailItem(
                  icon: themeMode == ThemeMode.system
                      ? PhosphorIconsRegular.circleHalf
                      : (themeMode == ThemeMode.dark
                            ? PhosphorIconsRegular.moon
                            : PhosphorIconsRegular.sun),
                  label: themeMode == ThemeMode.system
                      ? "System Default"
                      : (themeMode == ThemeMode.dark
                            ? "Dark Mode"
                            : "Light Mode"),
                  isSelected: false,
                  isCompact: isCompact,
                  onTap: () => ref.read(themeProvider.notifier).cycleTheme(),
                ),

                const SizedBox(height: 8),

                // 2. Settings (Navigates to Preferences)
                _RailItem(
                  icon: PhosphorIconsRegular.gear,
                  label: "Settings",
                  isSelected: idx == 2, // Highlight if we are in Settings
                  isCompact: isCompact,
                  onTap: () => _onTap(2),
                ),

                const SizedBox(height: 8),

                // 3. Profile
                _RailItem(
                  icon: PhosphorIconsRegular.userCircle,
                  label: "Profile",
                  isSelected: idx == 3, // Highlight if in Profile
                  isCompact: isCompact,
                  onTap: () => _onTap(3),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    final color = isSelected ? txtColor : txtColor.withValues(alpha: 0.5);
    final bgColor = isSelected
        ? txtColor.withValues(alpha: 0.1)
        : Colors.transparent;

    // FIX: Optimized padding to prevent overflow in compact mode
    // Compact: 10px padding. Expanded: 12px vertical, 16px horizontal
    final padding = isCompact
        ? const EdgeInsets.all(10)
        : const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    return Tooltip(
      message: isCompact ? label : "",
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? txtColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: isCompact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            mainAxisSize: isCompact
                ? MainAxisSize.min
                : MainAxisSize
                      .max, // FIX: Min size for compact to avoid stretch
            children: [
              Icon(icon, color: color, size: 22),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                Flexible(
                  // FIX: Flexible prevents text overflow
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(PhosphorIconsBold.caretRight, size: 14, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
