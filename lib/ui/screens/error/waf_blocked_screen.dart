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

                  const Text(
                    "Access Denied",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Our security perimeter flagged this request. If you believe this is an error, contact the administrator.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
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
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black26,
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
                    backgroundColor: Colors.white,
                    child: const Text(
                      "RETURN TO SAFETY",
                      style: TextStyle(
                        color: Colors.black,
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
