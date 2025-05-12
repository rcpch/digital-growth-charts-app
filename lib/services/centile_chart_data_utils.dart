import 'package:digital_growth_charts_app/definitions/enums.dart';
import 'package:digital_growth_charts_app/classes/digital_growth_charts_chart_coordinates_response.dart';

// Define a type for the organized chart data
// Map: Sex -> Map: MeasurementMethod -> List of CentileDataPoint
typedef OrganizedCentileLines = Map<Sex, Map<MeasurementMethod, List<CentileDataPoint>>>;

OrganizedCentileLines organizeCentileLines(DigitalGrowthChartsCentileLines centileLinesResponse) {
  final OrganizedCentileLines organizedData = {
    Sex.male: {
      MeasurementMethod.height: [],
      MeasurementMethod.weight: [],
      MeasurementMethod.ofc: [],
      MeasurementMethod.bmi: [],
    },
    Sex.female: {
      MeasurementMethod.height: [],
      MeasurementMethod.weight: [],
      MeasurementMethod.ofc: [],
      MeasurementMethod.bmi: [],
    },
  };

  final allReferenceData = centileLinesResponse.centileData;

  if (allReferenceData != null) {
    for (final referenceData in allReferenceData) {
      // Process each potential source of SexMeasurementData
      final sources = [
        referenceData.uk90Preterm,
        referenceData.ukWhoInfant,
        referenceData.ukWhoChild,
        referenceData.uk90Child,
      ];

      for (final sexMeasurementData in sources) {
        if (sexMeasurementData != null) {
          // Process male data if available
          if (sexMeasurementData.male != null) {
            // Check if data exists and add it to the list for the corresponding measurement method
            if (sexMeasurementData.male!.height != null) {
              organizedData[Sex.male]![MeasurementMethod.height]?.addAll(sexMeasurementData.male!.height!);
            }
            if (sexMeasurementData.male!.weight != null) {
              organizedData[Sex.male]![MeasurementMethod.weight]?.addAll(sexMeasurementData.male!.weight!);
            }
            if (sexMeasurementData.male!.ofc != null) {
              organizedData[Sex.male]![MeasurementMethod.ofc]?.addAll(sexMeasurementData.male!.ofc!);
            }
            if (sexMeasurementData.male!.bmi != null) {
              organizedData[Sex.male]![MeasurementMethod.bmi]?.addAll(sexMeasurementData.male!.bmi!);
            }
          }

          // Process female data if available
          if (sexMeasurementData.female != null) {
            // Check if data exists and add it to the list for the corresponding measurement method
            if (sexMeasurementData.female!.height != null) {
              organizedData[Sex.female]![MeasurementMethod.height]?.addAll(sexMeasurementData.female!.height!);
            }
            if (sexMeasurementData.female!.weight != null) {
              organizedData[Sex.female]![MeasurementMethod.weight]?.addAll(sexMeasurementData.female!.weight!);
            }
            if (sexMeasurementData.female!.ofc != null) {
              organizedData[Sex.female]![MeasurementMethod.ofc]?.addAll(sexMeasurementData.female!.ofc!);
            }
            if (sexMeasurementData.female!.bmi != null) {
              organizedData[Sex.female]![MeasurementMethod.bmi]?.addAll(sexMeasurementData.female!.bmi!);
            }
          }
        }
      }
    }
  }


  return organizedData;
}