// Dart/flutter imports
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// RCPCH Imports
import '../definitions/enums.dart';
import './centile_chart.dart';
import './results_data_table.dart';
import '../classes/app_state.dart';
import '../widgets/enum_radio_group.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key, this.initialMeasurementMethod});

  final MeasurementMethod? initialMeasurementMethod;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

enum ResultsTab { height, weight, ofc, data }

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  AgeCorrectionMethod _ageCorrectionMethod = AgeCorrectionMethod.chronological;

  Widget buildPlaceholder(MeasurementMethod? method) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('No ${method?.name ?? ''} data yet.'),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Add measurement"),
        ),
      ],
    );
  }

  Widget buildChart(MeasurementMethod method, AppState appState) {
    if (!appState.organizedGrowthData.containsKey(method)) {
      return buildPlaceholder(method);
    }

    return CentileChart(
      organizedCentileLines: appState.organizedCentileLines,
      measurementMethod: method,
      sex: appState.sex!,
      growthDataForMethod: appState.organizedGrowthData[method]!,
      dob: appState.dob!,
      ageCorrectionMethod: _ageCorrectionMethod,
      gestationWeeks: appState.gestationWeeks,
      gestationDays: appState.gestationDays,
    );
  }

  Widget buildTab(ResultsTab tab, AppState appState) {
    switch (tab) {
      case ResultsTab.height:
        return buildChart(MeasurementMethod.height, appState);
      case ResultsTab.weight:
        return buildChart(MeasurementMethod.weight, appState);
      case ResultsTab.ofc:
        return buildChart(MeasurementMethod.ofc, appState);
      case ResultsTab.data:
        return ResultsDataTable(
          organizedGrowthData: appState.organizedGrowthData,
        );
    }
  }

  Tab buildTabLink(ResultsTab tab) {
    switch (tab) {
      case ResultsTab.height:
        return const Tab(text: 'Height');
      case ResultsTab.weight:
        return const Tab(text: 'Weight');
      case ResultsTab.ofc:
        return const Tab(text: 'Head Cm.');
      case ResultsTab.data:
        return const Tab(text: 'Table');
    }
  }

  ResultsTab getFirstTab(AppState appState) {
    var measurementMethod = MeasurementMethod.height;

    if (widget.initialMeasurementMethod != null &&
        appState.organizedGrowthData.containsKey(
          widget.initialMeasurementMethod,
        )) {
      measurementMethod = widget.initialMeasurementMethod!;
    }

    switch (measurementMethod) {
      case MeasurementMethod.weight:
        return ResultsTab.weight;
      case MeasurementMethod.ofc:
        return ResultsTab.ofc;
      case MeasurementMethod.height:
      default:
        return ResultsTab.height;
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
          child: Column(
            children: [
              Text('No growth data available to display charts.'),
              ElevatedButton(onPressed: null, child: Text("Add measurement")),
            ],
          ),
        ),
      );
    }

    var currentTab = ResultsTab.values.indexOf(getFirstTab(appState));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Growth Chart - ${appState.sex != null ? toBeginningOfSentenceCase(appState.sex!.name) : ''}',
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.display_settings),
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Column(
                    children: [
                      Text(
                        'Age correction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setDialogState) {
                              return EnumRadioGroup<AgeCorrectionMethod>(
                                groupValue: _ageCorrectionMethod,
                                itemsPerRow: 1,
                                onChanged: (value) {
                                  setState(() {
                                    _ageCorrectionMethod = value!;
                                  });
                                  setDialogState(
                                    () {},
                                  ); // Update the dialog state
                                },
                                values: AgeCorrectionMethod.values,
                                labelBuilder: (m) {
                                  return toBeginningOfSentenceCase(m.name);
                                },
                              );
                            },
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'OK'),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: DefaultTabController(
        length: ResultsTab.values.length,
        initialIndex: currentTab,
        child: Scaffold(
          body: TabBarView(
            children: [
              for (var tab in ResultsTab.values) buildTab(tab, appState),
            ],
          ),
          bottomNavigationBar: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (var tab in ResultsTab.values) buildTabLink(tab)],
          ),
        ),
      ),
    );
  }
}
