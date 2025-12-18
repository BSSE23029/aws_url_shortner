import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class PhysicsButton extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const PhysicsButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  ConsumerState<PhysicsButton> createState() => _PhysicsButtonState();
}

class _PhysicsButtonState extends ConsumerState<PhysicsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onPressed == null) return;

    final settings = ref.read(themeProvider);

    if (settings.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    if (settings.enableAnimations) {
      await _controller.forward();
      await _controller.reverse();
    }

    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(themeProvider);
    final isEnabled = widget.onPressed != null;

    // --- SMART COLOR LOGIC ---
    // Background: Use provided color OR the theme's "Ink" color
    final bgColor = isEnabled
        ? (widget.backgroundColor ?? theme.colorScheme.onSurface)
        : theme.colorScheme.onSurface.withOpacity(0.1);

    // Text/Icon: Use provided color OR the theme's "Paper" color (for contrast)
    final resolvedTxtColor = isEnabled
        ? (widget.textColor ?? theme.scaffoldBackgroundColor)
        : theme.colorScheme.onSurface.withOpacity(0.3);

    return GestureDetector(
      onTapDown: (_) =>
          isEnabled && settings.enableAnimations ? _controller.forward() : null,
      onTapUp: (_) =>
          isEnabled && settings.enableAnimations ? _controller.reverse() : null,
      onTapCancel: () => _controller.reverse(),
      onTap: _handlePress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isEnabled && isEnabled
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: IconTheme(
            data: IconThemeData(color: resolvedTxtColor, size: 20),
            child: DefaultTextStyle(
              style: TextStyle(
                color: resolvedTxtColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
              child: widget.icon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon),
                        const SizedBox(width: 10),
                        widget.child,
                      ],
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
