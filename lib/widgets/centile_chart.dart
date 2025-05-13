import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import 'package:digital_growth_charts_app/services/centile_chart_data_utils.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../classes/centile_labels.dart';

class CentileChart extends StatefulWidget {
  final OrganizedCentileLines organizedCentileLines;
  final MeasurementMethod measurementMethod;
  final Sex sex;
  final List<GrowthDataResponse> growthDataForMethod;
  final DateTime dob;
  final int? gestationWeeks;
  final int? gestationDays;


  const CentileChart({
    Key? key,
    required this.organizedCentileLines,
    required this.measurementMethod,
    required this.sex,
    required this.growthDataForMethod,
    required this.dob,
    this.gestationWeeks,
    this.gestationDays,
  }) : super(key: key);

  @override
  State<CentileChart> createState() => _CentileChartState();
}

class _CentileChartState extends State<CentileChart> {
  AgeCorrectionMethod _selectedPlotType = AgeCorrectionMethod.chronological;

  double get _minX => _getCentileXValues().reduce((a, b) => a < b ? a : b);
  double get _maxX => _getCentileXValues().reduce((a, b) => a > b ? a : b);
  double get _minY => _getCentileYValues().reduce((a, b) => a < b ? a : b);
  double get _maxY => _getCentileYValues().reduce((a, b) => a > b ? a : b);

  List<double> _getCentileXValues() {
    final centilePoints = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    return centilePoints
        ?.expand((cp) => cp.data?.map((p) => p.x ?? 0.0).cast<double>() ?? const <double>[])
        .toList() ??
        <double>[0.0];
  }

  List<double> _getCentileYValues() {
    final centilePoints = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    return centilePoints
        ?.expand((cp) => cp.data?.map((p) => p.y ?? 0.0).cast<double>() ?? const <double>[])
        .toList() ??
        <double>[0.0];
  }

  List<Widget> _buildRightAxisLabels(BoxConstraints constraints) {
    final List<Widget> labels = [];

    final centilePoints = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    if (centilePoints == null || centilePoints.isEmpty) return labels;

    final chartHeight = constraints.maxHeight;

    // Group centile lines by centile value
    final Map<double, List<CentileDataPoint>> grouped = {};
    for (final centile in centilePoints) {
      final key = centile.centile ?? 0.0;
      grouped.putIfAbsent(key, () => []).add(centile);
    }

    for (final entry in grouped.entries) {
      final lines = entry.value;

      // Pick the line with the highest max x (i.e., most rightward)
      CentileDataPoint? rightmostLine;
      double highestX = double.negativeInfinity;

      for (final line in lines) {
        final data = line.data;
        if (data == null || data.isEmpty) continue;

        final List<FlSpot> spots = data
            .map((p) => FlSpot(p.x ?? 0.0, p.y ?? 0.0))
            .toList();

        final FlSpot maxXSpot = spots.reduce((a, b) => a.x > b.x ? a : b);
        if (maxXSpot.x > highestX) {
          highestX = maxXSpot.x;
          rightmostLine = line;
        }
      }


      // Build label for the rightmost line (if any)
      if (rightmostLine != null && rightmostLine.data != null && rightmostLine.data!.isNotEmpty) {
        final List<FlSpot> spots = rightmostLine.data!
            .map((p) => FlSpot(p.x ?? 0.0, p.y ?? 0.0))
            .toList();

        final FlSpot rightmostSpot = spots.reduce((a, b) => a.x > b.x ? a : b);
        final double normalizedY = (rightmostSpot.y - _minY) / (_maxY - _minY);
        final double topOffset = chartHeight * (1 - normalizedY);

        labels.add(
          Positioned(
            right: 50,
            top: (topOffset - 10).clamp(0.0, chartHeight - 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                '${rightmostLine.centile?.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: primaryColour),
              ),
            ),
          ),
        );
      }
    }

