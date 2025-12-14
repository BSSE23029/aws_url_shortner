import 'package:flutter/material.dart';
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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(urlsProvider.notifier).loadUrls(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final themeMode = ref.watch(themeProvider).mode;
    // Check if currently effectively dark
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return CyberScaffold(
      title: "DASHBOARD",
      enableBack: false,
      actions: [
        // 1. THEME TOGGLE BUTTON
        IconButton(
          icon: Icon(isDark ? PhosphorIconsBold.sun : PhosphorIconsBold.moon),
          tooltip: "Cycle Theme (System/Light/Dark)",
          onPressed: () => ref.read(themeProvider.notifier).cycleTheme(),
        ),
        // 2. SETTINGS BUTTON (Goes to Appearance Screen)
        IconButton(
          icon: Icon(PhosphorIconsBold.gear),
          tooltip: "Settings",
          onPressed: () => context.push('/appearance'),
        ),
        // 3. LOGOUT
        IconButton(
          icon: Icon(
            PhosphorIconsBold.signOut,
            color: Theme.of(context).colorScheme.error,
          ),
          tooltip: "Logout",
          onPressed: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/signin');
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-url'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(PhosphorIconsBold.plus),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Active Links",
                  "${urlsState.urls.length}",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  "Total Clicks",
                  "${urlsState.urls.fold<int>(0, (p, c) => p + c.clickCount)}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            "DEPLOYMENTS",
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (urlsState.isLoading)
            const Center(child: CircularProgressIndicator())
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

  // Updated widgets to use Theme colors instead of hardcoded white
  Widget _buildStatCard(String label, String value) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlRow(UrlModel url) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: () => context.push('/url-details', extra: url),
      child: Row(
        children: [
          Icon(PhosphorIconsBold.link, color: txtColor.withValues(alpha: 0.5)),
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
                  ),
                ),
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
            PhosphorIconsBold.chartBar,
            size: 14,
            color: txtColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            PhosphorIconsBold.ghost,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            "No active deployments",
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }
}
