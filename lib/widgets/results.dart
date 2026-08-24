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
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

enum ResultsTab { data, height, weight, bmi, ofc }

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  AgeCorrectionMethod _ageCorrectionMethod = AgeCorrectionMethod.chronological;

  Widget buildPlaceholder(MeasurementMethod? method) {
    String placeholder;

    switch(method) {
      case MeasurementMethod.height:
        placeholder = 'No height data yet';
        break;
      case MeasurementMethod.weight:
        placeholder = 'No weight data yet';
        break;
      case MeasurementMethod.ofc:
        placeholder = 'No head circumference data yet';
        break;
      case MeasurementMethod.bmi:
        placeholder = 'No BMI data yet';
        break;
      default:
        placeholder = 'No measurement data yet';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(placeholder),
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
      ageCorrectionMethod: _effectiveAgeCorrectionMethod(appState),
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
      case ResultsTab.bmi:
        return buildChart(MeasurementMethod.bmi, appState);
      case ResultsTab.data:
        return ResultsDataTable(
          organizedGrowthData: appState.organizedGrowthData,
          ageCorrectionMethod: _effectiveAgeCorrectionMethod(appState),
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
      case ResultsTab.bmi:
        return const Tab(text: 'BMI');
      case ResultsTab.data:
        return const Tab(text: 'Table');
    }
  }

  /// The age-correction method actually applied to the charts and table.
  /// The toggle is only offered when gestation has been recorded; without it
  /// there is nothing to correct against, so we fall back to chronological.
  /// For term children the API returns identical chronological and corrected
  /// values, so honouring a "corrected" selection is a no-op rather than
  /// wrong — we don't override the user's choice.
  AgeCorrectionMethod _effectiveAgeCorrectionMethod(AppState appState) {
    if (appState.gestationWeeks != null && appState.gestationDays != null) {
      return _ageCorrectionMethod;
    }
    return AgeCorrectionMethod.chronological;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Growth Chart - ${appState.sex != null ? toBeginningOfSentenceCase(appState.sex!.name) : ''}',
        ),
        actions: <Widget>[
          if (appState.gestationWeeks != null && appState.gestationDays != null)
            IconButton(
              icon: const Icon(Icons.display_settings),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
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
                              (
                                BuildContext context,
                                StateSetter setDialogState,
                              ) {
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
      body: SafeArea(
        child: DefaultTabController(
          length: ResultsTab.values.length,
          initialIndex: 0,
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
      ),
    );
  }
}
