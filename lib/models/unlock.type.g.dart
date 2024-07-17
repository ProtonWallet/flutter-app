// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock.type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockModel _$UnlockModelFromJson(Map<String, dynamic> json) => UnlockModel(
      type: $enumDecode(_$UnlockTypeEnumMap, json['type']),
      value: json['value'] as String? ?? "",
    );

Map<String, dynamic> _$UnlockModelToJson(UnlockModel instance) =>
    <String, dynamic>{
      'type': _$UnlockTypeEnumMap[instance.type]!,
      'value': instance.value,
    };

const _$UnlockTypeEnumMap = {
  UnlockType.none: 'none',
  UnlockType.biometrics: 'biometrics',
};

UnlockErrorCount _$UnlockErrorCountFromJson(Map<String, dynamic> json) =>
    UnlockErrorCount(
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$UnlockErrorCountToJson(UnlockErrorCount instance) =>
    <String, dynamic>{
      'count': instance.count,
    };
