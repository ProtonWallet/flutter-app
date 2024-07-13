import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ramp.countries.model.g.dart';

@JsonSerializable()
class RampCountry {
  final String code;
  final String name;
  final bool cardPaymentsEnabled;
  final String mainCurrencyCode;
  final List<String>? supportedAssets;
  final List<String>? apiV3SupportedAssets;

  RampCountry({
    required this.code,
    required this.name,
    required this.cardPaymentsEnabled,
    required this.mainCurrencyCode,
    required this.supportedAssets,
    required this.apiV3SupportedAssets,
  });

  /// Connect the generated [_$RampCountryFromJson] function to the `fromJson`
  /// factory.
  factory RampCountry.fromJson(Map<String, dynamic> json) =>
      _$RampCountryFromJson(json);

  /// Connect the generated [_$RampCountryToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RampCountryToJson(this);

  /// Handling a list of ProtonFeedItem instances
  static List<RampCountry> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RampCountry.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<RampCountry> items) {
    return items.map((item) => item.toJson()).toList();
  }

  static Future<List<RampCountry>> loadJsonFromAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/json/ramp_countries.json');
    final decodedJsonList = json.decode(jsonString) as List<dynamic>;
    return fromJsonList(decodedJsonList);
  }
}
