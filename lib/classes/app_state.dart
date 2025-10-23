import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:digital_growth_charts_app/definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../services/centile_chart_data_utils.dart';
import '../services/digital_growth_charts_services.dart';

class AppState with ChangeNotifier {
  DateTime? _dob;
  Sex? _sex;

  int? _gestationWeeks;
  int? _gestationDays;

  List<FeatureFlag> _featureFlags = [];

  final Map<MeasurementMethod, List<GrowthDataResponse>> _organizedGrowthData =
      {};
  final OrganizedCentileLines _organizedCentileLines = {
    Sex.male: {},
    Sex.female: {},
  };

  final DigitalGrowthChartsService _dgcApi = DigitalGrowthChartsService();

  DateTime? get dob => _dob;
  Sex? get sex => _sex;
  int? get gestationWeeks => _gestationWeeks;
  int? get gestationDays => _gestationDays;

  Map<MeasurementMethod, List<GrowthDataResponse>> get organizedGrowthData =>
      _organizedGrowthData;
  OrganizedCentileLines get organizedCentileLines => _organizedCentileLines;

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
    required String value,
  }) async {
    if (_dob == null ||
        _sex == null ||
        _gestationWeeks == null ||
        _gestationDays == null) {
      throw Exception('Missing demographics in app state');
    }

    // Exception handling is the responsibility of the caller for now
    final futureApiResponse = _dgcApi.submitGrowthData(
      birthDate: DateFormat('yyyy-MM-dd').format(_dob!),
      observationDate: observationDate,
      sex: _sex!,
      gestationWeeks: _gestationWeeks!,
      gestationDays: _gestationDays!,
      measurementMethod: method,
      observationValue: value,
    );

    final bool isCentileDataCached =
        _organizedCentileLines[_sex!]?.containsKey(method) ?? false;

    if (!isCentileDataCached) {
      final apiResponse = await _dgcApi.getChartCoordinates(
        sex: _sex!,
        measurementMethod: method,
      );

      // Process and merge the new centile data into the organized map
      if (apiResponse.centileData != null) {
        final newOrganizedData = organizeCentileLines(apiResponse);
        // Merge new data. Prioritize new data for the same sex and measurement method
        if (newOrganizedData[_sex!]?.containsKey(method) ?? false) {
          _organizedCentileLines[_sex!]![method] =
              newOrganizedData[_sex!]![method]!;
        }
      }
    }

    final apiResponse = await futureApiResponse;

    _organizedGrowthData.update(
      method,
      (list) => list..add(apiResponse),
      ifAbsent: () => [apiResponse],
    );

    notifyListeners();
  }

  bool isFeatureFlagEnabled(FeatureFlag flag) {
    return _featureFlags.contains(flag);
  }

  void setFeatureFlag(FeatureFlag flag, bool isEnabled) {
    if (isEnabled) {
      if (!_featureFlags.contains(flag)) {
        _featureFlags.add(flag);
        notifyListeners();
      }
    } else {
      if (_featureFlags.contains(flag)) {
        _featureFlags.remove(flag);
        notifyListeners();
      }
    }
  }

  void reset() {
    _dob = null;
    _sex = null;
    _gestationWeeks = null;
    _gestationDays = null;
    _organizedGrowthData.clear();

    notifyListeners();
  }
}
