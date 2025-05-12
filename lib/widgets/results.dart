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
import '../services/centile_chart_data_utils.dart';

class ResultsPage extends StatefulWidget {
  final Map<MeasurementMethod, List<GrowthDataResponse>> organizedGrowthData;
  final OrganizedCentileLines organizedCentileLines;

  final Sex sex;
  final MeasurementMethod measurementMethod;
  final DateTime dob;
  final int? gestationWeeks;
  final int? gestationDays;

  const ResultsPage({
    Key? key,
    required this.organizedGrowthData,
    required this.organizedCentileLines,
    required this.sex,
    required this.dob,
    required this.measurementMethod,
    this.gestationWeeks,
    this.gestationDays
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late PageController _pageController;
  int _currentPage = 0;
  // List of MeasurementMethods for which we have growth data
  List<MeasurementMethod> _availableCharts = [];


  @override
  void initState() {
    super.initState();
    // Determine which charts are available based on the growth data
    _availableCharts = widget.organizedGrowthData.keys.toList();

    // Initialize PageController with the initial page set to the first available chart
    _pageController = PageController(initialPage: 0);
  }

  // Helper to get the chart title based on MeasurementMethod and Sex
  String _getChartTitle(MeasurementMethod method, Sex sex) {
    switch (method) {
      case MeasurementMethod.height:
        return 'Height for ${sex == Sex.male ? 'Boys' : 'Girls'}';
      case MeasurementMethod.weight:
        return 'Weight for ${sex == Sex.male ? 'Boys' : 'Girls'}';
      case MeasurementMethod.ofc:
        return 'Head Circumference for ${sex == Sex.male ? 'Boys' : 'Girls'}';
      case MeasurementMethod.bmi:
        return 'BMI for ${sex == Sex.male ? 'Boys' : 'Girls'}';
    }
  }

  // Get the title for the current page
  String _getCurrentPageTitle() {
    if (_availableCharts.isEmpty) {
      return 'Growth Chart Results'; // Default title if no data
    }
    if (_currentPage < _availableCharts.length) {
      // It's a chart page
      final currentMeasurementMethod = _availableCharts[_currentPage];
      return _getChartTitle(currentMeasurementMethod, widget.sex);
    } else {
      // It's the data table page
      return 'Measurement Data';
    }
  }

  // Add a page for the data table
  static const int _dataTablePageIndex = -1; // Use a sentinel value for the data table page

  // Calculate the total number of pages (charts + data table)
  int get _numPages => _availableCharts.length + (_availableCharts.isNotEmpty ? 1 : 0);
  // Only add the data table page if there is at least one chart

  // Function to navigate to a specific page
  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If no growth data, show a message
    if (_availableCharts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Growth Chart Results'),
        ),
        body: const Center(
          child: Text('No growth data available to display charts.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Chart Results'),
        // Display the title of the currently visible page in the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              // Use _getCurrentPageTitle() here to handle both chart and data table titles
              _getCurrentPageTitle(),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Adjust color as needed
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _numPages, // Total number of pages (charts + data table)
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                if (index < _availableCharts.length) {
                  // This index corresponds to a chart page
                  final currentMeasurementMethod = _availableCharts[index];
                  final growthDataForThisChart = widget.organizedGrowthData[currentMeasurementMethod] ?? [];

                  // Build a CentileChart for the current measurement method
                  return CentileChart(
                    organizedCentileLines: widget.organizedCentileLines, // Pass the full centile data cache
                    measurementMethod: currentMeasurementMethod, // Pass the specific method for this page
                    sex: widget.sex, // Pass the fixed sex
                    growthDataForMethod: growthDataForThisChart, // Pass filtered growth data
                    dob: widget.dob, // Pass fixed DOB
                    gestationWeeks: widget.gestationWeeks, // Pass fixed gestation
                    gestationDays: widget.gestationDays,   // Pass fixed gestation
                  );
                } else {
                  // This index corresponds to the data table page (_numPages - 1)
                  // Build the ResultsDataTable
                  return ResultsDataTable(organizedGrowthData: widget.organizedGrowthData);
                }
              },
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
                      // Enable/disable based on whether the current page is the first chart page
                      onPressed: _currentPage > 0 ? () => _goToPage(0) : null,
                      child: const Text('Chart'),
                    ),
                    TextButton(
                      // Enable/disable based on whether the current page is the data table page
                      onPressed: _currentPage < _numPages - 1 ? () => _goToPage(_numPages - 1) : null,
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

