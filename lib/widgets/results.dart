import 'package:digital_growth_charts_app/themes/colours.dart';
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
              const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour),
              const SizedBox(height: 8),
              Text(
                'Ages',
                style: TextStyle(color: secondaryColour, fontSize: 16),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    // Default style for the whole RichText
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Date of Birth: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Make "Date of Birth: " bold
                      ),
                    ),
                    TextSpan(
                      text: '${growthData.birthData?.birthDate ?? 'N/A'}',
                      // This part inherits the default style (normal weight)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Measurement Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementDates?.observationDate ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Chronological Age: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementDates?.chronologicalCalendarAge ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Corrected Age: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementDates?.correctedCalendarAge ?? 'N/A'} (${growthData.measurementDates?.comments?.clinicianCorrectedDecimalAgeComment})',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 20, thickness: 5, indent: 0, endIndent: 0, color: primaryColour,),
              const SizedBox(height: 8),
              Text(
                'Measurements',
                style: TextStyle(
                  color: secondaryColour,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${growthData.childObservationValue?.measurementMethod ?? 'N/A'}: ', // Assuming measurementMethod should be part of the bold label
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.childObservationValue?.observationValue ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
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
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sex: ', // Adding a label for Sex
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.birthData?.sex ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
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
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Chronological Centile: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementCalculatedValues?.chronologicalCentile ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Chronological SDS: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementCalculatedValues?.chronologicalSds ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Corrected Centile: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementCalculatedValues?.correctedCentile ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Interpretation: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementCalculatedValues?.correctedCentileBand ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Corrected SDS: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${growthData.measurementCalculatedValues?.correctedSds ?? 'N/A'}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}