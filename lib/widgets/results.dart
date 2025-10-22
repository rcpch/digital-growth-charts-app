// Dart/flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// RCPCH Imports
import '../definitions/enums.dart';
import './centile_chart.dart';
import './results_data_table.dart';
import '../classes/app_state.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, this.initialMeasurementMethod});

  final MeasurementMethod? initialMeasurementMethod;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

enum ResultsTab {
  data,
  height,
  weight,
  ofc
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
  Widget buildChart(MeasurementMethod method, AppState appState) {
    if(!appState.organizedGrowthData.containsKey(method)) {
      return Center(child: Text("No growth data available"));
    }

    return CentileChart(
      organizedCentileLines: appState.organizedCentileLines,
      measurementMethod: method,
      sex: appState.sex!,
      growthDataForMethod: appState.organizedGrowthData[method]!,
      dob: appState.dob!,
      gestationWeeks: appState.gestationWeeks,
      gestationDays: appState.gestationDays,
    );
  }

  Widget buildTab(ResultsTab tab, AppState appState) {
    switch (tab) {
      case ResultsTab.data:
        return ResultsDataTable(
          organizedGrowthData: appState.organizedGrowthData,
        );
      case ResultsTab.height:
        return buildChart(MeasurementMethod.height, appState);
      case ResultsTab.weight:
        return buildChart(MeasurementMethod.weight, appState);
      case ResultsTab.ofc:
        return buildChart(MeasurementMethod.ofc, appState);
    }
  }

  Tab buildTabLink(ResultsTab tab) {
    switch (tab) {
      case ResultsTab.data:
        return const Tab(icon: Icon(Icons.child_care));
      case ResultsTab.height:
        return const Tab(text: 'Height');
      case ResultsTab.weight:
        return const Tab(text: 'Weight');
      case ResultsTab.ofc:
        return const Tab(text: 'Head Cm.');
    }
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

    // Default to the first tab with charts
    var currentTab = 1;

    if (widget.initialMeasurementMethod != null &&
        appState.organizedGrowthData.containsKey(
          widget.initialMeasurementMethod,
        )) {
      // Start on the tab for the specified measurement method
      final measurementMethodIndex = appState.organizedGrowthData.keys.toList().indexOf(
        widget.initialMeasurementMethod!,
      );
      
      currentTab = measurementMethodIndex + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Chart Results')),
      body: DefaultTabController(
        length: ResultsTab.values.length,
        initialIndex: currentTab,
        child: Scaffold(
          body: TabBarView(
            children: [for (var tab in ResultsTab.values) buildTab(tab, appState)]
          ),
          bottomNavigationBar: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (var tab in ResultsTab.values) buildTabLink(tab)]
          ),
        )
      )
    );
  }
}
