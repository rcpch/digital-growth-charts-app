// Dart/flutter imports
import 'package:digital_growth_charts_app/themes/colours.dart';
import 'package:flutter/material.dart';

// Third party imports
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// RCPCH Imports
import '../classes/digital_growth_charts_api_response.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../definitions/enums.dart';
import './centile_chart.dart';
import './results_data_table.dart';

class ResultsPage extends StatefulWidget {
  final List<GrowthDataResponse> growthDataList;
  final DigitalGrowthChartsCentileLines chartData;
  final Sex sex;
  final MeasurementMethod measurementMethod;

  const ResultsPage({
    Key? key,
    required this.growthDataList,
    required this.chartData,
    required this.sex,
    required this.measurementMethod,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  final int _numPages = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Chart Results'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // First Page: Centile Chart
                CentileChart(
                  chartData: _prepareChartData(widget.chartData.centileData!, widget.measurementMethod, widget.sex),
                  measurementMethod: widget.measurementMethod,
                  sex: widget.sex,
                  growthData: widget.growthDataList,
                ),
                // Second Page: Result TextSpans
                ResultsDataTable(
                  growthDataList: widget.growthDataList,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _numPages,
                  effect: WormEffect(
                    dotColor: Colors.grey,
                    activeDotColor: Theme.of(context).primaryColor,
                    dotHeight: 8.0,
                    dotWidth: 8.0,
                    spacing: 5.0,
                  ),
                  onDotClicked: (index) {
                    _goToPage(index);
                  },
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
                      child: const Text('Chart'),
                    ),
                    TextButton(
                      onPressed: _currentPage < _numPages - 1 ? () => _goToPage(1) : null,
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<List<Map<String, double>>> _prepareChartData(
    List<ReferenceData> allReferenceData,
    MeasurementMethod method,
    Sex sex) {
  List<List<Map<String, double>>> allLinesData = [];

  for (final referenceData in allReferenceData) {
    SexMeasurementData? sexMeasurementData;
    if (referenceData.ukWhoChild != null) {
      sexMeasurementData = referenceData.ukWhoChild;
    } else if (referenceData.uk90Child != null) {
      sexMeasurementData = referenceData.uk90Child;
    } else if (referenceData.ukWhoInfant != null) {
      sexMeasurementData = referenceData.ukWhoInfant;
    } else if (referenceData.uk90Preterm != null) {
      sexMeasurementData = referenceData.uk90Preterm;
    }

    if (sexMeasurementData != null) {
      List<CentileDataPoint>? measurementDataPoints;
      if (sex == Sex.male) {
        switch (method) {
          case MeasurementMethod.height:
            measurementDataPoints = sexMeasurementData.male?.height;
            break;
          case MeasurementMethod.weight:
            measurementDataPoints = sexMeasurementData.male?.weight;
            break;
          case MeasurementMethod.ofc:
            measurementDataPoints = sexMeasurementData.male?.ofc;
            break;
          case MeasurementMethod.bmi:
            measurementDataPoints = sexMeasurementData.male?.bmi;
            break;
        }
      } else {
        switch (method) {
          case MeasurementMethod.height:
            measurementDataPoints = sexMeasurementData.female?.height;
            break;
          case MeasurementMethod.weight:
            measurementDataPoints = sexMeasurementData.female?.weight;
            break;
          case MeasurementMethod.ofc:
            measurementDataPoints = sexMeasurementData.female?.ofc;
            break;
          case MeasurementMethod.bmi:
            measurementDataPoints = sexMeasurementData.female?.bmi;
            break;
        }
      }

      if (measurementDataPoints != null) {
        for (final centileDataPoint in measurementDataPoints) {
          List<Map<String, double>> lineData = [];
          if (centileDataPoint.data != null) {
            for (final dataPoint in centileDataPoint.data!) {
              if (dataPoint.x != null && dataPoint.y != null) {
                // Include the 'l' value in the map, defaulting to 0 if null
                lineData.add({
                  'x': dataPoint.x!,
                  'y': dataPoint.y!,
                  'l': dataPoint.l ?? 0.0,
                });
              }
            }
            if (lineData.isNotEmpty) {
              allLinesData.add(lineData);
            }
          }
        }
      }
    }
  }
  return allLinesData;
}

