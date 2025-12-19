import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_maps/maps.dart' as maps;

import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';
import '../../../models/models.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
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
    final globalStats = urlsState.globalStats;

    return CyberScaffold(
      enableBack: false,
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Show loading state
              if (urlsState.isLoading && urlsState.urls.isEmpty)
                _buildLoadingSkeleton(color)
              else ...[
                // SYSTEM OVERVIEW CARDS
                _section("SYSTEM_CORE", "GLOBAL NETWORK STATISTICS"),
                const SizedBox(height: 16),
                _buildSystemOverview(globalStats, color),

                const SizedBox(height: 32),
                _section(
                  "GEOGRAPHICAL_INTELLIGENCE",
                  "WORLDWIDE TRAFFIC DENSITY",
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildGlobalMap(urlsState, color)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildGeoBreakdown(globalStats, color)),
                  ],
                ),

                const SizedBox(height: 32),
                _section("PLATFORM_ANALYTICS", "OPERATING SYSTEM DISTRIBUTION"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildOsChart(globalStats)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildOsMetrics(globalStats, color)),
                  ],
                ),

                const SizedBox(height: 32),
                _section("TEMPORAL_PULSE", "HOURLY TRAFFIC FREQUENCY"),
                const SizedBox(height: 16),
                _buildHourlyChart(urlsState),

                const SizedBox(height: 32),
                _section("NETWORK_DNA", "MULTI-DIMENSIONAL PERFORMANCE"),
                const SizedBox(height: 16),
                _buildRadarChart(),

                const SizedBox(height: 32),
                _section("SYSTEM_VOLATILITY", "PEAK VS AVERAGE LOAD"),
                const SizedBox(height: 16),
                _buildLinearGauge(0.65, color),

                const SizedBox(height: 32),
                _section("ENGAGEMENT_MATRIX", "CLICK-THROUGH EFFICIENCY"),
                const SizedBox(height: 16),
                _buildEngagementMetrics(urlsState, color),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(Color color) {
    return Column(
      children: [
        _section("LOADING", "FETCHING NETWORK STATISTICS"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(120, color)),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonCard(120, color)),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonCard(120, color)),
          ],
        ),
        const SizedBox(height: 32),
        _section("GEOGRAPHICAL_INTELLIGENCE", "LOADING MAP DATA"),
        const SizedBox(height: 16),
        _buildSkeletonCard(320, color),
        const SizedBox(height: 32),
        _section("PLATFORM_ANALYTICS", "PREPARING CHARTS"),
        const SizedBox(height: 16),
        _buildSkeletonCard(280, color),
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: Colors.cyanAccent),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING ANALYTICS ENGINE...',
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.5),
                  fontFamily: 'Courier',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard(double height, Color color) {
    return GlassCard(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.circleNotch,
              color: color.withValues(alpha: 0.3),
              size: 32,
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview(GlobalStatsModel stats, Color color) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "TOTAL_LINKS",
            "${stats.totalSystemLinks}",
            PhosphorIconsRegular.link,
            Colors.cyanAccent,
            "DEPLOYED",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "TOTAL_CLICKS",
            "${stats.totalSystemClicks}",
            PhosphorIconsRegular.lightning,
            Colors.amber,
            "REQUESTS",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            "AVG_CTR",
            stats.totalSystemLinks > 0
                ? (stats.totalSystemClicks / stats.totalSystemLinks)
                      .toStringAsFixed(1)
                : '0',
            PhosphorIconsRegular.chartBar,
            Colors.greenAccent,
            "PER LINK",
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color accentColor,
    String suffix,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white60,
                ),
              ),
              Icon(icon, color: accentColor, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suffix,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white30,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeoBreakdown(GlobalStatsModel stats, Color color) {
    final sortedGeo = stats.geoDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      height: 320,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TOP REGIONS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: sortedGeo.length,
              itemBuilder: (context, index) {
                final entry = sortedGeo[index];
                final percentage =
                    (entry.value / stats.totalSystemClicks * 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getCountryName(entry.key),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${entry.value} (${percentage.toStringAsFixed(1)}%)",
                            style: TextStyle(
                              fontSize: 11,
                              color: color.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.cyanAccent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsChart(GlobalStatsModel stats) {
    final osData = stats.osDistribution.entries
        .map((e) => _ChartData(e.key, e.value.toDouble()))
        .toList();

    return GlassCard(
      height: 280,
      child: charts.SfCircularChart(
        title: const charts.ChartTitle(
          text: 'OS DISTRIBUTION',
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        legend: const charts.Legend(
          isVisible: true,
          position: charts.LegendPosition.bottom,
          textStyle: TextStyle(fontSize: 9, color: Colors.white60),
        ),
        series: <charts.CircularSeries>[
          charts.DoughnutSeries<_ChartData, String>(
            dataSource: osData,
            xValueMapper: (_ChartData data, _) => data.category,
            yValueMapper: (_ChartData data, _) => data.value,
            pointColorMapper: (_ChartData data, _) =>
                _getOsColor(data.category),
            dataLabelMapper: (_ChartData data, _) => '${data.value.toInt()}',
            dataLabelSettings: const charts.DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            innerRadius: '60%',
          ),
        ],
      ),
    );
  }

  Widget _buildOsMetrics(GlobalStatsModel stats, Color color) {
    final sortedOs = stats.osDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      height: 280,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PLATFORM METRICS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: sortedOs.length,
              itemBuilder: (context, index) {
                final entry = sortedOs[index];
                final iconData = _getOsIcon(entry.key);
                final osColor = _getOsColor(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: osColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(iconData, color: osColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${entry.value} requests",
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${(entry.value / stats.totalSystemClicks * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: osColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics(UrlsState state, Color color) {
    final avgClicks = state.urls.isEmpty
        ? 0
        : state.myTotalClicks / state.urls.length;
    final mostClicked = state.urls.isEmpty
        ? null
        : state.urls.reduce((a, b) => a.clickCount > b.clickCount ? a : b);
    final leastClicked = state.urls.isEmpty
        ? null
        : state.urls.reduce((a, b) => a.clickCount < b.clickCount ? a : b);

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AVG CLICKS/LINK",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  avgClicks.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TOP PERFORMER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (mostClicked != null) ...[
                  Text(
                    "${mostClicked.clickCount}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mostClicked.shortCode,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else
                  const Text("N/A", style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NEEDS BOOST",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (leastClicked != null) ...[
                  Text(
                    "${leastClicked.clickCount}",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leastClicked.shortCode,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else
                  const Text("N/A", style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalMap(UrlsState state, Color color) {
    // Check if we have geo data
    if (state.globalStats.geoDistribution.isEmpty) {
      return GlassCard(
        height: 320,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIconsRegular.globe,
                size: 48,
                color: color.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'NO GEOGRAPHICAL DATA',
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Create a map of country names to click counts
    final countryDataMap = <String, int>{};
    for (final entry in state.globalStats.geoDistribution.entries) {
      final countryName = _getCountryName(entry.key);
      countryDataMap[countryName] = entry.value;
    }

    return GlassCard(
      height: 320,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: maps.SfMaps(
          layers: [
            maps.MapShapeLayer(
              source: maps.MapShapeSource.asset(
                'assets/world_map.json',
                shapeDataField: 'name',
              ),
              color: color.withValues(alpha: 0.05),
              strokeColor: color.withValues(alpha: 0.15),
              strokeWidth: 0.5,
              shapeTooltipBuilder: (BuildContext context, int index) {
                return const SizedBox.shrink();
              },
              sublayers: [
                maps.MapShapeSublayer(
                  source: maps.MapShapeSource.asset(
                    'assets/world_map.json',
                    shapeDataField: 'name',
                    dataCount: countryDataMap.length,
                    primaryValueMapper: (int index) {
                      final keys = countryDataMap.keys.toList();
                      return index < keys.length ? keys[index] : '';
                    },
                    shapeColorValueMapper: (int index) {
                      final keys = countryDataMap.keys.toList();
                      if (index < keys.length) {
                        final clicks = countryDataMap[keys[index]] ?? 0;
                        // Return a color directly based on clicks
                        if (clicks > 500) {
                          return Colors.cyanAccent;
                        } else if (clicks > 100) {
                          return Colors.cyanAccent.withValues(alpha: 0.6);
                        } else if (clicks > 0) {
                          return Colors.cyanAccent.withValues(alpha: 0.3);
                        }
                      }
                      return null;
                    },
                  ),
                  shapeTooltipBuilder: (BuildContext context, int index) {
                    final keys = countryDataMap.keys.toList();
                    if (index >= 0 && index < keys.length) {
                      final countryName = keys[index];
                      final clicks = countryDataMap[countryName] ?? 0;
                      if (clicks > 0) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$countryName: $clicks clicks',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyChart(UrlsState state) {
    return GlassCard(
      height: 250,
      child: charts.SfCartesianChart(
        primaryXAxis: charts.NumericAxis(
          title: const charts.AxisTitle(
            text: 'HOUR_OF_DAY',
            textStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
          ),
          majorGridLines: const charts.MajorGridLines(width: 0),
        ),
        primaryYAxis: const charts.NumericAxis(isVisible: false),
        series: <charts.CartesianSeries<MapEntry<int, int>, int>>[
          charts.ColumnSeries<MapEntry<int, int>, int>(
            dataSource: state.hourlyActivity,
            xValueMapper: (MapEntry<int, int> d, _) => d.key,
            yValueMapper: (MapEntry<int, int> d, _) => d.value,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent,
                Colors.blueAccent.withValues(alpha: 0.2),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart() {
    final data = [
      _ChartData('SPEED', 0.9),
      _ChartData('VOL', 0.7),
      _ChartData('SEC', 0.8),
      _ChartData('GEO', 0.6),
      _ChartData('UPTIME', 0.95),
    ];

    return GlassCard(
      height: 300,
      child: charts.SfCartesianChart(
        primaryXAxis: const charts.CategoryAxis(
          labelStyle: TextStyle(fontSize: 8, color: Colors.white24),
          majorGridLines: charts.MajorGridLines(width: 0),
        ),
        primaryYAxis: const charts.NumericAxis(
          minimum: 0,
          maximum: 1,
          isVisible: false,
        ),
        series: <charts.CartesianSeries<_ChartData, String>>[
          charts.BarSeries<_ChartData, String>(
            dataSource: data,
            xValueMapper: (_ChartData d, _) => d.category,
            yValueMapper: (_ChartData d, _) => d.value,
            gradient: LinearGradient(
              colors: [
                Colors.cyanAccent,
                Colors.cyanAccent.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildLinearGauge(double val, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: gauges.SfLinearGauge(
        minimum: 0,
        maximum: 100,
        axisLabelStyle: TextStyle(
          color: color.withValues(alpha: 0.3),
          fontSize: 10,
        ),
        barPointers: [
          gauges.LinearBarPointer(
            value: val * 100,
            thickness: 12,
            color: Colors.cyanAccent,
            edgeStyle: gauges.LinearEdgeStyle.bothCurve,
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String sub) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white24,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(String code) {
    // Comprehensive ISO 3166-1 alpha-2 to Natural Earth country name mapping
    const map = {
      'AF': 'Afghanistan',
      'AL': 'Albania',
      'DZ': 'Algeria',
      'AO': 'Angola',
      'AR': 'Argentina',
      'AM': 'Armenia',
      'AU': 'Australia',
      'AT': 'Austria',
      'AZ': 'Azerbaijan',
      'BS': 'Bahamas',
      'BH': 'Bahrain',
      'BD': 'Bangladesh',
      'BY': 'Belarus',
      'BE': 'Belgium',
      'BZ': 'Belize',
      'BJ': 'Benin',
      'BT': 'Bhutan',
      'BO': 'Bolivia',
      'BA': 'Bosnia and Herz.',
      'BW': 'Botswana',
      'BR': 'Brazil',
      'BN': 'Brunei',
      'BG': 'Bulgaria',
      'BF': 'Burkina Faso',
      'BI': 'Burundi',
      'KH': 'Cambodia',
      'CM': 'Cameroon',
      'CA': 'Canada',
      'CF': 'Central African Rep.',
      'TD': 'Chad',
      'CL': 'Chile',
      'CN': 'China',
      'CO': 'Colombia',
      'CG': 'Congo',
      'CD': 'Dem. Rep. Congo',
      'CR': 'Costa Rica',
      'CI': 'Côte d\'Ivoire',
      'HR': 'Croatia',
      'CU': 'Cuba',
      'CY': 'Cyprus',
      'CZ': 'Czech Rep.',
      'DK': 'Denmark',
      'DJ': 'Djibouti',
      'DO': 'Dominican Rep.',
      'EC': 'Ecuador',
      'EG': 'Egypt',
      'SV': 'El Salvador',
      'GQ': 'Eq. Guinea',
      'ER': 'Eritrea',
      'EE': 'Estonia',
      'ET': 'Ethiopia',
      'FJ': 'Fiji',
      'FI': 'Finland',
      'FR': 'France',
      'GA': 'Gabon',
      'GM': 'Gambia',
      'GE': 'Georgia',
      'DE': 'Germany',
      'GH': 'Ghana',
      'GR': 'Greece',
      'GT': 'Guatemala',
      'GN': 'Guinea',
      'GW': 'Guinea-Bissau',
      'GY': 'Guyana',
      'HT': 'Haiti',
      'HN': 'Honduras',
      'HU': 'Hungary',
      'IS': 'Iceland',
      'IN': 'India',
      'ID': 'Indonesia',
      'IR': 'Iran',
      'IQ': 'Iraq',
      'IE': 'Ireland',
      'IL': 'Israel',
      'IT': 'Italy',
      'JM': 'Jamaica',
      'JP': 'Japan',
      'JO': 'Jordan',
      'KZ': 'Kazakhstan',
      'KE': 'Kenya',
      'KR': 'Korea',
      'KP': 'Dem. Rep. Korea',
      'KW': 'Kuwait',
      'KG': 'Kyrgyzstan',
      'LA': 'Laos',
      'LV': 'Latvia',
      'LB': 'Lebanon',
      'LS': 'Lesotho',
      'LR': 'Liberia',
      'LY': 'Libya',
      'LT': 'Lithuania',
      'LU': 'Luxembourg',
      'MK': 'Macedonia',
      'MG': 'Madagascar',
      'MW': 'Malawi',
      'MY': 'Malaysia',
      'ML': 'Mali',
      'MR': 'Mauritania',
      'MX': 'Mexico',
      'MD': 'Moldova',
      'MN': 'Mongolia',
      'ME': 'Montenegro',
      'MA': 'Morocco',
      'MZ': 'Mozambique',
      'MM': 'Myanmar',
      'NA': 'Namibia',
      'NP': 'Nepal',
      'NL': 'Netherlands',
      'NZ': 'New Zealand',
      'NI': 'Nicaragua',
      'NE': 'Niger',
      'NG': 'Nigeria',
      'NO': 'Norway',
      'OM': 'Oman',
      'PK': 'Pakistan',
      'PA': 'Panama',
      'PG': 'Papua New Guinea',
      'PY': 'Paraguay',
      'PE': 'Peru',
      'PH': 'Philippines',
      'PL': 'Poland',
      'PT': 'Portugal',
      'PR': 'Puerto Rico',
      'QA': 'Qatar',
      'RO': 'Romania',
      'RU': 'Russia',
      'RW': 'Rwanda',
      'SA': 'Saudi Arabia',
      'SN': 'Senegal',
      'RS': 'Serbia',
      'SL': 'Sierra Leone',
      'SG': 'Singapore',
      'SK': 'Slovakia',
      'SI': 'Slovenia',
      'SB': 'Solomon Is.',
      'SO': 'Somalia',
      'ZA': 'South Africa',
      'SS': 'S. Sudan',
      'ES': 'Spain',
      'LK': 'Sri Lanka',
      'SD': 'Sudan',
      'SR': 'Suriname',
      'SZ': 'Swaziland',
      'SE': 'Sweden',
      'CH': 'Switzerland',
      'SY': 'Syria',
      'TW': 'Taiwan',
      'TJ': 'Tajikistan',
      'TZ': 'Tanzania',
      'TH': 'Thailand',
      'TL': 'Timor-Leste',
      'TG': 'Togo',
      'TT': 'Trinidad and Tobago',
      'TN': 'Tunisia',
      'TR': 'Turkey',
      'TM': 'Turkmenistan',
      'UG': 'Uganda',
      'UA': 'Ukraine',
      'AE': 'United Arab Emirates',
      'GB': 'United Kingdom',
      'UK': 'United Kingdom',
      'US': 'United States',
      'UY': 'Uruguay',
      'UZ': 'Uzbekistan',
      'VE': 'Venezuela',
      'VN': 'Vietnam',
      'YE': 'Yemen',
      'ZM': 'Zambia',
      'ZW': 'Zimbabwe',
      'XX': 'Unknown',
    };
    return map[code] ?? code;
  }

  IconData _getOsIcon(String os) {
    switch (os.toLowerCase()) {
      case 'android':
        return PhosphorIconsRegular.androidLogo;
      case 'ios':
        return PhosphorIconsRegular.appleLogo;
      case 'windows':
        return PhosphorIconsRegular.windowsLogo;
      case 'macos':
        return PhosphorIconsRegular.appleLogo;
      case 'linux':
        return PhosphorIconsRegular.linuxLogo;
      default:
        return PhosphorIconsRegular.deviceMobile;
    }
  }

  Color _getOsColor(String os) {
    switch (os.toLowerCase()) {
      case 'android':
        return Colors.greenAccent;
      case 'ios':
        return Colors.white;
      case 'windows':
        return Colors.blueAccent;
      case 'macos':
        return Colors.grey;
      case 'linux':
        return Colors.orangeAccent;
      default:
        return Colors.white60;
    }
  }
}

class _ChartData {
  _ChartData(this.category, this.value);
  final String category;
  final double value;
}
