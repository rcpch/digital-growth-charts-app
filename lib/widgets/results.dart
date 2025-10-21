// Dart/flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Third party imports
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// RCPCH Imports
import '../classes/digital_growth_charts_api_response.dart';
import '../definitions/enums.dart';
import './centile_chart.dart';
import './results_data_table.dart';
import '../services/centile_chart_data_utils.dart';
import '../classes/app_state.dart';

class ResultsPage extends StatefulWidget {
  final Map<MeasurementMethod, List<GrowthDataResponse>> organizedGrowthData;
  final OrganizedCentileLines organizedCentileLines;

  final MeasurementMethod measurementMethod;

  const ResultsPage({
    super.key,
    required this.organizedGrowthData,
    required this.organizedCentileLines,
    required this.measurementMethod,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late PageController _pageController;
  int _currentPage = 0;
  // List of MeasurementMethods for which we have growth data
  List<MeasurementMethod> _availableCharts = [];
  // holds the actual pages
  // Add a page for the data table
  // Use a sentinel value for the data table page

  // Calculate the total number of pages (charts + data table)
  int get _numPages =>
      _availableCharts.length + (_availableCharts.isNotEmpty ? 1 : 0);
  // Only add the data table page if there is at least one chart

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _buildAvailableCharts(); // Changed from _buildPageViewChildren
  }

  @override
  void didUpdateWidget(covariant ResultsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool growthDataChanged =
        widget.organizedGrowthData != oldWidget.organizedGrowthData;

    if (growthDataChanged) {
      setState(() {
        _buildAvailableCharts(); // Changed from _buildPageViewChildren
        if (_currentPage >= _numPages) {
          _currentPage = _numPages - 1;
        }
      });
    }
  }

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

  void _buildAvailableCharts() {
    _availableCharts = widget.organizedGrowthData.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList();
  }

  Widget _buildPageViewItem(BuildContext context, int index) {
    // If it's the last page and we have charts, it's the data table
    if (index == _availableCharts.length && _availableCharts.isNotEmpty) {
      return ResultsDataTable(
        key: const PageStorageKey('data_table'),
        organizedGrowthData: widget.organizedGrowthData,
      );
    }

    // Otherwise it's a chart
    final method = _availableCharts[index];

    var appState = context.read<AppState>();

    if(appState.dob != null && appState.sex != null) {
      return CentileChart(
        key: PageStorageKey('chart_$method'),
        organizedCentileLines: widget.organizedCentileLines,
        measurementMethod: method,
        sex: appState.sex!,
        growthDataForMethod: widget.organizedGrowthData[method]!,
        dob: appState.dob!,
        gestationWeeks: appState.gestationWeeks,
        gestationDays: appState.gestationDays,
      );
    }

    return const Center(
      child: Text('Cannot display chart. Missing date of birth or sex.'),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      key: const ValueKey('pageView'),
      controller: _pageController,
      itemCount: _numPages,
      itemBuilder: (context, index) {
        return _buildPageViewItem(context, index);
      },
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no growth data, show a message
    if (_availableCharts.isEmpty) {
      // Changed from _pageViewChildren.isEmpty
      return Scaffold(
        appBar: AppBar(title: const Text('Growth Chart Results')),
        body: const Center(
          child: Text('No growth data available to display charts.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Chart Results')),
      body: Column(
        children: [
          Expanded(child: _buildPageView()),
          if (_availableCharts
              .isNotEmpty) // Changed from _pageViewChildren.isNotEmpty
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
                        onPressed: _currentPage < _numPages - 1
                            ? () => _goToPage(_numPages - 1)
                            : null,
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
