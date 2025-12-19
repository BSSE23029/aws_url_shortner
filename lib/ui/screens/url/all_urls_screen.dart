import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart'; // Added this import

class AllUrlsScreen extends ConsumerWidget {
  const AllUrlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlsState = ref.watch(urlsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white54 : Colors.black54;
    final subtextColor = isDark ? Colors.white38 : Colors.black45;
    final chevronColor = isDark ? Colors.white24 : Colors.black26;

    return CyberScaffold(
      title: "ARCHIVES",
      body: urlsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
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
                          Icon(PhosphorIconsBold.link, color: iconColor),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  url.shortUrl,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  url.originalUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              PhosphorIconsBold.copy,
                              color: iconColor,
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
                                CyberFeedback.bufferLoaded(context);
                              }
                            },
                            tooltip: 'Copy link',
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            PhosphorIconsBold.caretRight,
                            color: chevronColor,
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
