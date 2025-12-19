import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class UrlDetailsScreen extends ConsumerWidget {
  final UrlModel url;
  const UrlDetailsScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      title: "TELEMETRY",
      actions: [
        IconButton(
          icon: Icon(PhosphorIconsBold.trash, color: theme.colorScheme.error),
          onPressed: () {
            HapticFeedback.heavyImpact();
            CyberFeedback.assetDecommissioned(context);
            ref.read(urlsProvider.notifier).deleteUrl(url.id);
            context.pop();
          },
          tooltip: 'Delete URL',
        ),
      ],
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: txtColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        PhosphorIconsBold.qrCode,
                        size: 120,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      url.shortUrl,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: txtColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: txtColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        url.originalUrl,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: txtColor.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await Clipboard.setData(
                                ClipboardData(text: url.shortUrl),
                              );
                              if (context.mounted) {
                                CyberFeedback.bufferLoaded(context);
                              }
                            },
                            icon: Icon(PhosphorIconsBold.copy, size: 18),
                            label: const Text('Copy Link'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: txtColor,
                              foregroundColor: theme.scaffoldBackgroundColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Share functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Share feature coming soon',
                                  ),
                                  backgroundColor: txtColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              PhosphorIconsBold.shareNetwork,
                              size: 18,
                            ),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: txtColor,
                              side: BorderSide(
                                color: txtColor.withValues(alpha: 0.3),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStat(
                      context,
                      "Total Clicks",
                      "${url.clickCount}",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailStat(
                      context,
                      "Created",
                      "${url.createdAt.day}/${url.createdAt.month}",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(BuildContext context, String label, String value) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: txtColor.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
