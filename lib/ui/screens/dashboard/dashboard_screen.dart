import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(urlsProvider.notifier).loadUrls(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      enableBack: false,
      // FIX: Removed actions list. The Rail handles settings/theme now.
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-url'),
        backgroundColor: txtColor,
        foregroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(PhosphorIconsBold.plus),
      ),
      body: ListView(
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
                  "Active Links",
                  "${urlsState.urls.length}",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  "Total Clicks",
                  "${urlsState.urls.fold<int>(0, (p, c) => p + c.clickCount)}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          Text(
            "RECENT DEPLOYMENTS",
            style: TextStyle(
              color: txtColor.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          if (urlsState.isLoading)
            Center(child: CircularProgressIndicator(color: txtColor))
          else if (urlsState.urls.isEmpty)
            _buildEmpty()
          else
            ...urlsState.urls.map(
              (url) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUrlRow(url),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              color: txtColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: txtColor.withValues(alpha: 0.5),
              fontSize: 12,
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
          Icon(
            PhosphorIconsRegular.link,
            color: txtColor.withValues(alpha: 0.5),
          ),
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
                const SizedBox(height: 4),
                Text(
                  url.originalUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: txtColor.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "${url.clickCount}",
            style: TextStyle(color: txtColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(
            PhosphorIconsRegular.chartBar,
            size: 14,
            color: txtColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final txtColor = Theme.of(context).disabledColor;
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.ghost, size: 48, color: txtColor),
          const SizedBox(height: 16),
          Text("No active deployments", style: TextStyle(color: txtColor)),
        ],
      ),
    );
  }
}
