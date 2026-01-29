// metric_line_chart.dart
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MetricLineChart extends StatelessWidget {
  const MetricLineChart({
    super.key,
    required this.spots,
    required this.yLabel,
    required this.color,
    required this.dashLineColour,
    this.aspectRatio = 6.5,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.minScale = 10.0,
    this.maxScale = 20.0,
    this.transformationController,
    this.touchIndex,
    this.onTouch, // (index, x, y)
    this.bottomTitleBuilder, // build label from x (timestamp, index, etc.)
    this.lineWidth = 1.0,
    this.touchThreshold = 5,
    this.showBottomTitle = false,
    required this.minY,
    required this.maxY,
  });

  final List<FlSpot> spots;
  final String yLabel;
  final Color color;
  final Color dashLineColour;

  final double aspectRatio;
  final bool panEnabled;
  final bool scaleEnabled;
  final double minScale;
  final double maxScale;
  final TransformationController? transformationController;
  final bool showBottomTitle;

  final int? touchIndex;
  final void Function(int index, double x, double y)? onTouch;
  final String Function(double x)? bottomTitleBuilder;

  final double lineWidth;
  final double touchThreshold;

  final double minY;
  final double maxY;

  static int _findClosestSpotIndex(List<FlSpot> spots, double x) {
    if (spots.isEmpty) return 0;
    int lo = 0, hi = spots.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (spots[mid].x < x) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    // lo is first >= x; choose closer of lo and lo-1
    if (lo > 0 &&
        (lo >= spots.length ||
            (x - spots[lo - 1].x).abs() <= (spots[lo].x - x).abs())) {
      return lo - 1;
    }
    return lo.clamp(0, spots.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Padding(
          padding:
              const EdgeInsets.all(16), // small fix from EdgeInsetsGeometry
          child: LineChart(
            transformationConfig: FlTransformationConfig(
              scaleAxis: FlScaleAxis.horizontal,
              minScale: minScale,
              maxScale: maxScale,
              panEnabled: panEnabled,
              scaleEnabled: scaleEnabled,
              transformationController: transformationController,
              
            ),
            LineChartData(
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  color: color,
                  barWidth: lineWidth,
                  dotData: const FlDotData(show: false),
                  showingIndicators:
                      touchIndex != null ? [touchIndex!] : const [],
                ),
                
              ],
              lineTouchData: LineTouchData(
                
                handleBuiltInTouches: false,
                touchSpotThreshold: touchThreshold,
                getTouchLineStart: (_, __) => -double.infinity,
              //  getTouchLineEnd: (_, __) => double.infinity,
                getTouchedSpotIndicator: (_, spotIndexes) =>
                    spotIndexes.map((_) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                        color: Colors.amber,
                        strokeWidth: 1.5,
                        dashArray: [8, 2]),

                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 0,
                        strokeColor: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touched) => touched.map((barSpot) {
                    final val = barSpot.y;
                    return LineTooltipItem(
                      'AFR: ${val.toStringAsFixed(2)}',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    );
                  }).toList(),
                  getTooltipColor: (_) => Colors.black,
                ),
                touchCallback: (event, response) {
                  if (response?.lineBarSpots == null ||
                      response!.lineBarSpots!.isEmpty) return;
                  final hit = response.lineBarSpots!.first;
                  final idx = _findClosestSpotIndex(spots, hit.x);
                  onTouch?.call(idx, hit.x, hit.y);
                },
              ),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  axisNameWidget:
                      Text(yLabel, style: const TextStyle(color: Colors.white)),
                  axisNameSize: 30,
                ),
                bottomTitles: AxisTitles(
                  
                  sideTitles: SideTitles(
                    showTitles: showBottomTitle,
                    
                    reservedSize: 38,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) {
                      final text = bottomTitleBuilder?.call(value) ??
                          value.toInt().toString();
                      return SideTitleWidget(
                        meta: meta,
                        child: Transform.rotate(
                          angle: -45 * math.pi / 180,
                          child: Text(text,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            duration: Duration.zero,
          ),
        ),
      ),
    );
  }
}
