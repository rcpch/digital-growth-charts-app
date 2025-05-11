// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_growth_charts_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthDataResponse _$GrowthDataResponseFromJson(Map<String, dynamic> json) =>
    GrowthDataResponse(
      birthData:
          json['birth_data'] == null
              ? null
              : BirthData.fromJson(json['birth_data'] as Map<String, dynamic>),
      measurementDates:
          json['measurement_dates'] == null
              ? null
              : MeasurementDates.fromJson(
                json['measurement_dates'] as Map<String, dynamic>,
              ),
      childObservationValue:
          json['child_observation_value'] == null
              ? null
              : ChildObservationValue.fromJson(
                json['child_observation_value'] as Map<String, dynamic>,
              ),
      measurementCalculatedValues:
          json['measurement_calculated_values'] == null
              ? null
              : MeasurementCalculatedValues.fromJson(
                json['measurement_calculated_values'] as Map<String, dynamic>,
              ),
      plottableData:
          json['plottable_data'] == null
              ? null
              : PlottableData.fromJson(
                json['plottable_data'] as Map<String, dynamic>,
              ),
      boneAge:
          json['bone_age'] == null
              ? null
              : BoneAge.fromJson(json['bone_age'] as Map<String, dynamic>),
      eventsData:
          json['events_data'] == null
              ? null
              : EventsData.fromJson(
                json['events_data'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$GrowthDataResponseToJson(GrowthDataResponse instance) =>
    <String, dynamic>{
      'birth_data': instance.birthData,
      'measurement_dates': instance.measurementDates,
      'child_observation_value': instance.childObservationValue,
      'measurement_calculated_values': instance.measurementCalculatedValues,
      'plottable_data': instance.plottableData,
      'bone_age': instance.boneAge,
      'events_data': instance.eventsData,
    };

BirthData _$BirthDataFromJson(Map<String, dynamic> json) => BirthData(
  birthDate: json['birth_date'] as String?,
  gestationWeeks: (json['gestation_weeks'] as num?)?.toInt(),
  gestationDays: (json['gestation_days'] as num?)?.toInt(),
  estimatedDateDelivery: json['estimated_date_delivery'] as String?,
  estimatedDateDeliveryString:
      json['estimated_date_delivery_string'] as String?,
  sex: json['sex'] as String?,
);

Map<String, dynamic> _$BirthDataToJson(BirthData instance) => <String, dynamic>{
  'birth_date': instance.birthDate,
  'gestation_weeks': instance.gestationWeeks,
  'gestation_days': instance.gestationDays,
  'estimated_date_delivery': instance.estimatedDateDelivery,
  'estimated_date_delivery_string': instance.estimatedDateDeliveryString,
  'sex': instance.sex,
};

MeasurementDates _$MeasurementDatesFromJson(Map<String, dynamic> json) =>
    MeasurementDates(
      observationDate: json['observation_date'] as String?,
      chronologicalDecimalAge:
          (json['chronological_decimal_age'] as num?)?.toDouble(),
      correctedDecimalAge: (json['corrected_decimal_age'] as num?)?.toDouble(),
      chronologicalCalendarAge: json['chronological_calendar_age'] as String?,
      correctedCalendarAge: json['corrected_calendar_age'] as String?,
      correctedGestationalAge:
          json['corrected_gestational_age'] == null
              ? null
              : CorrectedGestationalAge.fromJson(
                json['corrected_gestational_age'] as Map<String, dynamic>,
              ),
      comments:
          json['comments'] == null
              ? null
              : Comments.fromJson(json['comments'] as Map<String, dynamic>),
      correctedDecimalAgeError: json['corrected_decimal_age_error'] as String?,
      chronologicalDecimalAgeError:
          json['chronological_decimal_age_error'] as String?,
    );

Map<String, dynamic> _$MeasurementDatesToJson(MeasurementDates instance) =>
    <String, dynamic>{
      'observation_date': instance.observationDate,
      'chronological_decimal_age': instance.chronologicalDecimalAge,
      'corrected_decimal_age': instance.correctedDecimalAge,
      'chronological_calendar_age': instance.chronologicalCalendarAge,
      'corrected_calendar_age': instance.correctedCalendarAge,
      'corrected_gestational_age': instance.correctedGestationalAge,
      'comments': instance.comments,
      'corrected_decimal_age_error': instance.correctedDecimalAgeError,
      'chronological_decimal_age_error': instance.chronologicalDecimalAgeError,
    };

CorrectedGestationalAge _$CorrectedGestationalAgeFromJson(
  Map<String, dynamic> json,
) => CorrectedGestationalAge(
  correctedGestationWeeks: (json['corrected_gestation_weeks'] as num?)?.toInt(),
  correctedGestationDays: (json['corrected_gestation_days'] as num?)?.toInt(),
);

Map<String, dynamic> _$CorrectedGestationalAgeToJson(
  CorrectedGestationalAge instance,
) => <String, dynamic>{
  'corrected_gestation_weeks': instance.correctedGestationWeeks,
  'corrected_gestation_days': instance.correctedGestationDays,
};

Comments _$CommentsFromJson(Map<String, dynamic> json) => Comments(
  clinicianCorrectedDecimalAgeComment:
      json['clinician_corrected_decimal_age_comment'] as String?,
  layCorrectedDecimalAgeComment:
      json['lay_corrected_decimal_age_comment'] as String?,
  clinicianChronologicalDecimalAgeComment:
      json['clinician_chronological_decimal_age_comment'] as String?,
  layChronologicalDecimalAgeComment:
      json['lay_chronological_decimal_age_comment'] as String?,
);

Map<String, dynamic> _$CommentsToJson(Comments instance) => <String, dynamic>{
  'clinician_corrected_decimal_age_comment':
      instance.clinicianCorrectedDecimalAgeComment,
  'lay_corrected_decimal_age_comment': instance.layCorrectedDecimalAgeComment,
  'clinician_chronological_decimal_age_comment':
      instance.clinicianChronologicalDecimalAgeComment,
  'lay_chronological_decimal_age_comment':
      instance.layChronologicalDecimalAgeComment,
};

ChildObservationValue _$ChildObservationValueFromJson(
  Map<String, dynamic> json,
) => ChildObservationValue(
  measurementMethod: json['measurement_method'] as String?,
  observationValue: (json['observation_value'] as num?)?.toDouble(),
  observationValueError: json['observation_value_error'] as String?,
);

Map<String, dynamic> _$ChildObservationValueToJson(
  ChildObservationValue instance,
) => <String, dynamic>{
  'measurement_method': instance.measurementMethod,
  'observation_value': instance.observationValue,
  'observation_value_error': instance.observationValueError,
};

MeasurementCalculatedValues _$MeasurementCalculatedValuesFromJson(
  Map<String, dynamic> json,
) => MeasurementCalculatedValues(
  correctedSds: (json['corrected_sds'] as num?)?.toDouble(),
  correctedCentile: (json['corrected_centile'] as num?)?.toDouble(),
  correctedCentileBand: json['corrected_centile_band'] as String?,
  chronologicalSds: (json['chronological_sds'] as num?)?.toDouble(),
  chronologicalCentile: (json['chronological_centile'] as num?)?.toDouble(),
  chronologicalCentileBand: json['chronological_centile_band'] as String?,
  correctedMeasurementError: json['corrected_measurement_error'] as String?,
  chronologicalMeasurementError:
      json['chronological_measurement_error'] as String?,
  correctedPercentageMedianBmi:
      (json['corrected_percentage_median_bmi'] as num?)?.toDouble(),
  chronologicalPercentageMedianBmi:
      (json['chronological_percentage_median_bmi'] as num?)?.toDouble(),
);

Map<String, dynamic> _$MeasurementCalculatedValuesToJson(
  MeasurementCalculatedValues instance,
) => <String, dynamic>{
  'corrected_sds': instance.correctedSds,
  'corrected_centile': instance.correctedCentile,
  'corrected_centile_band': instance.correctedCentileBand,
  'chronological_sds': instance.chronologicalSds,
  'chronological_centile': instance.chronologicalCentile,
  'chronological_centile_band': instance.chronologicalCentileBand,
  'corrected_measurement_error': instance.correctedMeasurementError,
  'chronological_measurement_error': instance.chronologicalMeasurementError,
  'corrected_percentage_median_bmi': instance.correctedPercentageMedianBmi,
  'chronological_percentage_median_bmi':
      instance.chronologicalPercentageMedianBmi,
};

PlottableData _$PlottableDataFromJson(Map<String, dynamic> json) =>
    PlottableData(
      centileData:
          json['centile_data'] == null
              ? null
              : CentileData.fromJson(
                json['centile_data'] as Map<String, dynamic>,
              ),
      sdsData:
          json['sds_data'] == null
              ? null
              : SdsData.fromJson(json['sds_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlottableDataToJson(PlottableData instance) =>
    <String, dynamic>{
      'centile_data': instance.centileData,
      'sds_data': instance.sdsData,
    };

CentileData _$CentileDataFromJson(Map<String, dynamic> json) => CentileData(
  chronologicalDecimalAgeData:
      json['chronological_decimal_age_data'] == null
          ? null
          : PlottableDataEntry.fromJson(
            json['chronological_decimal_age_data'] as Map<String, dynamic>,
          ),
  correctedDecimalAgeData:
      json['corrected_decimal_age_data'] == null
          ? null
          : PlottableDataEntry.fromJson(
            json['corrected_decimal_age_data'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$CentileDataToJson(CentileData instance) =>
    <String, dynamic>{
      'chronological_decimal_age_data': instance.chronologicalDecimalAgeData,
      'corrected_decimal_age_data': instance.correctedDecimalAgeData,
    };

SdsData _$SdsDataFromJson(Map<String, dynamic> json) => SdsData(
  chronologicalDecimalAgeData:
      json['chronological_decimal_age_data'] == null
          ? null
          : PlottableDataEntry.fromJson(
            json['chronological_decimal_age_data'] as Map<String, dynamic>,
          ),
  correctedDecimalAgeData:
      json['corrected_decimal_age_data'] == null
          ? null
          : PlottableDataEntry.fromJson(
            json['corrected_decimal_age_data'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$SdsDataToJson(SdsData instance) => <String, dynamic>{
  'chronological_decimal_age_data': instance.chronologicalDecimalAgeData,
  'corrected_decimal_age_data': instance.correctedDecimalAgeData,
};

PlottableDataEntry _$PlottableDataEntryFromJson(Map<String, dynamic> json) =>
    PlottableDataEntry(
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      b: (json['b'] as num?)?.toDouble(),
      centile: (json['centile'] as num?)?.toDouble(),
      sds: (json['sds'] as num?)?.toDouble(),
      boneAgeLabel: json['bone_age_label'] as String?,
      eventsText: json['events_text'] as String?,
      boneAgeType: json['bone_age_type'] as String?,
      boneAgeSds: (json['bone_age_sds'] as num?)?.toDouble(),
      boneAgeCentile: (json['bone_age_centile'] as num?)?.toDouble(),
      observationError: json['observation_error'] as String?,
      ageType: json['age_type'] as String?,
      calendarAge: json['calendar_age'] as String?,
      correctedGestationalAge: json['corrected_gestational_age'] as String?,
      layComment: json['lay_comment'] as String?,
      clinicianComment: json['clinician_comment'] as String?,
      ageError: json['age_error'] as String?,
      centileBand: json['centile_band'] as String?,
      observationValueError: json['observation_value_error'] as String?,
    );

Map<String, dynamic> _$PlottableDataEntryToJson(PlottableDataEntry instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'b': instance.b,
      'centile': instance.centile,
      'sds': instance.sds,
      'bone_age_label': instance.boneAgeLabel,
      'events_text': instance.eventsText,
      'bone_age_type': instance.boneAgeType,
      'bone_age_sds': instance.boneAgeSds,
      'bone_age_centile': instance.boneAgeCentile,
      'observation_error': instance.observationError,
      'age_type': instance.ageType,
      'calendar_age': instance.calendarAge,
      'corrected_gestational_age': instance.correctedGestationalAge,
      'lay_comment': instance.layComment,
      'clinician_comment': instance.clinicianComment,
      'age_error': instance.ageError,
      'centile_band': instance.centileBand,
      'observation_value_error': instance.observationValueError,
    };

BoneAge _$BoneAgeFromJson(Map<String, dynamic> json) => BoneAge(
  boneAge: (json['bone_age'] as num?)?.toDouble(),
  boneAgeType: json['bone_age_type'] as String?,
  boneAgeSds: (json['bone_age_sds'] as num?)?.toDouble(),
  boneAgeCentile: (json['bone_age_centile'] as num?)?.toDouble(),
  boneAgeText: json['bone_age_text'] as String?,
);

Map<String, dynamic> _$BoneAgeToJson(BoneAge instance) => <String, dynamic>{
  'bone_age': instance.boneAge,
  'bone_age_type': instance.boneAgeType,
  'bone_age_sds': instance.boneAgeSds,
  'bone_age_centile': instance.boneAgeCentile,
  'bone_age_text': instance.boneAgeText,
};

EventsData _$EventsDataFromJson(Map<String, dynamic> json) =>
    EventsData(eventsText: json['events_text'] as String?);

Map<String, dynamic> _$EventsDataToJson(EventsData instance) =>
    <String, dynamic>{'events_text': instance.eventsText};
