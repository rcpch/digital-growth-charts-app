import 'package:digital_growth_charts_app/services/auth/auth_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../services/centile_chart_data_utils.dart';
import '../services/digital_growth_charts_services.dart';

class AppState with ChangeNotifier {
  final AuthProviderWrapper _authProviderWrapper = AuthProviderWrapper(
    AuthProvider(),
  );

  DateTime? _dob;
  Sex? _sex;

  int? _gestationWeeks;
  int? _gestationDays;

  final List<FeatureFlag> _featureFlags = [];

  final Map<MeasurementMethod, List<GrowthDataResponse>> _organizedGrowthData =
      {};
  final OrganizedCentileLines _organizedCentileLines = {
    Sex.male: {},
    Sex.female: {},
  };

  AuthData? _authData;

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

  AuthData? get authData => _authData;

  Future<void> _fetchCentileDataIfNeeded(MeasurementMethod method) async {
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
  }

  Future<void> addMeasurement({
    required String observationDate,
    required MeasurementMethod method,
    required String value,
  }) async {
    if (_dob == null || _sex == null) {
      throw Exception('Missing demographics in app state');
    }

    // Exception handling is the responsibility of the caller for now
    final futureApiResponse = _dgcApi.submitGrowthData(
      birthDate: DateFormat('yyyy-MM-dd').format(_dob!),
      observationDate: observationDate,
      sex: _sex!,
      gestationWeeks: _gestationWeeks,
      gestationDays: _gestationDays,
      measurementMethod: method,
      observationValue: value,
    );

    await _fetchCentileDataIfNeeded(method);

    final apiResponse = await futureApiResponse;

    _organizedGrowthData.update(
      method,
      (list) => list..add(apiResponse),
      ifAbsent: () => [apiResponse],
    );

    notifyListeners();
  }

  Future<void> generateFictionalData({
    required Sex sex,
    required double startChronologicalAge,
    required double endAge,
    required double measurementIntervalNumber,
    required String measurementIntervalType,
    int? gestationWeeks,
    int? gestationDays,
  }) async {
    final tasks =
        [
          MeasurementMethod.height,
          MeasurementMethod.weight,
          MeasurementMethod.ofc,
          MeasurementMethod.bmi,
        ].map((method) {
          return _dgcApi.generateFictionalChildData(
            gestationWeeks: gestationWeeks,
            gestationDays: gestationDays,
            sex: sex,
            startChronologicalAge: startChronologicalAge,
            endAge: endAge,
            measurementIntervalNumber: measurementIntervalNumber,
            measurementIntervalType: measurementIntervalType,
            measurementMethod: method,
          );
        });

    final [heightResponse, weightResponse, ofcResponse, bmiResponse] =
        await Future.wait(tasks);

    _sex = sex;
    _gestationWeeks = gestationWeeks;
    _gestationDays = gestationDays;

    final birthDateStr = heightResponse[0].birthData?.birthDate;
    if (birthDateStr == null) {
      throw Exception('Generated fictional data is missing birth_date');
    }
    _dob = DateFormat('yyyy-MM-dd').parse(birthDateStr);

    _organizedGrowthData.clear();
    _organizedGrowthData[MeasurementMethod.height] = heightResponse;
    _organizedGrowthData[MeasurementMethod.weight] = weightResponse;
    _organizedGrowthData[MeasurementMethod.ofc] = ofcResponse;
    _organizedGrowthData[MeasurementMethod.bmi] = bmiResponse;

    await Future.wait([
      _fetchCentileDataIfNeeded(MeasurementMethod.height),
      _fetchCentileDataIfNeeded(MeasurementMethod.weight),
      _fetchCentileDataIfNeeded(MeasurementMethod.ofc),
      _fetchCentileDataIfNeeded(MeasurementMethod.bmi),
    ]);

    notifyListeners();
  }

  Future<void> generateSingleSeriesOfFictionalData({
    required Sex sex,
    required double startChronologicalAge,
    required double endAge,
    required double measurementIntervalNumber,
    required String measurementIntervalType,
    required MeasurementMethod measurementMethod,
    int? gestationWeeks,
    int? gestationDays,
  }) async {
    final apiResponse = await _dgcApi.generateFictionalChildData(
      gestationWeeks: gestationWeeks,
      gestationDays: gestationDays,
      sex: sex,
      startChronologicalAge: startChronologicalAge,
      endAge: endAge,
      measurementIntervalNumber: measurementIntervalNumber,
      measurementIntervalType: measurementIntervalType,
      measurementMethod: measurementMethod,
    );

    _sex = sex;
    _gestationWeeks = gestationWeeks;
    _gestationDays = gestationDays;

    final birthDateStr = apiResponse[0].birthData?.birthDate;
    if (birthDateStr == null) {
      throw Exception('Generated fictional data is missing birth_date');
    }
    _dob = DateFormat('yyyy-MM-dd').parse(birthDateStr);

    _organizedGrowthData.clear();
    _organizedGrowthData[measurementMethod] = apiResponse;

    await _fetchCentileDataIfNeeded(measurementMethod);

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

  Future<void> loadAuthData() async {
    _authData = await _authProviderWrapper.load();
    if (_authData != null) {
      notifyListeners();
    }
  }

  Future<void> login() async {
    _authData = await _authProviderWrapper.login();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authProviderWrapper.logout();
    _authData = null;
    notifyListeners();
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
