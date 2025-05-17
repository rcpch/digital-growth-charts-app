import 'package:digital_growth_charts_app/definitions/helpers.dart';
import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import '../definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import 'package:digital_growth_charts_app/services/centile_chart_data_utils.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';

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

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is CentileChart &&
        other.measurementMethod == measurementMethod &&
        other.sex == sex &&
        other.dob == dob &&
        other.gestationWeeks == gestationWeeks &&
        other.gestationDays == gestationDays &&
        listEquals(other.growthDataForMethod, growthDataForMethod) &&
        other.organizedCentileLines == organizedCentileLines;
  }

  @override
  int get hashCode => Object.hash(
    measurementMethod,
    sex,
    dob,
    gestationWeeks,
    gestationDays,
    Object.hashAll(growthDataForMethod),
    organizedCentileLines,
  );
}

class _CentileChartState extends State<CentileChart> {

  AgeCorrectionMethod _selectedPlotType = AgeCorrectionMethod.chronological;

  static const double _paddingFactor = 0.05; // 5% padding

  List<double> _getMeasurementXValues() {
    final List<double> measurementX = [];
    for (final response in widget.growthDataForMethod) {
      final chronologicalX = response.plottableData?.centileData?.chronologicalDecimalAgeData?.x;
      final correctedX = response.plottableData?.centileData?.correctedDecimalAgeData?.x;
      if (chronologicalX != null) measurementX.add(chronologicalX);
      if (correctedX != null) measurementX.add(correctedX);
    }
    return measurementX;
  }

// Helper to get Y values *only* from the scatter spots
  List<double> _getMeasurementYValues() {
    final List<double> measurementY = [];
    for (final response in widget.growthDataForMethod) {
      final chronologicalY = response.plottableData?.centileData?.chronologicalDecimalAgeData?.y;
      final correctedY = response.plottableData?.centileData?.correctedDecimalAgeData?.y;
      if (chronologicalY != null) measurementY.add(chronologicalY);
      if (correctedY != null) measurementY.add(correctedY);
    }
    return measurementY;
  }

  List<double> _getCentileXValues() {
    final centilePoints = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    if (centilePoints == null || centilePoints.isEmpty) {
      return <double>[];
    }
    return centilePoints
        .expand((cp) => cp.data?.map((p) => p.x).whereType<double>() ?? const <double>[])
        .toList();
  }

  List<double> _getCentileYValues() {
    final centilePoints = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    if (centilePoints == null || centilePoints.isEmpty) {
      return <double>[];
    }
    return centilePoints
        .expand((cp) => cp.data?.map((p) => p.y).whereType<double>() ?? const <double>[])
        .toList();
  }

  double get minX {
    // When _isZoomedToFullLifeCourse is true, this will be different
    // if (_isZoomedToFullLifeCourse) {
    //   final allCentileX = _getCentileXValues();
    //   if (allCentileX.isEmpty) return -0.5; // Or your chart's absolute earliest X
    //   return allCentileX.reduce((a, b) => a < b ? a : b) - 0.1; // Buffer for full view
    // }

    final measurementXValues = _getMeasurementXValues();

    if (measurementXValues.isEmpty) {
      // NO MEASUREMENTS: Default to a view of the start of centiles.
      final allCentileX = _getCentileXValues();
      if (allCentileX.isEmpty) return -0.5; // Absolute default if no data at all
      // Show a small window from the very beginning of the centile data.
      // This ensures even preterm centiles are visible if no measurements exist.
      final double centileDataStart = allCentileX.reduce((a, b) => a < b ? a : b);
      // You might want a fixed default window, e.g., centileDataStart to centileDataStart + 2
      return centileDataStart - 0.1; // Small padding before the earliest centile data
    }

    // HAVE MEASUREMENTS: Base the view on the measurement range.
    final double dataMinX = measurementXValues.reduce((a, b) => a < b ? a : b);
    final double dataMaxX = measurementXValues.reduce((a, b) => a > b ? a : b);
    final double range = dataMaxX - dataMinX;
    // Padding: 5% of range, or 0.5 units (e.g., years) if single point/no range.
    final double padding = (range > 0) ? range * _paddingFactor : 0.5;
    return dataMinX - padding; // Ensure this allows negative values if dataMinX is negative
  }

