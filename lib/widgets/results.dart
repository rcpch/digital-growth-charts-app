// Dart/flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Third party imports
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// RCPCH Imports
import '../definitions/enums.dart';
import './centile_chart.dart';
import './results_data_table.dart';
import '../classes/app_state.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
    this.initialMeasurementMethod,
  });

  final MeasurementMethod? initialMeasurementMethod;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();

    var appState = context.read<AppState>();

    print("initialMeasurementMethod: ${widget.initialMeasurementMethod} data: ${appState.organizedGrowthData.keys}");

    if(widget.initialMeasurementMethod != null &&
       appState.organizedGrowthData.containsKey(widget.initialMeasurementMethod)) {
      // Start on the page for the specified measurement method
      var methodIndex = appState.organizedGrowthData.keys.toList().indexOf(widget.initialMeasurementMethod!);
      _currentPage = methodIndex;
      _pageController = PageController(initialPage: methodIndex);
    } else {
      // Default to the first chart page
      _currentPage = 0;
      
    }

    _pageController = PageController(initialPage: _currentPage);
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

  Widget _buildPageView(AppState appState) {
    var numPages = appState.organizedGrowthData.length + (appState.organizedGrowthData.isNotEmpty ? 1 : 0);

    return PageView.builder(
      key: const ValueKey('pageView'),
      controller: _pageController,
      itemCount: numPages,
      itemBuilder: (context, index) {
        if (index == numPages - 1 && numPages > 1) {
          // Last page is the data table
          return ResultsDataTable(
            key: const PageStorageKey('data_table'),
            organizedGrowthData: appState.organizedGrowthData,
          );
        } else if(appState.dob != null && appState.sex != null) {
          var method = appState.organizedGrowthData.keys.elementAt(index);

          return CentileChart(
            key: PageStorageKey('chart_$method'),
            organizedCentileLines: appState.organizedCentileLines,
            measurementMethod: method,
            sex: appState.sex!,
            growthDataForMethod: appState.organizedGrowthData[method]!,
            dob: appState.dob!,
            gestationWeeks: appState.gestationWeeks,
            gestationDays: appState.gestationDays,
          );
        }

        return const Center(
          child: Text('Cannot display chart. Missing date of birth or sex.'),
        );
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
    var appState = context.watch<AppState>();

    // If no growth data, show a message
    if (appState.organizedGrowthData.isEmpty) {
      // Changed from _pageViewChildren.isEmpty
      return Scaffold(
        appBar: AppBar(title: const Text('Growth Chart Results')),
        body: const Center(
          child: Text('No growth data available to display charts.'),
        ),
      );
    }

    // Calculate the total number of pages (charts + data table)
    int numPages = appState.organizedGrowthData.length + (appState.organizedGrowthData.isNotEmpty ? 1 : 0);
    // Only add the data table page if there is at least one chart

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Chart Results')),
      body: Column(
        children: [
          Expanded(child: _buildPageView(appState)),
          if (appState.organizedGrowthData.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: numPages,
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
                        onPressed: _currentPage < numPages - 1
                            ? () => _goToPage(numPages - 1)
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
