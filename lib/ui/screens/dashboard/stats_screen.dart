import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../widgets/cyber_feedback.dart';
import '../../../providers/providers.dart';
import '../../../models/models.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  List<Polygon>? _cachedPolygons;
  bool _mapBuiltWithData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(urlsProvider.notifier).loadDashboard();
      // Wait a bit for state to update, then prepare map with real data
      await Future.delayed(const Duration(milliseconds: 500));

      final urlsState = ref.read(urlsProvider);
      debugPrint(
        "🗺️ About to build map. GeoDistribution: ${urlsState.globalStats.geoDistribution}",
      );

      if (urlsState.globalStats.geoDistribution.isNotEmpty) {
        _prepareMapPolygons();
      } else {
        debugPrint("⚠️ No geo data available yet, waiting...");
        await Future.delayed(const Duration(milliseconds: 500));
        _prepareMapPolygons();
      }
    });
  }

  Future<void> _prepareMapPolygons() async {
    try {
      debugPrint("🗺️ Starting _prepareMapPolygons...");

      final String jsonString = await rootBundle.loadString(
        'assets/world_map.json',
      );
      final data = json.decode(jsonString);
      final List features = data['features'];
      final urlsState = ref.read(urlsProvider);

      List<Polygon> polygons = [];

      debugPrint(
        "🗺️ GeoDistribution data: ${urlsState.globalStats.geoDistribution}",
      );
      debugPrint(
        "🗺️ Total features to process: ${features.length}",
      );
      debugPrint(
        "🗺️ GeoDistribution keys: ${urlsState.globalStats.geoDistribution.keys.toList()}",
      );

      for (var feature in features) {
        final props = feature['properties'];
        // Get country name from GeoJSON (your file uses 'name' or 'admin')
        final String countryName = props['name'] ?? props['admin'] ?? '';

        // Convert country name to ISO code
        final String? isoCode = _getIsoCodeFromName(countryName);

        // Look up clicks using ISO code
        final int clicks = isoCode != null
            ? (urlsState.globalStats.geoDistribution[isoCode] ?? 0)
            : 0;

        // Debug: Log ALL countries being processed
        debugPrint(
          "🗺️ Processing '$countryName' (ISO: $isoCode) - Clicks: $clicks - Has Data: ${urlsState.globalStats.geoDistribution.containsKey(isoCode)}",
        );

        if (clicks > 0) {
          debugPrint(
            "✅ Country '$countryName' (ISO: $isoCode) has $clicks clicks - Color: ${_getMapColor(clicks)}",
          );
        }

        final Color countryColor = _getMapColor(clicks);
        final Color borderColor = _getBorderColor(clicks);

        final geom = feature['geometry'];
        if (geom['type'] == 'MultiPolygon') {
          for (var poly in geom['coordinates']) {
            for (var ring in poly) {
              polygons.add(_createPolygon(ring, countryColor, borderColor));
            }
          }
        } else if (geom['type'] == 'Polygon') {
          for (var ring in geom['coordinates']) {
            polygons.add(_createPolygon(ring, countryColor, borderColor));
          }
        }
      }

      debugPrint("🗺️ Created ${polygons.length} polygons. Setting state...");

      if (mounted) {
        setState(() {
          _cachedPolygons = polygons;
          _mapBuiltWithData = true;
        });
        debugPrint("🗺️ Map state updated!");
        CyberFeedback.geospatialReady(context);
      }
    } catch (e) {
      debugPrint("❌ Map Load Error: $e");
    }
  }

  Polygon _createPolygon(List coordinates, Color color, Color borderColor) {
    return Polygon(
      points: coordinates.map((pt) {
        double lng = pt[0].toDouble().clamp(-180.0, 180.0);
        double lat = pt[1].toDouble().clamp(-90.0, 90.0);
        return LatLng(lat, lng);
      }).toList(),
      color: color,
      borderStrokeWidth: 0.8,
      borderColor: borderColor,
    );
  }

  Color _getBorderColor(int count) {
    if (count == 0) {
      // Base country border - very subtle
      return Colors.cyanAccent.withValues(alpha: 0.1);
    }
    if (count > 5000) {
      // Ultra high traffic - bright glowing cyan border
      return Colors.cyanAccent.withValues(alpha: 1.0);
    }
    if (count > 1000) {
      // High traffic - bright cyan border
      return Colors.cyanAccent.withValues(alpha: 0.85);
    }
    if (count > 100) {
      // Medium traffic - visible cyan border
      return Colors.cyanAccent.withValues(alpha: 0.7);
    }
    // Low traffic - faint cyan border
    return Colors.cyanAccent.withValues(alpha: 0.5);
  }

  Color _getMapColor(int count) {
    if (count == 0) {
      // Base country color - very dark, almost invisible
      return const Color(0xFF0A1929).withValues(alpha: 0.3);
    }
    if (count > 5000) {
      // Ultra high traffic - blazing cyan with glow
      return Colors.cyanAccent.withValues(alpha: 0.8);
    }
    if (count > 1000) {
      // High traffic - very bright cyan
      return Colors.cyanAccent.withValues(alpha: 0.6);
    }
    if (count > 100) {
      // Medium traffic - bright cyan
      return Colors.cyanAccent.withValues(alpha: 0.4);
    }
    // Low traffic (1-100) - clearly visible cyan
    return Colors.cyanAccent.withValues(alpha: 0.25);
  }

  Widget _buildGlobalMap(UrlsState state, Color color, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_cachedPolygons == null) {
      return GlassCard(
        height: isMobile ? 250 : 320,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.cyanAccent),
              const SizedBox(height: 16),
              Text(
                'LOADING WORLD MAP...',
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
      );
    }

    return GlassCard(
      height: isMobile ? 250 : 320,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Adaptive background - deep space for dark, light blue for light
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: isDark
                      ? [
                          const Color(0xFF001F3F), // Deep navy center
                          const Color(0xFF000814), // Almost black
                          Colors.black,
                        ]
                      : [
                          const Color(0xFFB3E5FC), // Light blue center
                          const Color(0xFF81D4FA), // Sky blue
                          const Color(0xFF4FC3F7), // Medium blue
                        ],
                ),
              ),
            ),
            // The actual map
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(20, 0),
                initialZoom: 1.2,
                minZoom: 1.0,
                maxZoom: 3.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [PolygonLayer(polygons: _cachedPolygons!)],
            ),
            // Cyber grid overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.cyanAccent.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Top-left legend
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(
                    alpha: 0.85,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAFFIC DENSITY',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildLegendItem(
                      '5000+',
                      Colors.cyanAccent.withValues(alpha: 0.8),
                      isDark,
                    ),
                    _buildLegendItem(
                      '1000+',
                      Colors.cyanAccent.withValues(alpha: 0.5),
                      isDark,
                    ),
                    _buildLegendItem(
                      '100+',
                      Colors.cyanAccent.withValues(alpha: 0.3),
                      isDark,
                    ),
                    _buildLegendItem(
                      '1+',
                      Colors.cyanAccent.withValues(alpha: 0.15),
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom-right stats
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withValues(
                    alpha: 0.85,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.globe,
                      size: 14,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.globalStats.geoDistribution.length} REGIONS',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface;
    final globalStats = urlsState.globalStats;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return CyberScaffold(
      enableBack: false,
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            children: [
              // Show loading state
              if (urlsState.isLoading && urlsState.urls.isEmpty)
                _buildLoadingSkeleton(color)
              else ...[
                // SYSTEM OVERVIEW CARDS
                _section("SYSTEM_CORE", "GLOBAL NETWORK STATISTICS", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _buildSystemOverview(globalStats, color, isMobile),

                SizedBox(height: isMobile ? 24 : 32),
                _section(
                  "GEOGRAPHICAL_INTELLIGENCE",
                  "WORLDWIDE TRAFFIC DENSITY",
                  isMobile,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                if (isMobile)
                  Column(
                    children: [
                      _buildGlobalMap(urlsState, color, isMobile),
                      const SizedBox(height: 16),
                      _buildGeoBreakdown(globalStats, color, isMobile),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildGlobalMap(urlsState, color, isMobile)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildGeoBreakdown(globalStats, color, isMobile)),
                    ],
                  ),

                SizedBox(height: isMobile ? 24 : 32),
                _section("PLATFORM_ANALYTICS", "OPERATING SYSTEM DISTRIBUTION", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                if (isMobile)
                  Column(
                    children: [
                      _buildOsChart(globalStats, isMobile),
                      const SizedBox(height: 16),
                      _buildOsMetrics(globalStats, color, isMobile),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildOsChart(globalStats, isMobile)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildOsMetrics(globalStats, color, isMobile)),
                    ],
                  ),

                SizedBox(height: isMobile ? 24 : 32),
                _section("TEMPORAL_PULSE", "HOURLY TRAFFIC FREQUENCY", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _buildHourlyChart(urlsState, isMobile),

                SizedBox(height: isMobile ? 24 : 32),
                _section("NETWORK_DNA", "MULTI-DIMENSIONAL PERFORMANCE", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _buildRadarChart(isMobile),

                SizedBox(height: isMobile ? 24 : 32),
                _section("SYSTEM_VOLATILITY", "PEAK VS AVERAGE LOAD", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _buildLinearGauge(0.65, color, isMobile),

                SizedBox(height: isMobile ? 24 : 32),
                _section("ENGAGEMENT_MATRIX", "CLICK-THROUGH EFFICIENCY", isMobile),
                SizedBox(height: isMobile ? 12 : 16),
                _buildEngagementMetrics(urlsState, color, isMobile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(Color color) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        _section("LOADING", "FETCHING NETWORK STATISTICS", isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        if (isMobile)
          Column(
            children: [
              _buildSkeletonCard(isMobile ? 100 : 120, color),
              const SizedBox(height: 12),
              _buildSkeletonCard(isMobile ? 100 : 120, color),
              const SizedBox(height: 12),
              _buildSkeletonCard(isMobile ? 100 : 120, color),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: _buildSkeletonCard(120, color)),
              const SizedBox(width: 16),
              Expanded(child: _buildSkeletonCard(120, color)),
              const SizedBox(width: 16),
              Expanded(child: _buildSkeletonCard(120, color)),
            ],
          ),
        SizedBox(height: isMobile ? 24 : 32),
        _section("GEOGRAPHICAL_INTELLIGENCE", "LOADING MAP DATA", isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        _buildSkeletonCard(isMobile ? 250 : 320, color),
        SizedBox(height: isMobile ? 24 : 32),
        _section("PLATFORM_ANALYTICS", "PREPARING CHARTS", isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        _buildSkeletonCard(isMobile ? 220 : 280, color),
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

  Widget _buildSystemOverview(GlobalStatsModel stats, Color color, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildMetricCard(
            "TOTAL_LINKS",
            "${stats.totalSystemLinks}",
            PhosphorIconsRegular.link,
            Colors.cyanAccent,
            "DEPLOYED",
            isMobile,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            "TOTAL_CLICKS",
            "${stats.totalSystemClicks}",
            PhosphorIconsRegular.lightning,
            Colors.amber,
            "REQUESTS",
            isMobile,
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            "AVG_CTR",
            stats.totalSystemLinks > 0
                ? (stats.totalSystemClicks / stats.totalSystemLinks)
                      .toStringAsFixed(1)
                : '0',
            PhosphorIconsRegular.chartBar,
            Colors.greenAccent,
            "PER LINK",
            isMobile,
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "TOTAL_LINKS",
            "${stats.totalSystemLinks}",
            PhosphorIconsRegular.link,
            Colors.cyanAccent,
            "DEPLOYED",
            isMobile,
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
            isMobile,
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
            isMobile,
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
    bool isMobile,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: isMobile ? 1 : 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: accentColor, size: isMobile ? 20 : 24),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suffix,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.white30 : Colors.black38,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeoBreakdown(GlobalStatsModel stats, Color color, bool isMobile) {
    final sortedGeo = stats.geoDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      height: isMobile ? 250 : 320,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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

  Widget _buildOsChart(GlobalStatsModel stats, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final osData = stats.osDistribution.entries
        .map((e) => _ChartData(e.key, e.value.toDouble()))
        .toList();

    return GlassCard(
      height: isMobile ? 220 : 280,
      child: charts.SfCircularChart(
        title: const charts.ChartTitle(
          text: 'OS DISTRIBUTION',
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        legend: charts.Legend(
          isVisible: true,
          position: charts.LegendPosition.bottom,
          textStyle: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
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

  Widget _buildOsMetrics(GlobalStatsModel stats, Color color, bool isMobile) {
    final sortedOs = stats.osDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      height: isMobile ? 220 : 280,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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

  Widget _buildEngagementMetrics(UrlsState state, Color color, bool isMobile) {
    final avgClicks = state.urls.isEmpty
        ? 0
        : state.myTotalClicks / state.urls.length;
    final mostClicked = state.urls.isEmpty
        ? null
        : state.urls.reduce((a, b) => a.clickCount > b.clickCount ? a : b);
    final leastClicked = state.urls.isEmpty
        ? null
        : state.urls.reduce((a, b) => a.clickCount < b.clickCount ? a : b);

    if (isMobile) {
      return Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
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
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
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
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
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
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
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
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
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
        ],
      );
    }

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

  Widget _buildHourlyChart(UrlsState state, bool isMobile) {
    return GlassCard(
      height: isMobile ? 200 : 250,
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

  Widget _buildRadarChart(bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = [
      _ChartData('SPEED', 0.9),
      _ChartData('VOL', 0.7),
      _ChartData('SEC', 0.8),
      _ChartData('GEO', 0.6),
      _ChartData('UPTIME', 0.95),
    ];

    return GlassCard(
      height: isMobile ? 220 : 300,
      child: charts.SfCartesianChart(
        primaryXAxis: charts.CategoryAxis(
          labelStyle: TextStyle(
            fontSize: 8,
            color: isDark ? Colors.white24 : Colors.black38,
          ),
          majorGridLines: const charts.MajorGridLines(width: 0),
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

  Widget _buildLinearGauge(double val, Color color, bool isMobile) {
    return GlassCard(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 32,
      ),
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

  Widget _section(String title, String sub, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
              letterSpacing: isMobile ? 1 : 2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: isMobile ? 8 : 9,
              color: isDark ? Colors.white24 : Colors.black38,
              fontFamily: 'Courier',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String? _getIsoCodeFromName(String countryName) {
    // Reverse lookup: GeoJSON country name → ISO code
    const reverseMap = {
      'Afghanistan': 'AF',
      'Albania': 'AL',
      'Algeria': 'DZ',
      'Angola': 'AO',
      'Argentina': 'AR',
      'Armenia': 'AM',
      'Australia': 'AU',
      'Austria': 'AT',
      'Azerbaijan': 'AZ',
      'Bahamas': 'BS',
      'Bahrain': 'BH',
      'Bangladesh': 'BD',
      'Belarus': 'BY',
      'Belgium': 'BE',
      'Belize': 'BZ',
      'Benin': 'BJ',
      'Bhutan': 'BT',
      'Bolivia': 'BO',
      'Bosnia and Herzegovina': 'BA',
      'Bosnia and Herz.': 'BA',
      'Botswana': 'BW',
      'Brazil': 'BR',
      'Brunei': 'BN',
      'Bulgaria': 'BG',
      'Burkina Faso': 'BF',
      'Burundi': 'BI',
      'Cambodia': 'KH',
      'Cameroon': 'CM',
      'Canada': 'CA',
      'Central African Republic': 'CF',
      'Central African Rep.': 'CF',
      'Chad': 'TD',
      'Chile': 'CL',
      'China': 'CN',
      'Colombia': 'CO',
      'Congo': 'CG',
      'Democratic Republic of the Congo': 'CD',
      'Dem. Rep. Congo': 'CD',
      'Costa Rica': 'CR',
      'Côte d\'Ivoire': 'CI',
      'Ivory Coast': 'CI',
      'Croatia': 'HR',
      'Cuba': 'CU',
      'Cyprus': 'CY',
      'Czech Republic': 'CZ',
      'Czech Rep.': 'CZ',
      'Denmark': 'DK',
      'Djibouti': 'DJ',
      'Dominican Republic': 'DO',
      'Dominican Rep.': 'DO',
      'Ecuador': 'EC',
      'Egypt': 'EG',
      'El Salvador': 'SV',
      'Equatorial Guinea': 'GQ',
      'Eq. Guinea': 'GQ',
      'Eritrea': 'ER',
      'Estonia': 'EE',
      'Ethiopia': 'ET',
      'Fiji': 'FJ',
      'Finland': 'FI',
      'France': 'FR',
      'Gabon': 'GA',
      'Gambia': 'GM',
      'Georgia': 'GE',
      'Germany': 'DE',
      'Ghana': 'GH',
      'Greece': 'GR',
      'Guatemala': 'GT',
      'Guinea': 'GN',
      'Guinea-Bissau': 'GW',
      'Guyana': 'GY',
      'Haiti': 'HT',
      'Honduras': 'HN',
      'Hungary': 'HU',
      'Iceland': 'IS',
      'India': 'IN',
      'Indonesia': 'ID',
      'Iran': 'IR',
      'Iraq': 'IQ',
      'Ireland': 'IE',
      'Israel': 'IL',
      'Italy': 'IT',
      'Jamaica': 'JM',
      'Japan': 'JP',
      'Jordan': 'JO',
      'Kazakhstan': 'KZ',
      'Kenya': 'KE',
      'South Korea': 'KR',
      'Korea': 'KR',
      'North Korea': 'KP',
      'Dem. Rep. Korea': 'KP',
      'Kuwait': 'KW',
      'Kyrgyzstan': 'KG',
      'Laos': 'LA',
      'Latvia': 'LV',
      'Lebanon': 'LB',
      'Lesotho': 'LS',
      'Liberia': 'LR',
      'Libya': 'LY',
      'Lithuania': 'LT',
      'Luxembourg': 'LU',
      'Macedonia': 'MK',
      'Madagascar': 'MG',
      'Malawi': 'MW',
      'Malaysia': 'MY',
      'Mali': 'ML',
      'Mauritania': 'MR',
      'Mexico': 'MX',
      'Moldova': 'MD',
      'Mongolia': 'MN',
      'Montenegro': 'ME',
      'Morocco': 'MA',
      'Mozambique': 'MZ',
      'Myanmar': 'MM',
      'Namibia': 'NA',
      'Nepal': 'NP',
      'Netherlands': 'NL',
      'New Zealand': 'NZ',
      'Nicaragua': 'NI',
      'Niger': 'NE',
      'Nigeria': 'NG',
      'Norway': 'NO',
      'Oman': 'OM',
      'Pakistan': 'PK',
      'Panama': 'PA',
      'Papua New Guinea': 'PG',
      'Paraguay': 'PY',
      'Peru': 'PE',
      'Philippines': 'PH',
      'Poland': 'PL',
      'Portugal': 'PT',
      'Puerto Rico': 'PR',
      'Qatar': 'QA',
      'Romania': 'RO',
      'Russia': 'RU',
      'Russian Federation': 'RU',
      'Rwanda': 'RW',
      'Saudi Arabia': 'SA',
      'Senegal': 'SN',
      'Serbia': 'RS',
      'Sierra Leone': 'SL',
      'Singapore': 'SG',
      'Slovakia': 'SK',
      'Slovenia': 'SI',
      'Solomon Islands': 'SB',
      'Solomon Is.': 'SB',
      'Somalia': 'SO',
      'South Africa': 'ZA',
      'South Sudan': 'SS',
      'S. Sudan': 'SS',
      'Spain': 'ES',
      'Sri Lanka': 'LK',
      'Sudan': 'SD',
      'Suriname': 'SR',
      'Swaziland': 'SZ',
      'Eswatini': 'SZ',
      'Sweden': 'SE',
      'Switzerland': 'CH',
      'Syria': 'SY',
      'Taiwan': 'TW',
      'Tajikistan': 'TJ',
      'Tanzania': 'TZ',
      'Thailand': 'TH',
      'Timor-Leste': 'TL',
      'East Timor': 'TL',
      'Togo': 'TG',
      'Trinidad and Tobago': 'TT',
      'Tunisia': 'TN',
      'Turkey': 'TR',
      'Turkmenistan': 'TM',
      'Uganda': 'UG',
      'Ukraine': 'UA',
      'United Arab Emirates': 'AE',
      'United Kingdom': 'GB',
      'United States': 'US',
      'United States of America': 'US',
      'Uruguay': 'UY',
      'Uzbekistan': 'UZ',
      'Venezuela': 'VE',
      'Vietnam': 'VN',
      'Viet Nam': 'VN',
      'Yemen': 'YE',
      'Zambia': 'ZM',
      'Zimbabwe': 'ZW',
    };
    return reverseMap[countryName];
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (os.toLowerCase()) {
      case 'android':
        return Colors.greenAccent;
      case 'ios':
        return isDark ? Colors.white : Colors.black87;
      case 'windows':
        return Colors.blueAccent;
      case 'macos':
        return Colors.grey;
      case 'linux':
        return Colors.orangeAccent;
      default:
        return isDark ? Colors.white60 : Colors.black54;
    }
  }
}

class _ChartData {
  _ChartData(this.category, this.value);
  final String category;
  final double value;
}
