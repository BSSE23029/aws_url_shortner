import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(urlsProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final urlsState = ref.watch(urlsProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      enableBack: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-url'),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        child: const Icon(PhosphorIconsBold.plus),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(urlsProvider.notifier).loadDashboard(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildCipherHeader(authState.user, txtColor),
            const SizedBox(height: 24),

            // QUICK STATS ROW
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "SYSTEM_IO",
                    "${urlsState.urls.length}",
                    PhosphorIconsRegular.cpu,
                    txtColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "NETWORK_TX",
                    "${urlsState.myTotalClicks}",
                    PhosphorIconsRegular.lightning,
                    txtColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    "GLOBAL_LINKS",
                    "${urlsState.globalStats.totalSystemLinks}",
                    PhosphorIconsRegular.globe,
                    txtColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    "GLOBAL_CLICKS",
                    "${urlsState.globalStats.totalSystemClicks}",
                    PhosphorIconsRegular.chartLine,
                    txtColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildPerformanceIndicators(urlsState, txtColor),

            const SizedBox(height: 32),
            _buildTopPerformers(urlsState, txtColor),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildListHeader(txtColor),
                TextButton.icon(
                  onPressed: () => context.push('/deployments'),
                  icon: const Icon(PhosphorIconsRegular.arrowRight, size: 16),
                  label: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (urlsState.urls.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        PhosphorIconsRegular.package,
                        size: 48,
                        color: txtColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text("NO_DEPLOYMENTS_ACTIVE"),
                    ],
                  ),
                ),
              )
            else
              ...urlsState.urls.take(5).map((u) => _buildUrlItem(u, txtColor)),
            if (urlsState.urls.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () => context.push('/deployments'),
                    child: Text(
                      'VIEW ${urlsState.urls.length - 5} MORE',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCipherHeader(UserModel? user, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "USER_SESSION: ${user?.name?.toUpperCase() ?? 'GUEST'}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    "STATUS: AUTHENTICATED // ENCRYPTED",
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              ),
              const Icon(
                PhosphorIconsFill.shieldCheck,
                color: Colors.greenAccent,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _terminalLine("INIT_HANDSHAKE", "SUCCESS", color),
                _terminalLine("WAF_POLICIES", "ACTIVE_BLOCK", color),
                _terminalLine(
                  "GATEWAY_ID",
                  user?.id.substring(0, 12).toUpperCase() ?? "---",
                  color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminalLine(String key, String val, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "> $key",
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              color: c.withValues(alpha: 0.4),
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              color: c,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 18),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.3),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 20,
            child: SfSparkLineChart(
              data: const [1, 5, 3, 9, 4, 8, 6],
              color: Colors.cyanAccent.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlItem(UrlModel u, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/url-details', extra: u),
        child: Column(
          children: [
            ListTile(
              leading: _buildMiniRadial(u.clickCount),
              title: Text(
                u.shortCode.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              subtitle: Text(
                u.originalUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.white24),
              ),
              trailing: Text(
                "${u.clickCount}",
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 24,
              child: charts.SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: const charts.CategoryAxis(isVisible: false),
                primaryYAxis: const charts.NumericAxis(isVisible: false),
                series: <charts.CartesianSeries<double, int>>[
                  charts.StepLineSeries<double, int>(
                    dataSource: const [1, 4, 2, 7, 3, 9, 5, 8],
                    xValueMapper: (double d, i) => i,
                    yValueMapper: (double d, _) => d,
                    color: Colors.cyanAccent.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRadial(int val) {
    return SizedBox(
      width: 30,
      height: 30,
      child: gauges.SfRadialGauge(
        axes: <gauges.RadialAxis>[
          gauges.RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            axisLineStyle: const gauges.AxisLineStyle(
              thickness: 0.2,
              color: Colors.white10,
              thicknessUnit: gauges.GaugeSizeUnit.factor,
            ),
            pointers: [
              gauges.RangePointer(
                value: (val * 10.0).clamp(0, 100),
                width: 0.2,
                sizeUnit: gauges.GaugeSizeUnit.factor,
                color: Colors.cyanAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(Color c) {
    return Row(
      children: [
        Container(width: 2, height: 12, color: c),
        const SizedBox(width: 8),
        Text(
          "ACTIVE_DEPLOYMENTS",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: c.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicators(UrlsState state, Color color) {
    final avgClicks = state.urls.isEmpty
        ? 0.0
        : state.myTotalClicks / state.urls.length;
    final systemAvg = state.globalStats.totalSystemLinks > 0
        ? state.globalStats.totalSystemClicks /
              state.globalStats.totalSystemLinks
        : 0.0;
    final performance = systemAvg > 0
        ? (avgClicks / systemAvg * 100).clamp(0, 200)
        : 100;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.trendUp, color: color, size: 16),
              const SizedBox(width: 8),
              const Text(
                "PERFORMANCE_MATRIX",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildIndicator(
                  "YOUR AVG",
                  avgClicks.toStringAsFixed(1),
                  "clicks/link",
                  Colors.cyanAccent,
                  color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIndicator(
                  "SYSTEM AVG",
                  systemAvg.toStringAsFixed(1),
                  "clicks/link",
                  Colors.purpleAccent,
                  color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIndicator(
                  "PERFORMANCE",
                  "${performance.toStringAsFixed(0)}%",
                  performance > 100 ? "above average" : "below average",
                  performance > 100 ? Colors.greenAccent : Colors.orangeAccent,
                  color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (performance / 200).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                performance > 100 ? Colors.greenAccent : Colors.orangeAccent,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
    String label,
    String value,
    String unit,
    Color accentColor,
    Color baseColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: baseColor.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: accentColor,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 4),
        Text(unit, style: const TextStyle(fontSize: 8, color: Colors.white30)),
      ],
    );
  }

  Widget _buildTopPerformers(UrlsState state, Color color) {
    final sortedUrls = List<UrlModel>.from(state.urls)
      ..sort((a, b) => b.clickCount.compareTo(a.clickCount));
    final topUrls = sortedUrls.take(3).toList();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.trophy,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "TOP_PERFORMERS",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Text(
                "RANKED BY CLICKS",
                style: TextStyle(
                  fontSize: 8,
                  color: color.withValues(alpha: 0.4),
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topUrls.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "NO DATA AVAILABLE",
                  style: TextStyle(fontSize: 10, color: Colors.white24),
                ),
              ),
            )
          else
            ...topUrls.asMap().entries.map((entry) {
              final index = entry.key;
              final url = entry.value;
              final medals = [Colors.amber, Colors.grey, Colors.brown];
              final medalColor = index < medals.length
                  ? medals[index]
                  : Colors.white24;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: medalColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: medalColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "#${index + 1}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: medalColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              url.shortCode.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              url.originalUrl,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${url.clickCount}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: medalColor,
                              fontFamily: 'Courier',
                            ),
                          ),
                          Text(
                            "CLICKS",
                            style: TextStyle(
                              fontSize: 8,
                              color: color.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
