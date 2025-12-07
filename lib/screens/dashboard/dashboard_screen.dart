import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/skeleton_loader.dart';
import '../../providers/providers.dart';
import '../../config.dart';
import '../../utils/responsive.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await ref.read(urlsProvider.notifier).loadUrls();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, responsive) {
        return Scaffold(
          appBar: responsive.isMobile
              ? AppBar(
                  title: const Text('Dashboard'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle),
                      onPressed: () {},
                    ),
                  ],
                )
              : null,
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: CenteredWebContent(
              child: CustomScrollView(
                slivers: [
                  // Web/Desktop Header (replaces AppBar)
                  if (!responsive.isMobile)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: responsive.pagePadding,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 32,
                                  color: AppTheme.accentTeal,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'URL Shortener',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.account_circle),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: responsive.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: responsive.valueWhen(
                                    mobile: 22,
                                    tablet: 26,
                                    desktop: 28,
                                  ),
                                ),
                          ),
                          SizedBox(height: responsive.spacing),
                          ref.watch(urlsProvider).isLoading
                              ? Row(
                                  children: [
                                    Expanded(child: StatCardSkeleton()),
                                    SizedBox(width: responsive.spacing * 0.75),
                                    Expanded(child: StatCardSkeleton()),
                                    SizedBox(width: responsive.spacing * 0.75),
                                    Expanded(child: StatCardSkeleton()),
                                  ],
                                )
                              : responsive.isMobile
                              ? Column(
                                  children: [
                                    _buildStatCard(
                                      context,
                                      responsive,
                                      'Total URLs',
                                      ref
                                          .watch(urlsProvider)
                                          .urls
                                          .length
                                          .toString(),
                                      Icons.link,
                                      AppTheme.accentTeal,
                                    ),
                                    SizedBox(height: responsive.spacing),
                                    _buildStatCard(
                                      context,
                                      responsive,
                                      'Total Clicks',
                                      ref
                                          .watch(urlsProvider)
                                          .urls
                                          .fold<int>(
                                            0,
                                            (sum, url) => sum + url.clickCount,
                                          )
                                          .toString(),
                                      Icons.mouse,
                                      AppTheme.lightBlue,
                                    ),
                                    SizedBox(height: responsive.spacing),
                                    _buildStatCard(
                                      context,
                                      responsive,
                                      'Active',
                                      ref
                                          .watch(urlsProvider)
                                          .urls
                                          .where((url) => url.isActive)
                                          .length
                                          .toString(),
                                      Icons.check_circle,
                                      AppTheme.success,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        responsive,
                                        'Total URLs',
                                        ref
                                            .watch(urlsProvider)
                                            .urls
                                            .length
                                            .toString(),
                                        Icons.link,
                                        AppTheme.accentTeal,
                                      ),
                                    ),
                                    SizedBox(width: responsive.spacing * 0.75),
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        responsive,
                                        'Total Clicks',
                                        ref
                                            .watch(urlsProvider)
                                            .urls
                                            .fold<int>(
                                              0,
                                              (sum, url) =>
                                                  sum + url.clickCount,
                                            )
                                            .toString(),
                                        Icons.mouse,
                                        AppTheme.lightBlue,
                                      ),
                                    ),
                                    SizedBox(width: responsive.spacing * 0.75),
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        responsive,
                                        'Active',
                                        ref
                                            .watch(urlsProvider)
                                            .urls
                                            .where((url) => url.isActive)
                                            .length
                                            .toString(),
                                        Icons.check_circle,
                                        AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: responsive.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: responsive.spacing * 0.5),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/create-url');
                            },
                            icon: Icon(Icons.add, size: responsive.iconSize),
                            label: Text(
                              'Create Short URL',
                              style: TextStyle(
                                fontSize: responsive.valueWhen(
                                  mobile: 14,
                                  tablet: 15,
                                  desktop: 16,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                double.infinity,
                                responsive.buttonHeight,
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.spacing * 1.5),
                        ],
                      ),
                    ),
                  ),

                  // Recent URLs Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent URLs',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/all-urls');
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // URL List
                  ref.watch(urlsProvider).isLoading
                      ? SliverPadding(
                          padding: responsive.pagePadding,
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const UrlCardSkeleton(),
                              childCount: 3,
                            ),
                          ),
                        )
                      : ref.watch(urlsProvider).urls.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.link_off,
                                  size: responsive.valueWhen(
                                    mobile: 48,
                                    tablet: 56,
                                    desktop: 64,
                                  ),
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(height: responsive.spacing),
                                Text(
                                  'No URLs yet',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: responsive.valueWhen(
                                          mobile: 18,
                                          tablet: 20,
                                          desktop: 22,
                                        ),
                                      ),
                                ),
                                SizedBox(height: responsive.spacing * 0.5),
                                Text(
                                  'Create your first short URL to get started',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: responsive.pagePadding,
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final url = ref.watch(urlsProvider).urls[index];
                              return _buildUrlCard(context, responsive, url);
                            }, childCount: ref.watch(urlsProvider).urls.length),
                          ),
                        ),
                ],
              ),
            ),
          ),
          // Region indicator at bottom
          bottomNavigationBar: Container(
            padding: EdgeInsets.all(responsive.spacing * 0.5),
            color: AppTheme.backgroundLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: responsive.valueWhen(
                    mobile: 14,
                    tablet: 16,
                    desktop: 16,
                  ),
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connected to: ${ref.watch(regionProvider)}${AppConfig.isDebugMode ? " (Debug Mode)" : ""}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.valueWhen(
                      mobile: 11,
                      tablet: 12,
                      desktop: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    Responsive responsive,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: responsive.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.valueWhen(
                      mobile: 12,
                      tablet: 14,
                      desktop: 14,
                    ),
                  ),
                ),
                Icon(icon, size: responsive.iconSize, color: color),
              ],
            ),
            SizedBox(height: responsive.spacing * 0.75),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: color,
                fontSize: responsive.valueWhen(
                  mobile: 28,
                  tablet: 32,
                  desktop: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlCard(
    BuildContext context,
    Responsive responsive,
    UrlModel url,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: responsive.spacing),
      child: InkWell(
        onTap: () {
          context.push('/url-details', extra: url);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: responsive.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      url.shortUrl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.valueWhen(
                          mobile: 14,
                          tablet: 16,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: responsive.iconSize * 0.9),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing * 0.5),
              Text(
                url.originalUrl,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: responsive.valueWhen(
                    mobile: 12,
                    tablet: 14,
                    desktop: 14,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: responsive.spacing),
              Row(
                children: [
                  Icon(
                    Icons.mouse,
                    size: responsive.valueWhen(
                      mobile: 14,
                      tablet: 16,
                      desktop: 16,
                    ),
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${url.clickCount} clicks',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: responsive.valueWhen(
                        mobile: 12,
                        tablet: 13,
                        desktop: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(url.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
