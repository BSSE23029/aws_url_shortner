import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';

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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/url-details', extra: url),
                    child: Row(
                      children: [
                        Icon(PhosphorIconsRegular.link, color: Colors.white54),
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
                        Icon(
                          PhosphorIconsRegular.caretRight,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
