import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/cyber_scaffold.dart';

class WafBlockedScreen extends StatelessWidget {
  const WafBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final subtextColor = isDark ? Colors.white54 : Colors.black54;
    final borderColor = isDark ? Colors.white10 : Colors.black12;
    final bgColor = isDark
        ? Colors.black26
        : Colors.white.withValues(alpha: 0.3);

    return CyberScaffold(
      enableBack: false,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: GlassCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Glitch Icon
                  Icon(
                        PhosphorIconsDuotone.shieldWarning,
                        size: 80,
                        color: Colors.redAccent,
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shake(hz: 2, curve: Curves.easeInOut)
                      .saturate(duration: 2.seconds),

                  const SizedBox(height: 32),

                  Text(
                    "Access Denied",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Our security perimeter flagged this request. If you believe this is an error, contact the administrator.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtextColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ID Badge style info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: bgColor,
                    ),
                    child: const Text(
                      "REF: WAF-BLOCK-7X9",
                      style: TextStyle(
                        fontFamily: 'Courier', // Monospace for technical feel
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  PhysicsButton(
                    onPressed: () => context.go('/dashboard'),
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    child: Text(
                      "RETURN TO SAFETY",
                      style: TextStyle(
                        color: isDark ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
