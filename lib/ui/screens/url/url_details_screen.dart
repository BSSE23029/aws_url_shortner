import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../widgets/physics_button.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';

class UrlDetailsScreen extends ConsumerStatefulWidget {
  final UrlModel url;
  const UrlDetailsScreen({super.key, required this.url});

  @override
  ConsumerState<UrlDetailsScreen> createState() => _UrlDetailsScreenState();
}

class _UrlDetailsScreenState extends ConsumerState<UrlDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _statsController;
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final txtColor = isDark ? Colors.white : Colors.black87;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return CyberScaffold(
      title: "LINK TELEMETRY",
      actions: [
        if (!_showDeleteConfirm)
          IconButton(
            icon: Icon(PhosphorIconsBold.trash, color: theme.colorScheme.error),
            onPressed: () {
              setState(() => _showDeleteConfirm = true);
              if (ref.read(themeProvider).enableHaptics) {
                HapticFeedback.mediumImpact();
              }
            },
            tooltip: 'Delete URL',
          ),
      ],
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              children: [
                // QR Code Section with enhanced design
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return GlassCard(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          children: [
                            // Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent.withAlpha(
                                          (150 * _pulseController.value)
                                              .round(),
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ACTIVE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 16 : 24),

                            // QR Code with glow effect
                            Container(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  isMobile ? 12 : 16,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (ref.read(themeProvider).mode ==
                                                    ThemeMode.dark
                                                ? Colors.cyanAccent
                                                : theme.colorScheme.primary)
                                            .withAlpha(100),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child:
                                  QrImageView(
                                        data: widget.url.shortUrl,
                                        version: QrVersions.auto,
                                        size: isMobile ? 160 : 200,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Colors.black,
                                        ),
                                      )
                                      .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(),
                                      )
                                      .shimmer(
                                        duration: 3.seconds,
                                        color: theme.colorScheme.primary
                                            .withAlpha(30),
                                      ),
                            ),
                            SizedBox(height: isMobile ? 16 : 24),

                            // Short URL Display
                            Container(
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(10)
                                    : Colors.black.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withAlpha(
                                    50,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SelectableText(
                                      widget.url.shortUrl,
                                      style:
                                          (isMobile
                                                  ? theme.textTheme.bodyMedium
                                                  : theme.textTheme.bodyLarge)
                                              ?.copyWith(
                                                color: txtColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      PhosphorIconsBold.copy,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: widget.url.shortUrl,
                                        ),
                                      );
                                      if (ref
                                          .read(themeProvider)
                                          .enableHaptics) {
                                        HapticFeedback.lightImpact();
                                      }
                                      if (context.mounted) {
                                        CyberFeedback.show(
                                          context,
                                          title: 'Copied!',
                                          message:
                                              'Short URL copied to clipboard',
                                          type: CyberMessageType.success,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Performance Metrics
                GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERFORMANCE METRICS',
                          style:
                              (isMobile
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isMobile ? 1.2 : 1.5,
                                  ),
                        ),
                        SizedBox(height: isMobile ? 16 : 24),
                        GridView.count(
                          crossAxisCount: isMobile ? 1 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: isMobile ? 12 : 16,
                          crossAxisSpacing: isMobile ? 12 : 16,
                          childAspectRatio: isMobile ? 2.5 : 1.5,
                          children: [
                            _buildDetailStat(
                              PhosphorIconsBold.chartLine,
                              'Total Clicks',
                              '${widget.url.clickCount}',
                              Colors.greenAccent,
                              _statsController,
                            ),
                            _buildDetailStat(
                              PhosphorIconsBold.calendarBlank,
                              'Created',
                              _formatDate(widget.url.createdAt),
                              Colors.blueAccent,
                              _statsController,
                            ),
                            _buildDetailStat(
                              PhosphorIconsBold.clockCounterClockwise,
                              'Last Access',
                              _getLastAccessText(),
                              Colors.orangeAccent,
                              _statsController,
                            ),
                            _buildDetailStat(
                              PhosphorIconsBold.trendUp,
                              'Avg / Day',
                              _calculateAvgPerDay(),
                              Colors.purpleAccent,
                              _statsController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Original URL Section
                GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIconsBold.link,
                              color: theme.colorScheme.primary,
                              size: isMobile ? 18 : 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ORIGINAL URL',
                              style:
                                  (isMobile
                                          ? theme.textTheme.bodySmall
                                          : theme.textTheme.titleSmall)
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: isMobile ? 1.0 : 1.2,
                                      ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(5)
                                : Colors.black.withAlpha(5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            widget.url.originalUrl,
                            style:
                                (isMobile
                                        ? theme.textTheme.bodySmall
                                        : theme.textTheme.bodyMedium)
                                    ?.copyWith(color: txtColor.withAlpha(200)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isMobile ? 16 : 24),

                // Action Buttons
                isMobile
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: PhysicsButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: widget.url.shortUrl),
                                );
                                if (ref.read(themeProvider).enableHaptics) {
                                  HapticFeedback.lightImpact();
                                }
                                if (context.mounted) {
                                  CyberFeedback.show(
                                    context,
                                    title: 'Copied!',
                                    message: 'Short URL copied to clipboard',
                                    type: CyberMessageType.success,
                                  );
                                }
                              },
                              backgroundColor: theme.colorScheme.primary,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIconsBold.copy,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COPY',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: PhysicsButton(
                              onPressed: () {
                                if (ref.read(themeProvider).enableHaptics) {
                                  HapticFeedback.lightImpact();
                                }
                                CyberFeedback.show(
                                  context,
                                  title: 'Coming Soon',
                                  message:
                                      'Share functionality will be available soon',
                                  type: CyberMessageType.info,
                                );
                              },
                              backgroundColor: Colors.white.withAlpha(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIconsBold.share,
                                    color: txtColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SHARE',
                                    style: TextStyle(
                                      color: txtColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: PhysicsButton(
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: widget.url.shortUrl),
                                );
                                if (ref.read(themeProvider).enableHaptics) {
                                  HapticFeedback.lightImpact();
                                }
                                if (context.mounted) {
                                  CyberFeedback.show(
                                    context,
                                    title: 'Copied!',
                                    message: 'Short URL copied to clipboard',
                                    type: CyberMessageType.success,
                                  );
                                }
                              },
                              backgroundColor: theme.colorScheme.primary,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIconsBold.copy,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'COPY',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PhysicsButton(
                              onPressed: () {
                                if (ref.read(themeProvider).enableHaptics) {
                                  HapticFeedback.lightImpact();
                                }
                                CyberFeedback.show(
                                  context,
                                  title: 'Coming Soon',
                                  message:
                                      'Share functionality will be available soon',
                                  type: CyberMessageType.info,
                                );
                              },
                              backgroundColor: Colors.white.withAlpha(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIconsBold.share,
                                    color: txtColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SHARE',
                                    style: TextStyle(
                                      color: txtColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                SizedBox(height: isMobile ? 60 : 100),
              ],
            ),
          ),

          // Delete Confirmation Overlay
          if (_showDeleteConfirm)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(200),
                child: Center(
                  child: GlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 20 : 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                                PhosphorIconsBold.warningCircle,
                                color: theme.colorScheme.error,
                                size: isMobile ? 48 : 64,
                              )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .shake(duration: 500.ms),
                          SizedBox(height: isMobile ? 12 : 16),
                          Text(
                            'DELETE URL?',
                            style:
                                (isMobile
                                        ? theme.textTheme.titleMedium
                                        : theme.textTheme.titleLarge)
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.error,
                                    ),
                          ),
                          SizedBox(height: isMobile ? 6 : 8),
                          Text(
                            'This action cannot be undone',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: txtColor.withAlpha(180),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: PhysicsButton(
                                  onPressed: () {
                                    setState(() => _showDeleteConfirm = false);
                                    if (ref.read(themeProvider).enableHaptics) {
                                      HapticFeedback.lightImpact();
                                    }
                                  },
                                  backgroundColor: Colors.white.withAlpha(20),
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: txtColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: PhysicsButton(
                                  onPressed: () async {
                                    if (ref.read(themeProvider).enableHaptics) {
                                      HapticFeedback.heavyImpact();
                                    }

                                    // Store initial state to check if deletion succeeded
                                    final urlsBeforeDeletion = ref
                                        .read(urlsProvider)
                                        .urls
                                        .length;

                                    await ref
                                        .read(urlsProvider.notifier)
                                        .deleteUrl(widget.url.id);

                                    if (context.mounted) {
                                      // Check if deletion was successful by checking if URL count decreased
                                      final urlsAfterDeletion = ref
                                          .read(urlsProvider)
                                          .urls
                                          .length;
                                      final errorMessage = ref
                                          .read(urlsProvider)
                                          .errorMessage;

                                      if (errorMessage != null &&
                                          errorMessage.isNotEmpty) {
                                        // Deletion failed - stay on page and show error
                                        setState(
                                          () => _showDeleteConfirm = false,
                                        );
                                        CyberFeedback.show(
                                          context,
                                          title: 'Delete Failed',
                                          message:
                                              errorMessage.contains(
                                                    'Unauthorized',
                                                  ) ||
                                                  errorMessage.contains('401')
                                              ? 'You do not have permission to delete this URL'
                                              : 'Failed to delete: $errorMessage',
                                          type: CyberMessageType.error,
                                        );
                                      } else if (urlsAfterDeletion <
                                          urlsBeforeDeletion) {
                                        // Deletion succeeded
                                        context.pop();
                                        CyberFeedback.show(
                                          context,
                                          title: 'Deleted',
                                          message: 'URL has been deleted',
                                          type: CyberMessageType.success,
                                        );
                                      }
                                    }
                                  },
                                  backgroundColor: theme.colorScheme.error,
                                  child: Text(
                                    'DELETE',
                                    style: TextStyle(
                                      color: theme.colorScheme.onError,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().scale(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(
    IconData icon,
    String label,
    String value,
    Color color,
    AnimationController controller,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, progress, child) {
        return Transform.scale(
          scale: 0.8 + (progress * 0.2),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withAlpha((50 * progress).round()),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: isMobile ? 24 : 32),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  value,
                  style:
                      (isMobile
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                ),
                SizedBox(height: isMobile ? 3 : 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withAlpha(
                      150,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getLastAccessText() {
    // This would come from actual analytics data
    // For now, return a placeholder
    return 'N/A';
  }

  String _calculateAvgPerDay() {
    final daysSinceCreation = DateTime.now()
        .difference(widget.url.createdAt)
        .inDays;
    if (daysSinceCreation == 0) return '${widget.url.clickCount}';
    return (widget.url.clickCount / daysSinceCreation).toStringAsFixed(1);
  }
}
