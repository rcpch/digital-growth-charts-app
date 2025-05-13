import 'package:flutter/material.dart';
import 'package:digital_growth_charts_app/themes/colours.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../definitions/enums.dart';

class ResultsDataTable extends StatelessWidget {
  // The list of API response objects
  final Map<MeasurementMethod, List<GrowthDataResponse>> organizedGrowthData;

  const ResultsDataTable({Key? key, required this.organizedGrowthData})
      : super(key: key);

  // Helper function to build RichText (can still be useful for other parts)
  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: primaryColour, // You might adjust the color here
          fontSize: 16,
        ),
        children: <TextSpan>[
          TextSpan(
            text: label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
          ),
        ],
      ),
    );
  }

  // Function to show the modal with detailed data
  void _showDetailsModal(BuildContext context, GrowthDataResponse growthData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detailed Growth Data'),
          content: SingleChildScrollView( // Added SingleChildScrollView here for modal content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: secondaryColour,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRichText('Chronological Age: ',
                    '${growthData.measurementDates?.chronologicalCalendarAge ??
                        'N/A'}'),
                const SizedBox(height: 8),
                _buildRichText('Corrected Age: ',
                    '${growthData.measurementDates?.correctedCalendarAge ??
                        'N/A'}'),
                const SizedBox(height: 8),
                _buildRichText('Corrected Age Comment: ',
                    '${growthData.measurementDates?.comments
                        ?.clinicianCorrectedDecimalAgeComment ?? ''}'),
                // Use empty string for comment if null
                const SizedBox(height: 16),
                Text(
                  'Calculated Measurements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: secondaryColour,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chronological',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColour,
                  ),
                ),
                const SizedBox(height: 4),
                _buildRichText('Centile: ',
                    '${growthData.measurementCalculatedValues
                        ?.chronologicalCentile ?? 'N/A'}'),
                const SizedBox(height: 8),
                _buildRichText('SDS: ',
                    '${growthData.measurementCalculatedValues
                        ?.chronologicalSds ?? 'N/A'}'),
                const SizedBox(height: 16),
                Text(
                  'Corrected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColour,
                  ),
                ),
                const SizedBox(height: 4),
                _buildRichText('Centile: ',
                    '${growthData.measurementCalculatedValues
                        ?.correctedCentile ?? 'N/A'}'),
                const SizedBox(height: 8),
                _buildRichText('Interpretation: ',
                    '${growthData.measurementCalculatedValues
                        ?.correctedCentileBand ?? 'N/A'}'),
                const SizedBox(height: 8),
                _buildRichText('SDS: ',
                    '${growthData.measurementCalculatedValues?.correctedSds ??
                        'N/A'}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Flatten the organizedGrowthData map into a single list of GrowthDataResponse objects.
    // We iterate through the values of the map (which are Lists of GrowthDataResponse)
    // and use expand to combine them into a single flat list.
    final List<GrowthDataResponse> allGrowthData = organizedGrowthData.values
        .expand((list) => list).toList();

    // Get the first growth data entry to display child information.
    // We assume child information like DOB and Sex is consistent across all entries.
    // Check if the list is not empty before trying to access the first element.
    final GrowthDataResponse? firstGrowthData = allGrowthData.isNotEmpty
        ? allGrowthData.first
        : null;

    // Handle the case where there's no data to display in the table.
    if (firstGrowthData == null) {
      // You might want to return a simple widget indicating no data,
      // NOT a full Scaffold here. The outer Scaffold in ResultsPage
      // will provide the app bar and overall structure.
      return const Center(
        child: Text('No growth data available to display.'),
      );
    }

    // If there is data, build the table view.
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Child Information separately at the top.
            const Divider(height: 20,
                thickness: 5,
                indent: 0,
                endIndent: 0,
                color: primaryColour),
            const SizedBox(height: 8),
            Text(
              'Child Information',
              style: TextStyle(color: secondaryColour, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildRichText('Date of Birth: ',
                '${firstGrowthData.birthData?.birthDate ?? 'N/A'}'),
            const SizedBox(height: 8),
            _buildRichText(
                'Sex: ', '${firstGrowthData.birthData?.sex ?? 'N/A'}'),
            const SizedBox(height: 16),
            const Divider(height: 20,
                thickness: 5,
                indent: 0,
                endIndent: 0,
                color: primaryColour),
            const SizedBox(height: 8),
            Text(
              'Measurement Data',
              style: TextStyle(color: secondaryColour, fontSize: 16,),
            ),
            const SizedBox(height: 8),
            // DataTable with reduced columns and expansion icon
            SingleChildScrollView( // Allows horizontal scrolling if columns are too wide
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      child: Text('Measurement Date',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text('Type',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text('Value',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text('Details',
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  ),
                ],
                // Generate DataRows from the flattened list of all growth data.
                rows: allGrowthData.map<DataRow>((growthData) {
                  return DataRow(
                    cells: <DataCell>[
                      // Display the observation date
                      DataCell(Text(
                          growthData.measurementDates?.observationDate ??
                              'N/A')),
                      // Display the measurement method type.
                      // Assuming measurementMethod in childObservationValue is a string or can be converted.
                      // If it's an enum, use .name or a mapping to get a display string.
                      DataCell(Text(
                          growthData.childObservationValue?.measurementMethod ??
                              'N/A')),
                      // Display the observed value
                      DataCell(Text('${growthData.childObservationValue
                          ?.observationValue ?? 'N/A'}')),
                      // DataCell with an IconButton to show detailed data modal
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.expand_more),
                          onPressed: () {
                            // Call the helper function to show the details modal for this specific data point
                            _showDetailsModal(context, growthData);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(), // Convert the mapped rows to a List<DataRow>
              ),
            ),
            const SizedBox(height: 16)
          ],
        )
    );
  }

}

