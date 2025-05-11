import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../definitions/enums.dart'; // Your enums

class CentileChart extends StatelessWidget {
  final List<List<Map<double, double>>> chartData;
  final MeasurementMethod measurementMethod;
  final Sex sex;

  const CentileChart({
    Key? key,
    required this.chartData,
    required this.measurementMethod,
    required this.sex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.6, // Adjust as needed
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            // titlesData: FlTitlesData(
            //   bottomTitles: AxisTitles(
            //     side: const BottomTitlesSide(),
            //     getTitles: (value) {
            //       // Format x-axis labels (age) as needed
            //       return value.toStringAsFixed(1);
            //     },
            //   ),
            //   leftTitles: AxisTitles(
            //     side: const LeftTitlesSide(),
            //     getTitles: (value) {
            //       // Format y-axis labels (observation value) as needed
            //       return value.toStringAsFixed(1);
            //     },
            //   ),
            // ),
            borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d))),
            minX: 0, // Adjust based on your age range
            maxX: 20, // Adjust based on your age range
            minY: 0, // Adjust based on your observation value range
            maxY: 210, // Adjust based on your observation value range
            lineBarsData: _generateLineBarsData(),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _generateLineBarsData() {
    return chartData.map((line) {
      final List<FlSpot> spots = line.map((point) {
        return FlSpot(point.keys.first, point.values.first);
      }).toList();

      // Customize the appearance of each line (e.g., color, stroke width)
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      );
    }).toList();
  }
}