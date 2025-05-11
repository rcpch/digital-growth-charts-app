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

class ResultsPage extends StatefulWidget {
  final GrowthDataResponse growthData;
  final DigitalGrowthChartsCentileLines chartData;
  final Sex sex;
  final MeasurementMethod measurementMethod;

  const ResultsPage({
    Key? key,
    required this.growthData,
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
                ),
                // Second Page: Result TextSpans
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour),
                      const SizedBox(height: 8),
                      Text(
                        'Ages',
                        style: TextStyle(color: secondaryColour, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _buildRichText('Date of Birth: ', '${widget.growthData.birthData?.birthDate ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Measurement Date: ', '${widget.growthData.measurementDates?.observationDate ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Chronological Age: ', '${widget.growthData.measurementDates?.chronologicalCalendarAge ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText(
                          'Corrected Age: ',
                          '${widget.growthData.measurementDates?.correctedCalendarAge ?? 'N/A'} (${widget.growthData.measurementDates?.comments?.clinicianCorrectedDecimalAgeComment})'),
                      const SizedBox(height: 16),
                      const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour),
                      const SizedBox(height: 8),
                      Text(
                        'Measurements',
                        style: TextStyle(
                          color: secondaryColour,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRichText('${widget.growthData.childObservationValue?.measurementMethod ?? 'N/A'}: ',
                          '${widget.growthData.childObservationValue?.observationValue ?? 'N/A'}'),
                      const SizedBox(height: 16),
                      const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour),
                      const SizedBox(height: 8),
                      Text(
                        'Sex',
                        style: TextStyle(
                          color: secondaryColour,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRichText('Sex: ', '${widget.growthData.birthData?.sex ?? 'N/A'}'),
                      const SizedBox(height: 16),
                      const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour),
                      const SizedBox(height: 8),
                      Text(
                        'Centiles/SDS',
                        style: TextStyle(
                          color: secondaryColour,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRichText('Chronological Centile: ', '${widget.growthData.measurementCalculatedValues?.chronologicalCentile ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Chronological SDS: ', '${widget.growthData.measurementCalculatedValues?.chronologicalSds ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Corrected Centile: ', '${widget.growthData.measurementCalculatedValues?.correctedCentile ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Interpretation: ', '${widget.growthData.measurementCalculatedValues?.correctedCentileBand ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      _buildRichText('Corrected SDS: ', '${widget.growthData.measurementCalculatedValues?.correctedSds ?? 'N/A'}'),
                    ],
                  ),
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

  RichText _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 16,
        ),
        children: <TextSpan>[
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }
}

List<List<Map<double, double>>> _prepareChartData(
    List<ReferenceData> allReferenceData,
    MeasurementMethod method,
    Sex sex,) {
  List<List<Map<double, double>>> allLinesData = [];

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
          List<Map<double, double>> lineData = [];
          if (centileDataPoint.data != null) {
            for (final dataPoint in centileDataPoint.data!) {
              if (dataPoint.x != null && dataPoint.y != null) {
                lineData.add({dataPoint.x!: dataPoint.y!});
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