    return labels;
  }







  List<LineChartBarData> _generateLineBarsData() {
    final List<LineChartBarData> centileLines = [];

    // Get the centile data for the specific sex and measurement method from the organized cache
    final List<CentileDataPoint>? centileDataPoints =
    widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];

    // These are the centile values that should have dashed lines
    const dashedCentileValues = [0.4, 9.0, 50.0, 91.0, 99.6];

    if (centileDataPoints != null) {

      for (final centileDataPoint in centileDataPoints) {
        if (centileDataPoint.data != null) {

          final List<FlSpot> spots = centileDataPoint.data!.map((dataPoint) {
            // Assuming dataPoint.x is the age and dataPoint.y is the measurement value.
            final double xValue = dataPoint.x ?? 0.0;
            final double yValue = dataPoint.y ?? 0.0;
            return FlSpot(xValue, yValue);
          }).toList();

          if (spots.isNotEmpty) {
            final isDashed = dashedCentileValues.contains(centileDataPoint.centile);

            centileLines.add(
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColours.centileLineColor(centileDataPoint.centile),
                dashArray: isDashed ? [5, 5] : null,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            );
          }
        }
      }
    }
    return centileLines;
  }

  // Helper to prepare the individual growth data points for fl_chart
  List<ScatterSpot> _generateScatterSpots() {
    final List<ScatterSpot> spots = [];

    for (final response in widget.growthDataForMethod) {
      final chronologicalData = response.plottableData?.centileData?.chronologicalDecimalAgeData;
      final correctedData = response.plottableData?.centileData?.correctedDecimalAgeData;

      // Add chronological point if selected to show or if 'both' is selected
      if (_selectedPlotType == AgeCorrectionMethod.chronological || _selectedPlotType == AgeCorrectionMethod.both) {
        if (chronologicalData?.x != null && chronologicalData?.y != null) {
          spots.add(
            ScatterSpot(
              chronologicalData!.x!,
              chronologicalData.y!,
              // Use a distinct painter for chronological points
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: AppColours.chronologicalPointColor, // Use a specific color for chronological points
              ),
            ),
          );
        }
      }

      // Add corrected point if selected to show or if 'both' is selected
      if (_selectedPlotType == AgeCorrectionMethod.corrected || _selectedPlotType == AgeCorrectionMethod.both) {
        if (correctedData?.x != null && correctedData?.y != null) {
          spots.add(
            ScatterSpot(
              correctedData!.x!,
              correctedData.y!,
              // Use a distinct painter for corrected points
              dotPainter: FlDotCrossPainter(
                size: 12,
                color: AppColours.correctedPointColor, // Use a specific color for corrected points
                width: 2.0,
              ),
            ),
          );
        }
      }
    }

    return spots;
  }



  // Determine the appropriate title for the axes based on the measurement method
  String _getXAxisTitle() {

    return 'Age (years)'; // Adjust based on your API's x-axis units
  }

  String _getYAxisTitle() {
    switch (widget.measurementMethod) {
      case MeasurementMethod.height:
        return 'Height (cm)';
      case MeasurementMethod.weight:
        return 'Weight (kg)';
      case MeasurementMethod.ofc:
        return 'Head Circumference (cm)';
      case MeasurementMethod.bmi:
        return 'BMI (kg/m²)';
      default: // Should not happen with the enum
        return 'Measurement Value';
    }
  }

  SideTitles _getBottomTitles() {
    // This needs to align with the x-axis unit of your data (e.g., days, months, years)
    // And should consider the age range covered by the data.

    // Example: If x-axis is in days, show labels every year
    const double intervalInDays = 365.25; // Approximate days in a year

    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: intervalInDays, // Show labels every year
      getTitlesWidget: (value, meta) {
        // Customize the title text based on the value (age in days)
        final int years = (value / intervalInDays).round();
        return SideTitleWidget(
          space: 8.0, // Space between the title and the axis line
          meta: meta, // Pass the meta object here
          child: Text('${years}y'),
        );
      },
    );
  }

  // Function to get Y-axis side titles (labels)
  SideTitles _getLeftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 40, // Adjust reserved size for the labels
      getTitlesWidget: (value, meta) {
        // Customize the title text based on the value (measurement)
        // You might want to format the number of decimal places based on the measurement type
        String text;
        if (value == 0) {
          text = '0';
        } else {
          // Simple example: show 1 decimal place for non-zero values
          text = value.toStringAsFixed(1);
        }
        return SideTitleWidget(
          space: 8.0, // Space between the title and the axis line
          meta: meta, // Pass the meta object here
          child: Text(text),
        );
      },
    );
  }


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
              _selectedPlotType == AgeCorrectionMethod.chronological,
              _selectedPlotType == AgeCorrectionMethod.corrected,
              _selectedPlotType == AgeCorrectionMethod.both,
            ],
            onPressed: (int index) {
              setState(() {
                _selectedPlotType = AgeCorrectionMethod.values[index];
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
          // Chart area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: _getBottomTitles()),
                          leftTitles: AxisTitles(sideTitles: _getLeftTitles()),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d)),
                        ),
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        lineBarsData: _generateLineBarsData(),
                      ),
                    ),
                    if (_generateScatterSpots().isNotEmpty)
                      ScatterChart(
                        ScatterChartData(
                          scatterSpots: _generateScatterSpots(),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: _minX,
                          maxX: _maxX,
                          minY: _minY,
                          maxY: _maxY,
                        ),
                      ),
                    // Labels along the right axis
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(children: _buildRightAxisLabels(constraints));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

  }

}

