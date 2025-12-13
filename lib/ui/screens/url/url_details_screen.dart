import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
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
          icon: Icon(
            PhosphorIconsRegular.trash,
            color: theme.colorScheme.error,
          ),
          onPressed: () {
            ref.read(urlsProvider.notifier).deleteUrl(url.id);
            context.pop();
          },
        ),
      ],
      body: SingleChildScrollView(
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
                      PhosphorIconsRegular.qrCode,
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    url.originalUrl,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: txtColor.withValues(alpha: 0.6)),
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
