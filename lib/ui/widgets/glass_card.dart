import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(32), // More padding like screenshot
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        // The "Smoked Glass" border
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        // Subtle glow/shadow behind the card
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: const Color(0xFF0A0A0A).withOpacity(0.7), // Very dark tint
            child: Material(
              color: Colors.transparent,
              child: onTap != null
                  ? InkWell(
                      onTap: onTap,
                      child: Padding(padding: padding, child: child),
                    )
                  : Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
