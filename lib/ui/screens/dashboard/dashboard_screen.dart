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

    return CyberScaffold(
      title: "DASHBOARD",
      enableBack: false,
      actions: [
        IconButton(
          icon: Icon(PhosphorIconsRegular.gear),
          onPressed: () => context.push('/appearance'),
        ),
        IconButton(
          icon: Icon(PhosphorIconsRegular.signOut, color: Colors.white),
          onPressed: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/signin');
          },
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-url'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
          const Text(
            "DEPLOYMENTS",
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          if (urlsState.isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
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
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlRow(UrlModel url) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "${url.clickCount}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(PhosphorIconsRegular.chartBar, size: 14, color: Colors.white54),
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
          Icon(PhosphorIconsRegular.ghost, size: 48, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            "No active deployments",
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
