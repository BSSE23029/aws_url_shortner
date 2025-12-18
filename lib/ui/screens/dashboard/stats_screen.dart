import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';
import '../../../providers/providers.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlsState = ref.watch(urlsProvider);
    final globalStats = urlsState.globalStats;
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    // Prepare Data for Charts
    final osData = globalStats.osDistribution.entries
        .map((e) => _ChartData(e.key, e.value.toDouble()))
        .toList();

    final geoData = globalStats.geoDistribution.entries
        .map((e) => _ChartData(e.key, e.value.toDouble()))
        .toList();

    // Sort Geo to show top countries first
    geoData.sort((a, b) => b.y.compareTo(a.y));

    return CyberScaffold(
      enableBack: false,
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              "Global Intelligence",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            Text(
              "System-wide telemetry",
              style: TextStyle(
                fontSize: 14,
                color: txtColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),

            // 1. GLOBAL OS DISTRIBUTION (Pie Chart)
            GlassCard(
              height: 350,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader("GLOBAL OS MARKET SHARE", txtColor),
                  Expanded(
                    child: osData.isEmpty
                        ? Center(
                            child: Text(
                              "No Data",
                              style: TextStyle(color: txtColor),
                            ),
                          )
                        : SfCircularChart(
                            legend: Legend(
                              isVisible: true,
                              textStyle: TextStyle(color: txtColor),
                              position: LegendPosition.bottom,
                            ),
                            series: <CircularSeries>[
                              DoughnutSeries<_ChartData, String>(
                                dataSource: osData,
                                xValueMapper: (_ChartData data, _) => data.x,
                                yValueMapper: (_ChartData data, _) => data.y,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                                innerRadius: '60%',
                                explode: true,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. GLOBAL GEO TRAFFIC (Bar Chart)
            GlassCard(
              height: 400,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader("TOP TRAFFIC SOURCES (GEO)", txtColor),
                  const SizedBox(height: 16),
                  Expanded(
                    child: geoData.isEmpty
                        ? Center(
                            child: Text(
                              "No Data",
                              style: TextStyle(color: txtColor),
                            ),
                          )
                        : SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              labelStyle: TextStyle(
                                color: txtColor.withValues(alpha: 0.7),
                              ),
                            ),
                            primaryYAxis: NumericAxis(isVisible: false),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries>[
                              BarSeries<_ChartData, String>(
                                dataSource: geoData
                                    .take(5)
                                    .toList(), // Top 5 only
                                xValueMapper: (_ChartData data, _) => data.x,
                                yValueMapper: (_ChartData data, _) => data.y,
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(color: txtColor),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. SYSTEM PULSE
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader("SYSTEM PULSE", txtColor),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPulseItem(
                        context,
                        "${globalStats.totalSystemLinks}",
                        "Total Links",
                        PhosphorIconsBold.link,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: txtColor.withValues(alpha: 0.2),
                      ),
                      _buildPulseItem(
                        context,
                        "${globalStats.totalSystemClicks}",
                        "Total Redirects",
                        PhosphorIconsBold.lightning,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final txtColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Icon(icon, color: txtColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: txtColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: txtColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}
