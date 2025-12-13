import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhysicsButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const PhysicsButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
  });

  @override
  State<PhysicsButton> createState() => _PhysicsButtonState();
}

class _PhysicsButtonState extends State<PhysicsButton>
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onPressed == null) return;
    await _controller.forward();
    await HapticFeedback.lightImpact();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Screenshot Style: White BG, Black Text, Glow
    final isEnabled = widget.onPressed != null;
    final bgColor = isEnabled
        ? (widget.backgroundColor ?? Colors.white)
        : Colors.white.withValues(alpha: 0.1); // Dimmed when disabled

    final txtColor = isEnabled
        ? (widget.textColor ?? Colors.black)
        : Colors.white.withValues(alpha: 0.3);

    return GestureDetector(
      onTapDown: (_) => isEnabled ? _controller.forward() : null,
      onTapUp: (_) => isEnabled ? _controller.reverse() : null,
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
            borderRadius: BorderRadius.circular(30), // Pill shape
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: bgColor.withValues(
                        alpha: 0.6,
                      ), // Glow matches button color
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [], // No shadow when disabled
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
