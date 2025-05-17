// package and library imports
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// RCPCH imports
import '/classes/digital_growth_charts_api_response.dart';
import '/classes/digital_growth_charts_chart_coordinates_response.dart';
import '../definitions/enums.dart';

class DigitalGrowthChartsService {
  final String _baseUrl = dotenv.env['DGC_BASE_URL'] ?? '';
  final String _apiKey = dotenv.env['DGC_API_KEY'] ?? '';

  // calculation endpoint
  Future<GrowthDataResponse> submitGrowthData({
    required String birthDate,
    required String observationDate,
    required Sex sex,
    required MeasurementMethod measurementMethod,
    required String observationValue,
    required int gestationWeeks,
    required int gestationDays,
  }) async {
    final url = Uri.parse('$_baseUrl/uk-who/calculation');
    final String sexString = sex == Sex.male ? 'male' : 'female';
    final String measurementMethodString = measurementMethod.name;

    // Construct the request body as a Map
    final Map<String, dynamic> requestBody = {
      'birth_date': birthDate,
      'observation_date': observationDate,
      'sex': sexString,
      'measurement_method': measurementMethodString,
      'observation_value': observationValue,
      'gestation_weeks': gestationWeeks,
      'gestation_days': gestationDays,
    };

    switch (measurementMethod) {
      case MeasurementMethod.height:
        requestBody['height'] = double.tryParse(observationValue);
        break;
      case MeasurementMethod.weight:
        requestBody['weight'] = double.tryParse(observationValue);
        break;
      case MeasurementMethod.ofc:
        requestBody['ofc'] = double.tryParse(observationValue);
        break;
      case MeasurementMethod.bmi:
        requestBody['bmi'] = double.tryParse(observationValue); // Adjust key if needed
        break;
      default:
      // Handle unknown measurement type or throw an error
        throw Exception('Unknown measurement type: $measurementMethod');
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Subscription-Key': _apiKey,
        },
        body: jsonEncode(requestBody), // Encode the Map to a JSON string
      );

      if (response.statusCode == 200) {
        // API call successful, parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return GrowthDataResponse.fromJson(responseData);
      } else {
        // API call failed
        throw Exception('Failed to load growth data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions during the API call (e.g., network errors)
      print('Error submitting growth data: $e');
      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  //   chart coordinates endpoint
  Future<DigitalGrowthChartsCentileLines> getChartCoordinates({
    required Sex sex,
    required MeasurementMethod measurementMethod,
  }) async {
    final url = Uri.parse('$_baseUrl/uk-who/chart-coordinates'); // Adjust the endpoint if needed
    final String measurementMethodString = measurementMethod.name;
    final String sexString = sex.name;

    final Map<String, dynamic> requestBody = {
      'sex': sexString,
      'measurement_method': measurementMethodString,
    };

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Subscription-Key': _apiKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return DigitalGrowthChartsCentileLines.fromJson(responseData);
      } else {
        throw Exception('Failed to load chart coordinates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chart coordinates: $e');
      rethrow;
    }
  }
}