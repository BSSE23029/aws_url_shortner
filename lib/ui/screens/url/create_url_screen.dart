import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/physics_button.dart';
import '../../widgets/stealth_input.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class CreateUrlScreen extends ConsumerStatefulWidget {
  const CreateUrlScreen({super.key});

  @override
  ConsumerState<CreateUrlScreen> createState() => _CreateUrlScreenState();
}

class _CreateUrlScreenState extends ConsumerState<CreateUrlScreen>
    with TickerProviderStateMixin {
  final _urlController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _useCustomCode = false;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _urlController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final theme = ref.read(themeProvider);
    if (theme.enableHaptics) {
      HapticFeedback.mediumImpact();
    }
    CyberFeedback.deployingAsset(context);
    await ref
        .read(urlsProvider.notifier)
        .createUrl(
          originalUrl: _urlController.text,
          customCode: _useCustomCode ? _codeController.text : null,
        );
    if (mounted && ref.read(urlsProvider).errorMessage == null) {
      if (theme.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      CyberFeedback.deploymentComplete(context);
      context.pop();
    } else if (mounted) {
      CyberFeedback.namespaceCollision(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final txtColor = theme.colorScheme.onSurface;
    final isLoading = ref.watch(urlsProvider).isLoading;

    return CyberScaffold(
      title: "NEW DEPLOYMENT",
      body: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _glowController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child:
                  ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          children: [
                            // Animated header section
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withValues(
                                        alpha:
                                            0.3 +
                                            (_pulseController.value * 0.3),
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withValues(
                                          alpha:
                                              0.1 +
                                              (_pulseController.value * 0.2),
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                            PhosphorIconsDuotone.rocketLaunch,
                                            size: 72,
                                            color: Colors.cyanAccent,
                                          )
                                          .animate(onPlay: (c) => c.repeat())
                                          .shimmer(
                                            duration: 2.seconds,
                                            color: Colors.cyanAccent.withValues(
                                              alpha: 0.3,
                                            ),
                                          )
                                          .shake(
                                            hz: 0.5,
                                            curve: Curves.easeInOut,
                                          ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "LINK FORGE",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: txtColor,
                                          letterSpacing: 4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Initialize new URL asset in the network",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: txtColor.withValues(
                                            alpha: 0.6,
                                          ),
                                          letterSpacing: 1,
                                          fontFamily: 'Courier',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            // Form section
                            GlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // URL Input with cyber decoration
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.cyanAccent.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.cyanAccent
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Icon(
                                            PhosphorIconsBold.globe,
                                            color: Colors.cyanAccent,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "TARGET COORDINATES",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: txtColor.withValues(
                                              alpha: 0.7,
                                            ),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    StealthInput(
                                      label: "Destination URL",
                                      icon: PhosphorIconsBold.link,
                                      controller: _urlController,
                                      validator: (v) {
                                        if (v?.isEmpty == true)
                                          return 'URL Required';
                                        if (!v!.startsWith('http://') &&
                                            !v.startsWith('https://')) {
                                          return 'Must start with http:// or https://';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                    // Custom code toggle with enhanced design
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _useCustomCode
                                            ? Colors.cyanAccent.withValues(
                                                alpha: 0.05,
                                              )
                                            : (isDark
                                                      ? Colors.white
                                                      : Colors.black)
                                                  .withValues(alpha: 0.02),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _useCustomCode
                                              ? Colors.cyanAccent.withValues(
                                                  alpha: 0.3,
                                                )
                                              : txtColor.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _useCustomCode
                                                ? PhosphorIconsBold.fingerprint
                                                : PhosphorIconsRegular
                                                      .fingerprint,
                                            color: _useCustomCode
                                                ? Colors.cyanAccent
                                                : txtColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "CUSTOM IDENTIFIER",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: _useCustomCode
                                                        ? Colors.cyanAccent
                                                        : txtColor,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _useCustomCode
                                                      ? "Define your own alias"
                                                      : "Auto-generate secure code",
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: txtColor.withValues(
                                                      alpha: 0.5,
                                                    ),
                                                    fontFamily: 'Courier',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Switch(
                                            value: _useCustomCode,
                                            onChanged: (v) {
                                              setState(
                                                () => _useCustomCode = v,
                                              );
                                              final switchTheme = ref.read(
                                                themeProvider,
                                              );
                                              if (switchTheme.enableHaptics) {
                                                HapticFeedback.selectionClick();
                                              }
                                            },
                                            activeThumbColor:
                                                theme.scaffoldBackgroundColor,
                                            activeTrackColor: Colors.cyanAccent,
                                            inactiveThumbColor: txtColor
                                                .withValues(alpha: 0.5),
                                            inactiveTrackColor: txtColor
                                                .withValues(alpha: 0.1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_useCustomCode) ...[
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.amberAccent
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.amberAccent
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Icon(
                                              PhosphorIconsBold.key,
                                              color: Colors.amberAccent,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "ALIAS DESIGNATION",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: txtColor.withValues(
                                                alpha: 0.7,
                                              ),
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      StealthInput(
                                            label:
                                                "Custom Alias (e.g., my-link)",
                                            icon: PhosphorIconsBold.tag,
                                            controller: _codeController,
                                            validator: (v) {
                                              if (_useCustomCode &&
                                                  v?.isEmpty == true) {
                                                return 'Alias required';
                                              }
                                              if (v != null && v.isNotEmpty) {
                                                if (!RegExp(
                                                  r'^[a-zA-Z0-9_-]+$',
                                                ).hasMatch(v)) {
                                                  return 'Only letters, numbers, - and _';
                                                }
                                              }
                                              return null;
                                            },
                                          )
                                          .animate()
                                          .fadeIn(duration: 300.ms)
                                          .slideX(begin: -0.2, end: 0),
                                    ],
                                    const SizedBox(height: 40),
                                    // Enhanced submit button
                                    PhysicsButton(
                                      onPressed: isLoading ? null : _submit,
                                      backgroundColor: isLoading
                                          ? Colors.grey
                                          : Colors.cyanAccent,
                                      child: isLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    color: theme
                                                        .scaffoldBackgroundColor,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "DEPLOYING...",
                                                  style: TextStyle(
                                                    color: theme
                                                        .scaffoldBackgroundColor,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  PhosphorIconsBold.lightning,
                                                  color: theme
                                                      .scaffoldBackgroundColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "INITIALIZE LINK",
                                                  style: TextStyle(
                                                    color: theme
                                                        .scaffoldBackgroundColor,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Info footer
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDark ? Colors.cyan : Colors.blue)
                                                .withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.cyanAccent.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            PhosphorIconsRegular.info,
                                            size: 16,
                                            color: Colors.cyanAccent,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Links are secured with enterprise-grade encryption",
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: txtColor.withValues(
                                                  alpha: 0.6,
                                                ),
                                                fontFamily: 'Courier',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        curve: Curves.easeOutCubic,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated background particles
class _ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ParticlePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: isDark ? 0.03 : 0.02)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 8; i++) {
      final x = (size.width / 8) * i + (progress * 50);
      final y =
          (size.height / 3) * ((i % 3) + 1) +
          (progress * 30 * (i.isEven ? 1 : -1));
      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        3 + (progress * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
