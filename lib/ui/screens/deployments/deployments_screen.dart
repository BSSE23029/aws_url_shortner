import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../providers/providers.dart';
import '../../../models/models.dart';

class DeploymentsScreen extends ConsumerStatefulWidget {
  const DeploymentsScreen({super.key});

  @override
  ConsumerState<DeploymentsScreen> createState() => _DeploymentsScreenState();
}

class _DeploymentsScreenState extends ConsumerState<DeploymentsScreen> {
  String _searchQuery = '';
  String _sortBy = 'clicks'; // 'clicks', 'date', 'name'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(urlsProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Filter and sort URLs
    var filteredUrls = urlsState.urls.where((url) {
      if (_searchQuery.isEmpty) return true;
      return url.shortCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          url.originalUrl.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort URLs
    switch (_sortBy) {
      case 'clicks':
        filteredUrls.sort((a, b) => b.clickCount.compareTo(a.clickCount));
        break;
      case 'date':
        filteredUrls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
        filteredUrls.sort((a, b) => a.shortCode.compareTo(b.shortCode));
        break;
    }

    return CyberScaffold(
      enableBack: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-url'),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(PhosphorIconsBold.plus),
        label: const Text(
          'NEW LINK',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.package,
                        color: Colors.cyanAccent,
                        size: isMobile ? 24 : 28,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'ACTIVE DEPLOYMENTS',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isMobile ? 1 : 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filteredUrls.length} of ${urlsState.urls.length} links',
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.5),
                      fontFamily: 'Courier',
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),

                  // Search and Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          style: TextStyle(color: color),
                          decoration: InputDecoration(
                            hintText: 'Search links...',
                            hintStyle: TextStyle(
                              color: color.withValues(alpha: 0.3),
                            ),
                            prefixIcon: Icon(
                              PhosphorIconsRegular.magnifyingGlass,
                              color: color.withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<String>(
                        icon: Icon(
                          PhosphorIconsRegular.funnelSimple,
                          color: color,
                        ),
                        onSelected: (value) => setState(() => _sortBy = value),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'clicks',
                            child: Row(
                              children: [
                                Icon(PhosphorIconsRegular.chartBar, size: 18),
                                const SizedBox(width: 8),
                                const Text('Sort by Clicks'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'date',
                            child: Row(
                              children: [
                                Icon(PhosphorIconsRegular.calendar, size: 18),
                                const SizedBox(width: 8),
                                const Text('Sort by Date'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'name',
                            child: Row(
                              children: [
                                Icon(PhosphorIconsRegular.textAa, size: 18),
                                const SizedBox(width: 8),
                                const Text('Sort by Name'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // URLs List
            Expanded(
              child: urlsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUrls.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            PhosphorIconsRegular.package,
                            size: 64,
                            color: color.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'NO DEPLOYMENTS YET'
                                : 'NO RESULTS FOUND',
                            style: TextStyle(
                              fontSize: 14,
                              color: color.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Create your first shortened link',
                              style: TextStyle(
                                fontSize: 12,
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: 8,
                      ),
                      itemCount: filteredUrls.length,
                      itemBuilder: (context, index) {
                        final url = filteredUrls[index];
                        return _buildUrlCard(url, color, isDark, context);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlCard(
    UrlModel url,
    Color color,
    bool isDark,
    BuildContext context,
  ) {
    final daysSinceCreation = DateTime.now().difference(url.createdAt).inDays;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: GlassCard(
        onTap: () => context.push('/url-details', extra: url),
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: isMobile ? 36 : 40,
                        height: isMobile ? 36 : 40,
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.link,
                          color: Colors.cyanAccent,
                          size: isMobile ? 18 : 20,
                        ),
                      ),
                      SizedBox(width: isMobile ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              url.shortCode.toUpperCase(),
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: isMobile ? 0.5 : 1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$daysSinceCreation days ago',
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withValues(alpha: 0.4),
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.copy,
                    color: color.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: url.shortUrl));
                    CyberFeedback.bufferLoaded(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Original URL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.arrowSquareOut,
                    size: 14,
                    color: color.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      url.originalUrl,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.7),
                        fontFamily: 'Courier',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats Row
            if (isMobile)
              Column(
                children: [
                  Row(
                    children: [
                      _buildStatPill(
                        PhosphorIconsRegular.eye,
                        '${url.clickCount}',
                        'CLICKS',
                        Colors.cyanAccent,
                        color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatPill(
                        PhosphorIconsRegular.calendar,
                        _formatDate(url.createdAt),
                        'CREATED',
                        Colors.purpleAccent,
                        color,
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  _buildStatPill(
                    PhosphorIconsRegular.eye,
                    '${url.clickCount}',
                    'CLICKS',
                    Colors.cyanAccent,
                    color,
                  ),
                  const SizedBox(width: 12),
                  _buildStatPill(
                    PhosphorIconsRegular.calendar,
                    _formatDate(url.createdAt),
                    'CREATED',
                    Colors.purpleAccent,
                    color,
                  ),
                ],
              ),

            SizedBox(height: isMobile ? 12 : 16),

            // Mini Chart
            SizedBox(
              height: isMobile ? 30 : 40,
              child: charts.SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: const charts.CategoryAxis(isVisible: false),
                primaryYAxis: const charts.NumericAxis(isVisible: false),
                series: <charts.CartesianSeries<double, int>>[
                  charts.SplineAreaSeries<double, int>(
                    dataSource: _generateMockData(url.clickCount),
                    xValueMapper: (double d, i) => i,
                    yValueMapper: (double d, _) => d,
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                    borderColor: Colors.cyanAccent,
                    borderWidth: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(
    IconData icon,
    String value,
    String label,
    Color accentColor,
    Color baseColor,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 14 : 16, color: accentColor),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      fontFamily: 'Courier',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isMobile ? 7 : 8,
                      color: baseColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  List<double> _generateMockData(int clickCount) {
    // Generate a simple trend based on click count
    final baseValue = clickCount / 10;
    return List.generate(
      8,
      (i) => baseValue + (i * baseValue * 0.3) + (i % 3 * baseValue * 0.5),
    );
  }
}
