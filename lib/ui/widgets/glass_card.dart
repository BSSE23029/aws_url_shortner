import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? customColor;
  final BoxBorder? border;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blur = 25,
    this.opacity = 0.05,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius,
    this.onTap,
    this.customColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rBorder = borderRadius ?? BorderRadius.circular(24);

    // DYNAMIC COLORS
    final glassColor =
        customColor ??
        (isDark
            ? Colors.white.withValues(alpha: opacity)
            : Colors.black.withValues(
                alpha: opacity,
              )); // Invert tint for light mode

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.1); // Black border for light mode

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: rBorder,
        border: border ?? Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: rBorder,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: glassColor,
            type: MaterialType.transparency,
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: rBorder,
                    // Dynamic splash colors
                    splashColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    highlightColor: theme.colorScheme.primary.withValues(
                      alpha: 0.05,
                    ),
                    child: Padding(padding: padding, child: child),
                  )
                : Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
