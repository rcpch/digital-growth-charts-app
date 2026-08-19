// package and library imports
import 'package:digital_growth_charts_app/services/device_id.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

// RCPCH imports
import '/classes/app_config.dart';
import '/classes/digital_growth_charts_api_response.dart';
import '/classes/digital_growth_charts_chart_coordinates_response.dart';
import '/classes/log_levels.dart';
import '../definitions/enums.dart';

class DigitalGrowthChartsService {
  final String _baseUrl = AppConfig.apiUrl;
  final String _apiKey = AppConfig.apiKey;

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
        requestBody['bmi'] = double.tryParse(
          observationValue,
        ); // Adjust key if needed
        break;
    }

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Subscription-Key': _apiKey,
          'X-Device-Id': await getHashedDeviceId() ?? 'unknown',
        },
        body: jsonEncode(requestBody), // Encode the Map to a JSON string
      );

      if (response.statusCode == 200) {
        // API call successful, parse the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return GrowthDataResponse.fromJson(responseData);
      } else {
        // API call failed
        final String descriptiveErrorMessage = parseApiError(
          response.body,
          response.statusCode,
        );
        throw Exception('${response.statusCode}: $descriptiveErrorMessage');
      }
    } catch (e) {
      // Handle any exceptions during the API call (e.g., network errors)
      developer.log(
        'Error submitting growth data: $e',
        level: LogLevel.warning,
        name: 'DigitalGrowthChartsService',
        error: e,
        stackTrace: StackTrace.current,
      );

      rethrow; // Rethrow the exception to be handled by the caller
    }
  }

  //   chart coordinates endpoint
  Future<DigitalGrowthChartsCentileLines> getChartCoordinates({
    required Sex sex,
    required MeasurementMethod measurementMethod,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/uk-who/chart-coordinates',
    ); // Adjust the endpoint if needed
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
        developer.log(
          'Failed to load chart coordinates: ${response.statusCode}',
          level: LogLevel.warning,
          name: 'DigitalGrowthChartsService',
          error: response.body,
          stackTrace: StackTrace.current,
        );
        throw Exception(
          'Failed to load chart coordinates: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Error fetching chart coordinates: $e',
        level: LogLevel.severe,
        name: 'DigitalGrowthChartsService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  Future<List<GrowthDataResponse>> generateFictionalChildData({
    required int gestationWeeks,
    required int gestationDays,
    required Sex sex,
    required double startChronologicalAge,
    required double endAge,
    required double measurementIntervalNumber,
    required String measurementIntervalType,
    required MeasurementMethod measurementMethod,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/uk-who/fictional-child-data',
    ); // Adjust the endpoint if needed
    final String measurementMethodString = measurementMethod.name;
    final String sexString = sex.name;

    final Map<String, dynamic> requestBody = {
      'gestation_weeks': gestationWeeks,
      'gestation_days': gestationDays,
      'sex': sexString,
      'start_chronological_age': startChronologicalAge,
      'end_age': endAge,
      'measurement_interval_number': measurementIntervalNumber,
      'measurement_interval_type': measurementIntervalType,
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
        final List<dynamic> responseData = jsonDecode(response.body);

        return responseData.map((item) => GrowthDataResponse.fromJson(item))
            .toList();
      } else {
        developer.log(
          'Failed to generate fictional child data: ${response.statusCode}',
          level: LogLevel.warning,
          name: 'DigitalGrowthChartsService',
          error: response.body,
          stackTrace: StackTrace.current,
        );
        throw Exception(
          'Failed to generate fictional child data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      developer.log(
        'Error generating fictional child data: $e',
        level: LogLevel.severe,
        name: 'DigitalGrowthChartsService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  String parseApiError(String responseBody, int statusCode) {
    try {
      if (responseBody.isEmpty) {
        return 'API Error: Status Code $statusCode (No response body)';
      }

      final Map<String, dynamic> errorJson = jsonDecode(responseBody);

      if (errorJson.containsKey('detail') && errorJson['detail'] is List) {
        final List<dynamic> detailList = errorJson['detail'] as List<dynamic>;
        if (detailList.isNotEmpty) {
          final firstErrorObject = detailList[0];
          if (firstErrorObject is Map<String, dynamic> &&
              firstErrorObject.containsKey('msg')) {
            // Successfully extracted the specific message
            return firstErrorObject['msg'].toString(); // Ensure it's a string
          }
        }
      }
      // If the specific 'msg' isn't found in the expected structure,
      // return a more generic message including the status code and a hint of the body.
      // You might want to truncate responseBody if it's too long for an exception message.
      String truncatedBody = responseBody.length > 100
          ? '${responseBody.substring(0, 100)}...'
          : responseBody;
      return 'API Error ($statusCode): Unexpected error format. Response: $truncatedBody';
    } catch (e) {
      // If JSON decoding fails or any other error during parsing
      String truncatedBody = responseBody.length > 100
          ? '${responseBody.substring(0, 100)}...'
          : responseBody;
      return 'API Error ($statusCode): Could not parse error response. Raw response: $truncatedBody';
    }
  }
}
