// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'digital_growth_charts_chart_coordinates_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DigitalGrowthChartsCentileLines _$DigitalGrowthChartsCentileLinesFromJson(
  Map<String, dynamic> json,
) => DigitalGrowthChartsCentileLines(
  centileData:
      (json['centile_data'] as List<dynamic>?)
          ?.map((e) => ReferenceData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$DigitalGrowthChartsCentileLinesToJson(
  DigitalGrowthChartsCentileLines instance,
) => <String, dynamic>{'centile_data': instance.centileData};

ReferenceData _$ReferenceDataFromJson(Map<String, dynamic> json) =>
    ReferenceData(
      ukWhoChild:
          json['uk_who_child'] == null
              ? null
              : SexMeasurementData.fromJson(
                json['uk_who_child'] as Map<String, dynamic>,
              ),
      uk90Child:
          json['uk90_child'] == null
              ? null
              : SexMeasurementData.fromJson(
                json['uk90_child'] as Map<String, dynamic>,
              ),
      ukWhoInfant:
          json['uk_who_infant'] == null
              ? null
              : SexMeasurementData.fromJson(
                json['uk_who_infant'] as Map<String, dynamic>,
              ),
      uk90Preterm:
          json['uk90_preterm'] == null
              ? null
              : SexMeasurementData.fromJson(
                json['uk90_preterm'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ReferenceDataToJson(ReferenceData instance) =>
    <String, dynamic>{
      'uk_who_child': instance.ukWhoChild,
      'uk90_child': instance.uk90Child,
      'uk_who_infant': instance.ukWhoInfant,
      'uk90_preterm': instance.uk90Preterm,
    };

SexMeasurementData _$SexMeasurementDataFromJson(Map<String, dynamic> json) =>
    SexMeasurementData(
      male:
          json['male'] == null
              ? null
              : MaleMeasurements.fromJson(json['male'] as Map<String, dynamic>),
      female:
          json['female'] == null
              ? null
              : FemaleMeasurements.fromJson(
                json['female'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$SexMeasurementDataToJson(SexMeasurementData instance) =>
    <String, dynamic>{'male': instance.male, 'female': instance.female};

MaleMeasurements _$MaleMeasurementsFromJson(Map<String, dynamic> json) =>
    MaleMeasurements(
      height:
          (json['height'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      weight:
          (json['weight'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      ofc:
          (json['ofc'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      bmi:
          (json['bmi'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MaleMeasurementsToJson(MaleMeasurements instance) =>
    <String, dynamic>{
      'height': instance.height,
      'weight': instance.weight,
      'ofc': instance.ofc,
      'bmi': instance.bmi,
    };

FemaleMeasurements _$FemaleMeasurementsFromJson(Map<String, dynamic> json) =>
    FemaleMeasurements(
      height:
          (json['height'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      weight:
          (json['weight'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      ofc:
          (json['ofc'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
      bmi:
          (json['bmi'] as List<dynamic>?)
              ?.map((e) => CentileDataPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$FemaleMeasurementsToJson(FemaleMeasurements instance) =>
    <String, dynamic>{
      'height': instance.height,
      'weight': instance.weight,
      'ofc': instance.ofc,
      'bmi': instance.bmi,
    };

CentileDataPoint _$CentileDataPointFromJson(Map<String, dynamic> json) =>
    CentileDataPoint(
      sds: (json['sds'] as num?)?.toDouble(),
      centile: (json['centile'] as num?)?.toDouble(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DataPointValue.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CentileDataPointToJson(CentileDataPoint instance) =>
    <String, dynamic>{
      'sds': instance.sds,
      'centile': instance.centile,
      'data': instance.data,
    };

DataPointValue _$DataPointValueFromJson(Map<String, dynamic> json) =>
    DataPointValue(
      l: (json['l'] as num?)?.toDouble(),
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DataPointValueToJson(DataPointValue instance) =>
    <String, dynamic>{'l': instance.l, 'x': instance.x, 'y': instance.y};