  double get maxX {
    // if (_isZoomedToFullLifeCourse) {
    //   final allCentileX = _getCentileXValues();
    //   if (allCentileX.isEmpty) return 20.0; // Or your chart's absolute latest X
    //   return allCentileX.reduce((a, b) => a > b ? a : b) + 0.1; // Buffer for full view
    // }

    final measurementXValues = _getMeasurementXValues();

    if (measurementXValues.isEmpty) {
      // NO MEASUREMENTS:
      final allCentileX = _getCentileXValues();
      if (allCentileX.isEmpty) return 2.0; // Absolute default

      final double centileDataStart = allCentileX.reduce((a, b) => a < b ? a : b);
      // Default view shows, for example, up to 2 years from the centile data start,
      // but not exceeding a max like 20. Ensure a minimum window.
      return (centileDataStart + 2.0).clamp(centileDataStart + 0.5, 20.0);
    }

    // HAVE MEASUREMENTS:
    final double dataMinX = measurementXValues.reduce((a, b) => a < b ? a : b); // Recalculate for clarity
    final double dataMaxX = measurementXValues.reduce((a, b) => a > b ? a : b);
    final double range = dataMaxX - dataMinX;
    final double padding = (range > 0) ? range * _paddingFactor : 0.5;

    return dataMaxX + padding;
  }

  double get minY {
    // if (_isZoomedToFullLifeCourse) {
    //   // Logic for full Y range of all centiles and measurements
    //   final allCentileY = _getCentileYValues();
    //   final allMeasurementY = _getMeasurementYValues();
    //   final allY = [...allCentileY, ...allMeasurementY];
    //   if (allY.isEmpty) return 0.0;
    //   final double dataMinY = allY.reduce((a, b) => a < b ? a : b);
    //   final double dataMaxY = allY.reduce((a, b) => a > b ? a : b);
    //   final double range = dataMaxY - dataMinY;
    //   final double padding = (range > 0) ? range * _paddingFactor : 1.0;
    //   return (dataMinY - padding).clamp(0.0, double.infinity);
    // }

    // For the focused view, consider Y values of measurements and visible centile segments
    final currentMinX = minX; // Get the already calculated minX for the current view
    final currentMaxX = maxX; // Get the already calculated maxX for the current view

    final List<double> relevantYValues = [];

    // Add Y values from all child measurements
    relevantYValues.addAll(_getMeasurementYValues());

    // Add Y values from centile line segments that fall within the current X-axis view
    final centileLineSeries = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    if (centileLineSeries != null) {
      for (final centileLine in centileLineSeries) {
        centileLine.data?.forEach((point) {
          // Check if the centile point's X value is within the visible range
          if (point.x != null && point.y != null && point.x! >= currentMinX && point.x! <= currentMaxX) {
            relevantYValues.add(point.y!);
          }
        });
      }
    }

    if (relevantYValues.isEmpty) {
      final allCentileY = _getCentileYValues();
      if (allCentileY.isEmpty) return 0.0; // Absolute default min Y
      relevantYValues.addAll(allCentileY); // Broaden to all centiles if focused view yields nothing
      if (relevantYValues.isEmpty) return 0.0; // Still empty? Absolute default
    }


    final double dataMinY = relevantYValues.reduce((a, b) => a < b ? a : b);
    final double dataMaxY = relevantYValues.reduce((a, b) => a > b ? a : b);
    final double range = dataMaxY - dataMinY;
    final double padding = (range > 0) ? range * _paddingFactor : 1.0; // 1.0 unit fixed padding for Y if single point or flat

    return (dataMinY - padding).clamp(0.0, double.infinity); // Clamp Y at 0, common for growth charts
  }

