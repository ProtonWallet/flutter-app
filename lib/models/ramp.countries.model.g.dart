// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ramp.countries.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RampCountry _$RampCountryFromJson(Map<String, dynamic> json) => RampCountry(
      code: json['code'] as String,
      name: json['name'] as String,
      cardPaymentsEnabled: json['cardPaymentsEnabled'] as bool,
      mainCurrencyCode: json['mainCurrencyCode'] as String,
      supportedAssets: (json['supportedAssets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      apiV3SupportedAssets: (json['apiV3SupportedAssets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$RampCountryToJson(RampCountry instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'cardPaymentsEnabled': instance.cardPaymentsEnabled,
      'mainCurrencyCode': instance.mainCurrencyCode,
      'supportedAssets': instance.supportedAssets,
      'apiV3SupportedAssets': instance.apiV3SupportedAssets,
    };
