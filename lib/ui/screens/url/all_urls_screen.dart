import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart'; // Added this import

class AllUrlsScreen extends ConsumerWidget {
  const AllUrlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlsState = ref.watch(urlsProvider);

    return CyberScaffold(
      title: "ARCHIVES",
      body: urlsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: urlsState.urls.length,
              itemBuilder: (context, index) {
                final url = urlsState.urls[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 30)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      onTap: () => context.push('/url-details', extra: url),
                      child: Row(
                        children: [
                          Icon(PhosphorIconsBold.link, color: Colors.white54),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  url.shortUrl,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  url.originalUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              PhosphorIconsBold.copy,
                              color: Colors.white54,
                              size: 20,
                            ),
                            onPressed: () async {
                              if (ref.read(themeProvider).enableHaptics) {
                                HapticFeedback.mediumImpact();
                              }
                              await Clipboard.setData(
                                ClipboardData(text: url.shortUrl),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          PhosphorIconsBold.checkCircle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Copied to clipboard',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                  ),
                                );
                              }
                            },
                            tooltip: 'Copy link',
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            PhosphorIconsBold.caretRight,
                            color: Colors.white24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
