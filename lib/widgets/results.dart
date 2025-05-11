import 'package:flutter/material.dart';
import '../classes/digital_growth_charts_api_response.dart';

class ResultsPage extends StatelessWidget {
  final GrowthDataResponse growthData;

  const ResultsPage({Key? key, required this.growthData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here you will display the growthData information
    // For now, let's just show some basic info
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Chart Results'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date of Birth: ${growthData.birthData?.birthDate ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Clinic Date: ${growthData.measurementDates?.observationDate ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Chronological Age: ${growthData.measurementDates?.chronologicalCalendarAge ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Corrected Centile: ${growthData.measurementCalculatedValues?.correctedCentile ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Centile Band: ${growthData.measurementCalculatedValues?.correctedCentileBand ?? 'N/A'}'),
              // Add more Text widgets to display other data as needed
            ],
          ),
        ),
      ),
    );
  }
}