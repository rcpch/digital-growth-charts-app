import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../definitions/enums.dart'; // Your enums

class CentileChart extends StatelessWidget {
  final List<List<Map<String, double>>> chartData;
  final MeasurementMethod measurementMethod;
  final Sex sex;
  final List<Map<double?, double?>>? scatterData;

  const CentileChart({
    Key? key,
    required this.chartData,
    required this.measurementMethod,
    required this.sex,
    this.scatterData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine chart title based on measurementMethod and sex
    String chartTitle = '';
    switch (measurementMethod) {
      case MeasurementMethod.height:
        chartTitle = 'Height for ${sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.weight:
        chartTitle = 'Weight for ${sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.ofc:
        chartTitle = 'Head Circumference for ${sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.bmi:
        chartTitle = 'BMI for ${sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: Stack(
          children: [
            LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d))),
                minX: 0, // Adjust based on your age range
                maxX: 20, // Adjust based on your age range
                minY: 0, // Adjust based on your observation value range
                maxY: 210, // Adjust based on your observation value range
                lineBarsData: _generateLineBarsData(),
              ),
            ),
            // Add the scatter plot layer if scatterData is provided
            if (scatterData != null && scatterData!.isNotEmpty)
              ScatterChart(
                ScatterChartData(
                  scatterSpots: _generateScatterSpots(),
                  titlesData: FlTitlesData(show: false), //hide the titles
                  borderData: FlBorderData(show: false), //hide the border
                  minX: 0,
                  maxX: 20,
                  minY: 0,
                  maxY: 210,
                ),
              ),
            Positioned( // position the title
              top: 8,
              left: 0,
              right: 0,
              child: Center(child: Text(chartTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            )
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _generateLineBarsData() {
    const dashedValues = [0.4, 9, 50, 91, 99.6];
    return chartData.map((line) {
      final List<FlSpot> spots = line.map((point) {
        final x = point['x'] ?? 0.0;
        final y = point['y'] ?? 0.0;
        return FlSpot(x, y);
      }).toList();

      // Determine if the line should be dashed based on the 'l' value.
      final isDashed = dashedValues.contains(line.first['l']);
      final lValue = line.first['l']; // Get the l value

      return LineChartBarData(
        spots: spots,
        isCurved: true,
        dashArray: isDashed ? [5, 5] : null, // Use null for solid line
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      );
    }).toList();
  }

  List<ScatterSpot> _generateScatterSpots() {
    List<ScatterSpot> spots = [];
    for (var point in scatterData!) {
      final x = point.keys.first;
      final y = point.values.first;
      if (x != null && y != null) { // Only add if both x and y are not null
        spots.add(
          ScatterSpot(
            x,
            y,
          ),
        );
      }
    }
    return spots;
  }
}

