import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/cyber_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txtColor = theme.colorScheme.onSurface;

    return CyberScaffold(
      // No title, let Rail handle context
      enableBack: false,
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            "Analytics",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
          ),
          const SizedBox(height: 32),

          GlassCard(
            height: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TRAFFIC FLUX",
                  style: TextStyle(
                    color: txtColor.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      labelStyle: TextStyle(
                        color: txtColor.withValues(alpha: 0.5),
                      ),
                      axisLine: AxisLine(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      majorGridLines: MajorGridLines(
                        width: 1,
                        color: txtColor.withValues(alpha: 0.1),
                      ),
                      labelStyle: TextStyle(
                        color: txtColor.withValues(alpha: 0.5),
                      ),
                      axisLine: AxisLine(width: 0),
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: '',
                      canShowMarker: false,
                    ),
                    series: <CartesianSeries>[
                      SplineAreaSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Mon', 35),
                          ChartData('Tue', 28),
                          ChartData('Wed', 34),
                          ChartData('Thu', 32),
                          ChartData('Fri', 40),
                          ChartData('Sat', 60),
                          ChartData('Sun', 55),
                        ],
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                            theme.colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderColor: theme.colorScheme.primary,
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
