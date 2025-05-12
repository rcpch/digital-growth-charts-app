import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../definitions/enums.dart'; // Your enums
import '../classes/digital_growth_charts_api_response.dart';

class CentileChart extends StatefulWidget {
  final List<List<Map<String, double>>> chartData;
  final MeasurementMethod measurementMethod;
  final Sex sex;
  final List<GrowthDataResponse> growthData;

  const CentileChart({
    Key? key,
    required this.chartData,
    required this.measurementMethod,
    required this.sex,
    required this.growthData,
  }) : super(key: key);

  @override
  State<CentileChart> createState() => _CentileChartState();
}

class _CentileChartState extends State<CentileChart> {
  AgeCorrectionMethod selectedPlotType = AgeCorrectionMethod.chronological;


  @override
  Widget build(BuildContext context) {
    // Determine chart title based on measurementMethod and sex
    String chartTitle = '';
    switch (widget.measurementMethod) {
      case MeasurementMethod.height:
        chartTitle = 'Height for ${widget.sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.weight:
        chartTitle = 'Weight for ${widget.sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.ofc:
        chartTitle = 'Head Circumference for ${widget.sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
      case MeasurementMethod.bmi:
        chartTitle = 'BMI for ${widget.sex == Sex.male ? 'Boys' : 'Girls'}';
        break;
    }

    // useCorrectedAge is not used in this snippet, remove if unnecessary.
    // final bool useCorrectedAge;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          children: [
            // Toggle buttons
            ToggleButtons(
              isSelected: [
                selectedPlotType == AgeCorrectionMethod.chronological,
                selectedPlotType == AgeCorrectionMethod.corrected,
                selectedPlotType == AgeCorrectionMethod.both,
              ],
              onPressed: (int index) {
                setState(() {
                  selectedPlotType = AgeCorrectionMethod.values[index];
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Chronological'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Corrected'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Both'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // centile chart
            Expanded( // Wrap the chart area in Expanded
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
                    if (_generateScatterSpots().isNotEmpty)
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
            ), // Closing bracket for Expanded
          ]
      ),
    );
  }

  List<LineChartBarData> _generateLineBarsData() {
    const dashedValues = [0.4, 9, 50, 91, 99.6];
    return widget.chartData.map((line) {
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

    final relevantGrowthData = widget.growthData.where((response) {
      return response.childObservationValue?.measurementMethod == widget.measurementMethod.toString().split('.').last.toLowerCase();
    }).toList();

    for (final response in relevantGrowthData) {
      final chronological = response.plottableData?.centileData?.chronologicalDecimalAgeData;
      final corrected = response.plottableData?.centileData?.correctedDecimalAgeData;

      if (selectedPlotType == AgeCorrectionMethod.chronological || selectedPlotType == AgeCorrectionMethod.both) {
        if (chronological?.x != null && chronological?.y != null) {
          spots.add(
            ScatterSpot(
              chronological!.x!,
              chronological.y!,
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
        }
      }

      if (selectedPlotType == AgeCorrectionMethod.corrected || selectedPlotType == AgeCorrectionMethod.both) {
        if (corrected?.x != null && corrected?.y != null) {
          spots.add(
            ScatterSpot(
              corrected!.x!,
              corrected.y!,
              dotPainter: FlDotCrossPainter(
                size: 12,
                color: Theme.of(context).primaryColor,
                width: 2.0
              ),
            ),
          );
        }
      }
    }

    return spots;
  }

}

