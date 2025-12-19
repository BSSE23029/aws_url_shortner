import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum CyberMessageType { info, success, warning, error }

enum CyberHapticType { none, light, medium, heavy, selection }

enum CyberPosition { topRight, topCenter, center, bottomRight }

class CyberFeedback {
  static int _notificationCounter = 0;

  /// Show a cyber-themed feedback message
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    CyberMessageType type = CyberMessageType.info,
    CyberHapticType haptic = CyberHapticType.none,
    CyberPosition position = CyberPosition.topRight,
    bool isTransient = false,
    Duration? duration,
  }) {
    // Trigger haptic feedback
    _triggerHaptic(haptic);

    // Determine if we should use mobile or desktop layout
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      _showMobileFeedback(
        context,
        title: title,
        message: message,
        type: type,
        isTransient: isTransient,
        duration: duration,
      );
    } else {
      _showDesktopFeedback(
        context,
        title: title,
        message: message,
        type: type,
        position: position,
        isTransient: isTransient,
        duration: duration,
      );
    }
  }

  static void _triggerHaptic(CyberHapticType haptic) {
    switch (haptic) {
      case CyberHapticType.light:
        HapticFeedback.lightImpact();
        break;
      case CyberHapticType.medium:
        HapticFeedback.mediumImpact();
        break;
      case CyberHapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case CyberHapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case CyberHapticType.none:
        break;
    }
  }

  static void _showMobileFeedback(
    BuildContext context, {
    required String title,
    required String message,
    required CyberMessageType type,
    required bool isTransient,
    Duration? duration,
  }) {
    final effectiveDuration = isTransient
        ? const Duration(seconds: 1)
        : (duration ?? const Duration(seconds: 3));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _CyberSnackBarContent(
          title: title,
          message: message,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: effectiveDuration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showDesktopFeedback(
    BuildContext context, {
    required String title,
    required String message,
    required CyberMessageType type,
    required CyberPosition position,
    required bool isTransient,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    final currentIndex = _notificationCounter++;

    overlayEntry = OverlayEntry(
      builder: (context) => _CyberDesktopNotification(
        title: title,
        message: message,
        type: type,
        position: position,
        isTransient: isTransient,
        stackIndex: currentIndex,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss for transient messages
    if (isTransient) {
      Future.delayed(duration ?? const Duration(milliseconds: 1500), () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    }
  }

  // Convenience methods for common scenarios
  static void authStart(BuildContext context) {
    show(
      context,
      title: 'INITIATING_SESSION',
      message: 'Establishing encrypted tunnel...',
      type: CyberMessageType.info,
      isTransient: true,
    );
  }

  static void authSuccess(BuildContext context, String username) {
    show(
      context,
      title: 'ACCESS_GRANTED',
      message: 'Welcome back, $username.',
      type: CyberMessageType.success,
      haptic: CyberHapticType.medium,
    );
  }

  static void authFailure(BuildContext context) {
    show(
      context,
      title: 'HANDSHAKE_DENIED',
      message: 'Invalid credentials. Incident logged.',
      type: CyberMessageType.error,
      haptic: CyberHapticType.heavy,
    );
  }

  static void mfaRequired(BuildContext context) {
    show(
      context,
      title: 'VERIFICATION_REQUIRED',
      message: 'Encrypted token sent to your terminal.',
      type: CyberMessageType.info,
      haptic: CyberHapticType.light,
    );
  }

  static void mfaConfirmed(BuildContext context) {
    show(
      context,
      title: 'IDENTITY_CONFIRMED',
      message: 'Secondary protocol complete.',
      type: CyberMessageType.success,
      haptic: CyberHapticType.medium,
    );
  }

  static void deployingAsset(BuildContext context) {
    show(
      context,
      title: 'DEPLOYING_ASSET',
      message: 'Routing request to edge server...',
      type: CyberMessageType.info,
      isTransient: true,
      position: CyberPosition.topCenter,
    );
  }

  static void deploymentComplete(BuildContext context) {
    show(
      context,
      title: 'DEPLOYMENT_COMPLETE',
      message: 'Alias is now live and propagating.',
      type: CyberMessageType.success,
      haptic: CyberHapticType.medium,
    );
  }

  static void namespaceCollision(BuildContext context) {
    show(
      context,
      title: 'NAMESPACE_COLLISION',
      message: 'Alias already exists. Select unique ID.',
      type: CyberMessageType.warning,
      haptic: CyberHapticType.heavy,
    );
  }

  static void bufferLoaded(BuildContext context) {
    show(
      context,
      title: 'BUFFER_LOADED',
      message: 'Short URL copied to local memory.',
      type: CyberMessageType.info,
      haptic: CyberHapticType.light,
      isTransient: true,
      position: CyberPosition.bottomRight,
    );
  }

  static void assetDecommissioned(BuildContext context) {
    show(
      context,
      title: 'ASSET_DECOMMISSIONED',
      message: 'URL has been scrubbed from the registry.',
      type: CyberMessageType.warning,
      haptic: CyberHapticType.heavy,
    );
  }

  static void syncingTelemetry(BuildContext context) {
    show(
      context,
      title: 'SYNCING_TELEMETRY',
      message: 'Updating system load and click counts...',
      type: CyberMessageType.info,
      isTransient: true,
      position: CyberPosition.topCenter,
    );
  }

  static void telemetryOffline(BuildContext context) {
    show(
      context,
      title: 'TELEMETRY_OFFLINE',
      message: 'Failed to fetch remote nodes. Using cached data.',
      type: CyberMessageType.error,
      haptic: CyberHapticType.heavy,
    );
  }

  static void geospatialReady(BuildContext context) {
    show(
      context,
      title: 'GEOSPATIAL_READY',
      message: 'World map polygons projected.',
      type: CyberMessageType.success,
      isTransient: true,
    );
  }

  static void throttlingActive(BuildContext context) {
    show(
      context,
      title: 'THROTTLING_ACTIVE',
      message: 'Request frequency exceeded. Cooling down.',
      type: CyberMessageType.error,
      haptic: CyberHapticType.heavy,
    );
  }

  static void perimeterBreach(BuildContext context) {
    show(
      context,
      title: 'PERIMETER_BREACH',
      message: 'Suspicious packet headers detected. Session flagged.',
      type: CyberMessageType.error,
      haptic: CyberHapticType.heavy,
    );
  }

  static void connectionUnstable(BuildContext context) {
    show(
      context,
      title: 'CONNECTION_UNSTABLE',
      message: 'Searching for gateway signal...',
      type: CyberMessageType.warning,
    );
  }

  static void visualOverhaul(BuildContext context) {
    show(
      context,
      title: 'VISUAL_OVERHAUL',
      message: 'Interface palette reconfigured.',
      type: CyberMessageType.info,
      haptic: CyberHapticType.selection,
      isTransient: true,
    );
  }

  static void kineticFeedback(BuildContext context, bool enabled) {
    show(
      context,
      title: 'KINETIC_FEEDBACK',
      message:
          'Physical interaction engine ${enabled ? "enabled" : "disabled"}.',
      type: CyberMessageType.info,
      haptic: CyberHapticType.selection,
      isTransient: true,
    );
  }

  static void factoryRestore(BuildContext context) {
    show(
      context,
      title: 'FACTORY_RESTORE',
      message: 'All preferences returned to default.',
      type: CyberMessageType.warning,
      haptic: CyberHapticType.heavy,
    );
  }
}

// Mobile SnackBar Content
class _CyberSnackBarContent extends StatelessWidget {
  final String title;
  final String message;
  final CyberMessageType type;

  const _CyberSnackBarContent({
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.98);
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark
        ? _getAccentColor().withValues(alpha: 0.5)
        : _getAccentColor().withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _getAccentColor().withValues(alpha: isDark ? 0.3 : 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getAccentColor().withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(), color: _getAccentColor(), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getAccentColor(),
                    letterSpacing: 1.2,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 13, color: textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor() {
    switch (type) {
      case CyberMessageType.info:
        return Colors.cyanAccent;
      case CyberMessageType.success:
        return Colors.greenAccent;
      case CyberMessageType.warning:
        return Colors.amber;
      case CyberMessageType.error:
        return Colors.redAccent;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case CyberMessageType.info:
        return PhosphorIconsRegular.info;
      case CyberMessageType.success:
        return PhosphorIconsRegular.checkCircle;
      case CyberMessageType.warning:
        return PhosphorIconsRegular.warning;
      case CyberMessageType.error:
        return PhosphorIconsRegular.xCircle;
    }
  }
}

// Desktop Notification
class _CyberDesktopNotification extends StatefulWidget {
  final String title;
  final String message;
  final CyberMessageType type;
  final CyberPosition position;
  final bool isTransient;
  final int stackIndex;
  final VoidCallback onDismiss;

  const _CyberDesktopNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.position,
    required this.isTransient,
    required this.stackIndex,
    required this.onDismiss,
  });

  @override
  State<_CyberDesktopNotification> createState() =>
      _CyberDesktopNotificationState();
}

class _CyberDesktopNotificationState extends State<_CyberDesktopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  Offset _getInitialOffset() {
    switch (widget.position) {
      case CyberPosition.topRight:
        return const Offset(1, 0);
      case CyberPosition.topCenter:
        return const Offset(0, -1);
      case CyberPosition.center:
        return const Offset(0, 0);
      case CyberPosition.bottomRight:
        return const Offset(1, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.98);
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final borderColor = isDark
        ? _getAccentColor().withValues(alpha: 0.5)
        : _getAccentColor().withValues(alpha: 0.4);
    final shadowOpacity = isDark ? 0.3 : 0.15;
    final iconBgOpacity = isDark ? 0.2 : 0.1;

    return Positioned(
      top: _getTop(),
      right: _getRight(),
      bottom: _getBottom(),
      child: IgnorePointer(
        ignoring: false,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              elevation: widget.stackIndex.toDouble(),
              child: Container(
                width: widget.position == CyberPosition.topCenter ? 400 : 350,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _getAccentColor().withValues(alpha: shadowOpacity),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getAccentColor().withValues(
                              alpha: iconBgOpacity,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIcon(),
                            color: _getAccentColor(),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getAccentColor(),
                              letterSpacing: 1.5,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                        if (!widget.isTransient)
                          IconButton(
                            icon: Icon(
                              PhosphorIconsRegular.x,
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: _dismiss,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    // Animated progress bar for transient messages
                    if (widget.isTransient) ...[
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor:
                                (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(
                              _getAccentColor().withValues(alpha: 0.5),
                            ),
                            minHeight: 2,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? _getTop() {
    switch (widget.position) {
      case CyberPosition.topRight:
      case CyberPosition.topCenter:
        return 0;
      case CyberPosition.center:
        return MediaQuery.of(context).size.height / 2 - 100;
      case CyberPosition.bottomRight:
        return null;
    }
  }

  double? _getRight() {
    switch (widget.position) {
      case CyberPosition.topRight:
      case CyberPosition.bottomRight:
        return 0;
      case CyberPosition.topCenter:
      case CyberPosition.center:
        return null;
    }
  }

  double? _getBottom() {
    switch (widget.position) {
      case CyberPosition.bottomRight:
        return 0;
      default:
        return null;
    }
  }

  Color _getAccentColor() {
    switch (widget.type) {
      case CyberMessageType.info:
        return Colors.cyanAccent;
      case CyberMessageType.success:
        return Colors.greenAccent;
      case CyberMessageType.warning:
        return Colors.amber;
      case CyberMessageType.error:
        return Colors.redAccent;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case CyberMessageType.info:
        return PhosphorIconsRegular.info;
      case CyberMessageType.success:
        return PhosphorIconsRegular.checkCircle;
      case CyberMessageType.warning:
        return PhosphorIconsRegular.warning;
      case CyberMessageType.error:
        return PhosphorIconsRegular.xCircle;
    }
  }
}
