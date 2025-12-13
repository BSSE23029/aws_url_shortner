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
    return CyberScaffold(
      title: "TELEMETRY",
      actions: [
        IconButton(
          icon: Icon(PhosphorIconsRegular.trash, color: Colors.red),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.qrCode,
                      size: 120,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    url.shortUrl,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    url.originalUrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailStat("Total Clicks", "${url.clickCount}"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailStat(
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

  Widget _buildDetailStat(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
