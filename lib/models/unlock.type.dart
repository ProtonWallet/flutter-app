import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unlock.type.g.dart';

enum UnlockType {
  @JsonValue('none')
  none,
  @JsonValue('biometrics')
  biometrics,
}

extension UnlockTypeExtension on UnlockType {
  String enumToString() {
    switch (this) {
      case UnlockType.none:
        return 'None';
      case UnlockType.biometrics:
        return 'Biometrics';
    }
  }
}

@JsonSerializable()
class UnlockModel {
  final UnlockType type;
  final String value;

  UnlockModel({required this.type, this.value = ""});

  factory UnlockModel.fromJson(Map<String, dynamic> json) =>
      _$UnlockModelFromJson(json);
  Map<String, dynamic> toJson() => _$UnlockModelToJson(this);
  factory UnlockModel.fromJsonString(String jsonString) =>
      UnlockModel.fromJson(jsonDecode(jsonString));
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class UnlockErrorCount {
  final int count;

  UnlockErrorCount({required this.count});

  factory UnlockErrorCount.fromJson(Map<String, dynamic> json) =>
      _$UnlockErrorCountFromJson(json);
  Map<String, dynamic> toJson() => _$UnlockErrorCountToJson(this);
  factory UnlockErrorCount.fromJsonString(String jsonString) =>
      UnlockErrorCount.fromJson(jsonDecode(jsonString));
  @override
  String toString() {
    return jsonEncode(toJson());
  }

  UnlockErrorCount plus() {
    return UnlockErrorCount(count: count + 1);
  }

  factory UnlockErrorCount.zero() => UnlockErrorCount(count: 0);
}
