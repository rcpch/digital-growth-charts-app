import 'package:flutter/foundation.dart';
import 'package:digital_growth_charts_app/definitions/enums.dart';
import '../classes/digital_growth_charts_api_response.dart';
import '../classes/digital_growth_charts_chart_coordinates_response.dart';
import '../services/centile_chart_data_utils.dart';

class AppState with ChangeNotifier {
  DateTime? _dob;
  Sex? _sex;

  int? _gestationWeeks;
  int? _gestationDays;

  final Map<MeasurementMethod, List<GrowthDataResponse>> _organizedGrowthData = {};
  OrganizedCentileLines _organizedCentileLines = {Sex.male: {}, Sex.female: {}};

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

  void addGrowthDataResponse(MeasurementMethod method, GrowthDataResponse data) {
    if(_organizedGrowthData.containsKey(method)) {
      _organizedGrowthData[method]!.add(data);
    } else {
      _organizedGrowthData[method] = [data];
    }

    notifyListeners();
  }

  set organizedCentileLines(OrganizedCentileLines organizedCentileLines) {
    _organizedCentileLines = organizedCentileLines;

    notifyListeners();
  }
}