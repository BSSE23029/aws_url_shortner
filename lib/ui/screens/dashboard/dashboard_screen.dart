import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';
import '../../../providers/theme_provider.dart';
import '../../../models/models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Only load if the list is empty to prevent theme-change re-fetches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(urlsProvider).urls.isEmpty) {
        ref.read(urlsProvider.notifier).loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;
    final enableAnims = ref.watch(themeProvider).enableAnimations;

    return CyberScaffold(
      enableBack: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-url'),
        backgroundColor: txtColor,
        foregroundColor: theme.scaffoldBackgroundColor,
        child: const Icon(PhosphorIconsBold.plus),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              "Overview",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "MY CLICKS",
                    "${urlsState.myTotalClicks}",
                    PhosphorIconsRegular.user,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "GLOBAL CLICKS",
                    "${urlsState.globalStats.totalSystemClicks}",
                    PhosphorIconsRegular.globeHemisphereWest,
                    isGlobal: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              "RECENT DEPLOYMENTS",
              style: TextStyle(
                color: txtColor.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (urlsState.isLoading && urlsState.urls.isEmpty)
              Center(child: CircularProgressIndicator(color: txtColor))
            else if (urlsState.urls.isEmpty)
              const Center(child: Text("No deployments found"))
            else
              ...urlsState.urls.asMap().entries.map((entry) {
                final index = entry.key;
                final url = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: enableAnims ? 0.0 : 1.0, end: 1.0),
                  duration: enableAnims
                      ? Duration(milliseconds: 300 + (index * 50))
                      : Duration.zero,
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildUrlRow(url),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    bool isGlobal = false,
  }) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      customColor: isGlobal ? Colors.purple.withOpacity(0.05) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isGlobal ? Colors.purpleAccent : txtColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w200,
              color: txtColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: txtColor.withOpacity(0.5),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlRow(UrlModel url) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      onTap: () => context.push('/url-details', extra: url),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.link, color: txtColor.withOpacity(0.5)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  url.shortUrl,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                    fontSize: 16,
                  ),
                ),
                Text(
                  url.originalUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: txtColor.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${url.clickCount}",
            style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
