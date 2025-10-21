import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:digital_growth_charts_app/definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../services/centile_chart_data_utils.dart';
import '../services/digital_growth_charts_services.dart';

class AppState with ChangeNotifier {
  DateTime? _dob;
  Sex? _sex;

  int? _gestationWeeks;
  int? _gestationDays;

  final Map<MeasurementMethod, List<GrowthDataResponse>> _organizedGrowthData = {};
  OrganizedCentileLines _organizedCentileLines = {Sex.male: {}, Sex.female: {}};

  final DigitalGrowthChartsService _dgcApi = DigitalGrowthChartsService();

  DateTime? get dob => _dob;
  Sex? get sex => _sex;
  int? get gestationWeeks => _gestationWeeks;
  int? get gestationDays => _gestationDays;

  get organizedGrowthData => _organizedGrowthData;
  get organizedCentileLines => _organizedCentileLines;

  set dob(DateTime? newDob) {
    _dob = newDob;
    notifyListeners();
  }

  set sex(Sex? newSex) {
    _sex = newSex;
    notifyListeners();
  }

  set gestationWeeks(int? newWeeks) {
    _gestationWeeks = newWeeks;
    notifyListeners();
  }

  set gestationDays(int? newDays) {
    _gestationDays = newDays;
    notifyListeners();
  }

  Future<void> addMeasurement({
    required String observationDate,
    required MeasurementMethod method,
    required String value
  }) async {
    if (_dob == null || _sex == null || _gestationWeeks == null || _gestationDays == null) {
      throw Exception('Missing demographics in app state');
    }

    print("_dgcApi: $_dgcApi");

    // Exception handling is the responsibility of the caller for now
    final apiResponse = await _dgcApi.submitGrowthData(
      birthDate: DateFormat('yyyy-MM-dd').format(_dob!),
      observationDate: observationDate,
      sex: _sex!,
      gestationWeeks: _gestationWeeks!,
      gestationDays: _gestationDays!,
      measurementMethod: method,
      observationValue: value
    );

    _organizedGrowthData.update(
      method,
      (list) => list..add(apiResponse),
      ifAbsent: () => [apiResponse],
    );

    final bool isCentileDataCached = _organizedCentileLines[_sex!]?.containsKey(method) ?? false;

    if (!isCentileDataCached) {
      final apiResponse = await _dgcApi.getChartCoordinates(
        sex: _sex!,
        measurementMethod: method
      );

      // Process and merge the new centile data into the organized map
      if (apiResponse.centileData != null) {
        final newOrganizedData = organizeCentileLines(apiResponse);
        // Merge new data. Prioritize new data for the same sex and measurement method
        if (newOrganizedData[_sex!]?.containsKey(method) ?? false) {
          _organizedCentileLines[_sex!]![method] = newOrganizedData[_sex!]![method]!;
        }
      }
    }

    notifyListeners();
  }

  void reset() {
    _dob = null;
    _sex = null;
    _gestationWeeks = null;
    _gestationDays = null;
    _organizedGrowthData.clear();
    _organizedCentileLines = {Sex.male: {}, Sex.female: {}};

    notifyListeners();
  }
}