  double get maxY {
    // if (_isZoomedToFullLifeCourse) {
    //   // Logic for full Y range of all centiles and measurements
    //   final allCentileY = _getCentileYValues();
    //   final allMeasurementY = _getMeasurementYValues();
    //   final allY = [...allCentileY, ...allMeasurementY];
    //   if (allY.isEmpty) return 100.0; // Arbitrary default max Y
    //   final double dataMinY = allY.reduce((a, b) => a < b ? a : b);
    //   final double dataMaxY = allY.reduce((a, b) => a > b ? a : b);
    //   final double range = dataMaxY - dataMinY;
    //   final double padding = (range > 0) ? range * _paddingFactor : 1.0;
    //   return dataMaxY + padding;
    // }

    final currentMinX = minX;
    final currentMaxX = maxX;
    final List<double> relevantYValues = [];

    relevantYValues.addAll(_getMeasurementYValues());

    final centileLineSeries = widget.organizedCentileLines[widget.sex]?[widget.measurementMethod];
    if (centileLineSeries != null) {
      for (final centileLine in centileLineSeries) {
        centileLine.data?.forEach((point) {
          if (point.x != null && point.y != null && point.x! >= currentMinX && point.x! <= currentMaxX) {
            relevantYValues.add(point.y!);
          }
        });
      }
    }

    if (relevantYValues.isEmpty) {
      final allCentileY = _getCentileYValues();
      if (allCentileY.isEmpty) return 100.0; // Absolute default max Y
      relevantYValues.addAll(allCentileY);
      if (relevantYValues.isEmpty) return 100.0; // Still empty? Absolute default
    }

    final double dataMinY = relevantYValues.reduce((a, b) => a < b ? a : b);
    final double dataMaxY = relevantYValues.reduce((a, b) => a > b ? a : b);
    final double range = dataMaxY - dataMinY;
    final double padding = (range > 0) ? range * _paddingFactor : 1.0;

    return dataMaxY + padding;
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
        final double normalizedY = (rightmostSpot.y - minY) / (maxY - minY);
        final double topOffset = chartHeight * (1 - normalizedY);

        labels.add(
          Positioned(
            right: 20,
            top: (topOffset - 10).clamp(0.0, chartHeight - 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: Colors.white
              ),
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
  List<Map<String, dynamic>> _generateScatterSpots() {
    final List<Map<String, dynamic>> spots = [];

    for (final response in widget.growthDataForMethod) {
      final chronologicalData = response.plottableData?.centileData?.chronologicalDecimalAgeData;
      final correctedData = response.plottableData?.centileData?.correctedDecimalAgeData;
      // Add chronological point if selected to show or if 'both' is selected
      if (_selectedPlotType == AgeCorrectionMethod.chronological || _selectedPlotType == AgeCorrectionMethod.both) {
        if (chronologicalData?.x != null && chronologicalData?.y != null) {
          spots.add({
            'spot': ScatterSpot( // Store the ScatterSpot
              chronologicalData!.x!,
              chronologicalData.y!,
              dotPainter: FlDotCirclePainter(
                radius: 6,
                color: AppColours.chronologicalPointColor,
              ),
            ),
            'originalData': response, // Store the original response separately
            'ageType': AgeCorrectionMethod.chronological, // Add age type for differentiation
          });
        }
      }

      // Add corrected point if selected to show or if 'both' is selected
      if (_selectedPlotType == AgeCorrectionMethod.corrected || _selectedPlotType == AgeCorrectionMethod.both) {
        if (correctedData?.x != null && correctedData?.y != null) {
          spots.add({
            'spot': ScatterSpot( // Store the ScatterSpot
              correctedData!.x!,
              correctedData.y!,
              dotPainter: FlDotCrossPainter(
                size: 12,
                color: AppColours.correctedPointColor,
                width: 1.0,
              ),
            ),
            'originalData': response, // Store the original response separately
            'ageType': AgeCorrectionMethod.corrected, // Add age type for differentiation
          });
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

  // SideTitles _getBottomTitles() {
  //
  //   // Example: If x-axis is in days, show labels every year
  //   const double intervalInDays = 365.25; // Approximate days in a year
  //
  //   return SideTitles(
  //     showTitles: true,
  //     reservedSize: 40,
  //     interval: 4, // Show labels every year
  //     getTitlesWidget: (value, meta) {
  //       // Customize the title text based on the value (age in days)
  //       final int years = (value / intervalInDays).round();
  //       return SideTitleWidget(
  //         space: 8.0, // Space between the title and the axis line
  //         meta: meta, // Pass the meta object here
  //         child: Text('${value}y'),
  //       );
  //     },
  //   );
  // }

  // Function to get Y-axis side titles (labels)
  SideTitles _getLeftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 50, // Adjust reserved size for the labels
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

    final List<Map<String, dynamic>> scatterDataWithDetails = _generateScatterSpots();
    final List<ScatterSpot> scatterSpots = scatterDataWithDetails.map((data) => data['spot'] as ScatterSpot).toList();
    final currentMinX = minX; // Assuming minX is a getter
    final currentMaxX = maxX;
    final currentMinY = minY;
    final currentMaxY = maxY;

    final baseData = FlBorderData(
      show: true,
      border: Border.all(color: Colors.transparent),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            chartTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          // bottomTitles: AxisTitles(
                          //   sideTitles: _getBottomTitles(), // This will need to be adjusted when we scope the x-axis to the data
                          //   axisNameWidget: Text(
                          //     _getXAxisTitle(),
                          //     style: const TextStyle(
                          //         fontWeight: FontWeight.bold, fontSize: 12), // Customize style
                          //   ),
                          //   axisNameSize: 20,
                          // ),
                          leftTitles: AxisTitles(
                            sideTitles: _getLeftTitles(),
                            axisNameWidget: Text(
                              _getYAxisTitle(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12), // Customize style
                            ),
                            axisNameSize: 20,
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        minX: currentMinX,
                        maxX: currentMaxX,
                        minY: currentMinY,
                        maxY: currentMaxY,
                        lineBarsData: _generateLineBarsData(),
                        clipData: const FlClipData.all(),
                      ),
                    ),
                    if (_generateScatterSpots().isNotEmpty)
                      ScatterChart(
                        ScatterChartData(
                          clipData: const FlClipData.all(),
                          gridData: const FlGridData(show: false),
                          scatterSpots: scatterSpots,
                          titlesData: FlTitlesData(
                            show: true,
                            // bottomTitles: AxisTitles(
                            //   sideTitles: _getBottomTitles(), // This will need to be adjusted when we scope the x-axis to the data
                            //   axisNameWidget: Text(
                            //     _getXAxisTitle(),
                            //     style: const TextStyle(
                            //         fontWeight: FontWeight.bold, fontSize: 12), // Customize style
                            //   ),
                            //   axisNameSize: 20,
                            // ),
                            leftTitles: AxisTitles(
                              sideTitles: _getLeftTitles(),
                              axisNameWidget: Text(
                                _getYAxisTitle(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12), // Customize style
                              ),
                              axisNameSize: 20,
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: currentMinX,
                          maxX: currentMaxX,
                          minY: currentMinY,
                          maxY: currentMaxY,
                           scatterTouchData: ScatterTouchData(
                             enabled: true,
                             handleBuiltInTouches: true,
                             mouseCursorResolver: (FlTouchEvent, ScatterTouchResponse) {
                               return SystemMouseCursors.click;
                             },
                             touchTooltipData: ScatterTouchTooltipData(
                               getTooltipItems: (ScatterSpot spot) {
                                 // Find the original data
                                 Map<String, dynamic>? touchedData;
                                 for (final data in scatterDataWithDetails) {
                                   if (data['spot'].x == spot.x && data['spot'].y == spot.y) {
                                     touchedData = data;
                                     break; // Found the match, exit the loop
                                   }
                                 }

                                 if (touchedData != null) {
                                   // Now you have access to the original data and age type
                                   final GrowthDataResponse originalResponse = touchedData['originalData'] as GrowthDataResponse;
                                   final AgeCorrectionMethod ageType = touchedData['ageType'] as AgeCorrectionMethod;

                                   // Build your tooltip string with meaningful data
                                   String tooltipText = "${originalResponse.measurementDates?.observationDate ?? 'N/A'}\n${originalResponse.childObservationValue?.observationValue  ?? 'N/A'} ${getMeasurementMethodUnits(originalResponse.childObservationValue?.measurementMethod) ?? 'N/A'}";

                                   // Add age and centile/SDS based on age type
                                   if (ageType == AgeCorrectionMethod.chronological || ageType == AgeCorrectionMethod.both) {
                                     tooltipText += "\nChronological Age: ${originalResponse.measurementDates?.chronologicalCalendarAge ?? 'N/A'}\nChronological Centile: ${originalResponse.measurementCalculatedValues?.chronologicalCentile ?? 'N/A'}";
                                   }

                                   if (ageType == AgeCorrectionMethod.corrected || ageType == AgeCorrectionMethod.both) {
                                     tooltipText += "\nCorrected Age: ${originalResponse.measurementDates?.correctedCalendarAge ?? 'N/A'}\nCorrected Centile: ${originalResponse.measurementCalculatedValues?.correctedCentile ?? 'N/A'}\nInterpretation: ${originalResponse.measurementCalculatedValues?.correctedCentileBand ?? 'N/A'}";
                                   }

                                   return ScatterTooltipItem(
                                     tooltipText,
                                     textStyle: const TextStyle(
                                       color: Colors.white,
                                       fontWeight: FontWeight.bold,
                                       fontSize: 10, // Adjust font size for modal
                                     ),
                                     textDirection: TextDirection.ltr,
                                     textAlign: TextAlign.left,
                                   );
                 }
                                 return null; // Returning null means no tooltip will be shown
                               },
                             ),
                           ),
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

