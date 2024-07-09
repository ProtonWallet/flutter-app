// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirmation_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConfirmationTime {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int height, BigInt time) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int height, BigInt time)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int height, BigInt time)? confirmed,
    TResult Function(BigInt lastSeen)? unconfirmed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConfirmationTime_Confirmed value) confirmed,
    required TResult Function(ConfirmationTime_Unconfirmed value) unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult? Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfirmationTimeCopyWith<$Res> {
  factory $ConfirmationTimeCopyWith(
          ConfirmationTime value, $Res Function(ConfirmationTime) then) =
      _$ConfirmationTimeCopyWithImpl<$Res, ConfirmationTime>;
}

/// @nodoc
class _$ConfirmationTimeCopyWithImpl<$Res, $Val extends ConfirmationTime>
    implements $ConfirmationTimeCopyWith<$Res> {
  _$ConfirmationTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ConfirmationTime_ConfirmedImplCopyWith<$Res> {
  factory _$$ConfirmationTime_ConfirmedImplCopyWith(
          _$ConfirmationTime_ConfirmedImpl value,
          $Res Function(_$ConfirmationTime_ConfirmedImpl) then) =
      __$$ConfirmationTime_ConfirmedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int height, BigInt time});
}

/// @nodoc
class __$$ConfirmationTime_ConfirmedImplCopyWithImpl<$Res>
    extends _$ConfirmationTimeCopyWithImpl<$Res,
        _$ConfirmationTime_ConfirmedImpl>
    implements _$$ConfirmationTime_ConfirmedImplCopyWith<$Res> {
  __$$ConfirmationTime_ConfirmedImplCopyWithImpl(
      _$ConfirmationTime_ConfirmedImpl _value,
      $Res Function(_$ConfirmationTime_ConfirmedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? height = null,
    Object? time = null,
  }) {
    return _then(_$ConfirmationTime_ConfirmedImpl(
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$ConfirmationTime_ConfirmedImpl extends ConfirmationTime_Confirmed {
  const _$ConfirmationTime_ConfirmedImpl(
      {required this.height, required this.time})
      : super._();

  /// Confirmation height.
  @override
  final int height;

  /// Confirmation time in unix seconds.
  @override
  final BigInt time;

  @override
  String toString() {
    return 'ConfirmationTime.confirmed(height: $height, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfirmationTime_ConfirmedImpl &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.time, time) || other.time == time));
  }

  @override
  int get hashCode => Object.hash(runtimeType, height, time);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfirmationTime_ConfirmedImplCopyWith<_$ConfirmationTime_ConfirmedImpl>
      get copyWith => __$$ConfirmationTime_ConfirmedImplCopyWithImpl<
          _$ConfirmationTime_ConfirmedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int height, BigInt time) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) {
    return confirmed(height, time);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int height, BigInt time)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) {
    return confirmed?.call(height, time);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int height, BigInt time)? confirmed,
    TResult Function(BigInt lastSeen)? unconfirmed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(height, time);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConfirmationTime_Confirmed value) confirmed,
    required TResult Function(ConfirmationTime_Unconfirmed value) unconfirmed,
  }) {
    return confirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult? Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
  }) {
    return confirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(this);
    }
    return orElse();
  }
}

abstract class ConfirmationTime_Confirmed extends ConfirmationTime {
  const factory ConfirmationTime_Confirmed(
      {required final int height,
      required final BigInt time}) = _$ConfirmationTime_ConfirmedImpl;
  const ConfirmationTime_Confirmed._() : super._();

  /// Confirmation height.
  int get height;

  /// Confirmation time in unix seconds.
  BigInt get time;
  @JsonKey(ignore: true)
  _$$ConfirmationTime_ConfirmedImplCopyWith<_$ConfirmationTime_ConfirmedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ConfirmationTime_UnconfirmedImplCopyWith<$Res> {
  factory _$$ConfirmationTime_UnconfirmedImplCopyWith(
          _$ConfirmationTime_UnconfirmedImpl value,
          $Res Function(_$ConfirmationTime_UnconfirmedImpl) then) =
      __$$ConfirmationTime_UnconfirmedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt lastSeen});
}

/// @nodoc
class __$$ConfirmationTime_UnconfirmedImplCopyWithImpl<$Res>
    extends _$ConfirmationTimeCopyWithImpl<$Res,
        _$ConfirmationTime_UnconfirmedImpl>
    implements _$$ConfirmationTime_UnconfirmedImplCopyWith<$Res> {
  __$$ConfirmationTime_UnconfirmedImplCopyWithImpl(
      _$ConfirmationTime_UnconfirmedImpl _value,
      $Res Function(_$ConfirmationTime_UnconfirmedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastSeen = null,
  }) {
    return _then(_$ConfirmationTime_UnconfirmedImpl(
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$ConfirmationTime_UnconfirmedImpl extends ConfirmationTime_Unconfirmed {
  const _$ConfirmationTime_UnconfirmedImpl({required this.lastSeen})
      : super._();

  /// The last-seen timestamp in unix seconds.
  @override
  final BigInt lastSeen;

  @override
  String toString() {
    return 'ConfirmationTime.unconfirmed(lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfirmationTime_UnconfirmedImpl &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lastSeen);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfirmationTime_UnconfirmedImplCopyWith<
          _$ConfirmationTime_UnconfirmedImpl>
      get copyWith => __$$ConfirmationTime_UnconfirmedImplCopyWithImpl<
          _$ConfirmationTime_UnconfirmedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int height, BigInt time) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) {
    return unconfirmed(lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int height, BigInt time)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) {
    return unconfirmed?.call(lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int height, BigInt time)? confirmed,
    TResult Function(BigInt lastSeen)? unconfirmed,
    required TResult orElse(),
  }) {
    if (unconfirmed != null) {
      return unconfirmed(lastSeen);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ConfirmationTime_Confirmed value) confirmed,
    required TResult Function(ConfirmationTime_Unconfirmed value) unconfirmed,
  }) {
    return unconfirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult? Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
  }) {
    return unconfirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ConfirmationTime_Confirmed value)? confirmed,
    TResult Function(ConfirmationTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) {
    if (unconfirmed != null) {
      return unconfirmed(this);
    }
    return orElse();
  }
}

abstract class ConfirmationTime_Unconfirmed extends ConfirmationTime {
  const factory ConfirmationTime_Unconfirmed({required final BigInt lastSeen}) =
      _$ConfirmationTime_UnconfirmedImpl;
  const ConfirmationTime_Unconfirmed._() : super._();

  /// The last-seen timestamp in unix seconds.
  BigInt get lastSeen;
  @JsonKey(ignore: true)
  _$$ConfirmationTime_UnconfirmedImplCopyWith<
          _$ConfirmationTime_UnconfirmedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
