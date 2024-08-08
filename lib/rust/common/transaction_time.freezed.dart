// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TransactionTime {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt confirmationTime) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt confirmationTime)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt confirmationTime)? confirmed,
    TResult Function(BigInt lastSeen)? unconfirmed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TransactionTime_Confirmed value) confirmed,
    required TResult Function(TransactionTime_Unconfirmed value) unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TransactionTime_Confirmed value)? confirmed,
    TResult? Function(TransactionTime_Unconfirmed value)? unconfirmed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TransactionTime_Confirmed value)? confirmed,
    TResult Function(TransactionTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionTimeCopyWith<$Res> {
  factory $TransactionTimeCopyWith(
          TransactionTime value, $Res Function(TransactionTime) then) =
      _$TransactionTimeCopyWithImpl<$Res, TransactionTime>;
}

/// @nodoc
class _$TransactionTimeCopyWithImpl<$Res, $Val extends TransactionTime>
    implements $TransactionTimeCopyWith<$Res> {
  _$TransactionTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TransactionTime_ConfirmedImplCopyWith<$Res> {
  factory _$$TransactionTime_ConfirmedImplCopyWith(
          _$TransactionTime_ConfirmedImpl value,
          $Res Function(_$TransactionTime_ConfirmedImpl) then) =
      __$$TransactionTime_ConfirmedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt confirmationTime});
}

/// @nodoc
class __$$TransactionTime_ConfirmedImplCopyWithImpl<$Res>
    extends _$TransactionTimeCopyWithImpl<$Res, _$TransactionTime_ConfirmedImpl>
    implements _$$TransactionTime_ConfirmedImplCopyWith<$Res> {
  __$$TransactionTime_ConfirmedImplCopyWithImpl(
      _$TransactionTime_ConfirmedImpl _value,
      $Res Function(_$TransactionTime_ConfirmedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? confirmationTime = null,
  }) {
    return _then(_$TransactionTime_ConfirmedImpl(
      confirmationTime: null == confirmationTime
          ? _value.confirmationTime
          : confirmationTime // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$TransactionTime_ConfirmedImpl extends TransactionTime_Confirmed {
  const _$TransactionTime_ConfirmedImpl({required this.confirmationTime})
      : super._();

  @override
  final BigInt confirmationTime;

  @override
  String toString() {
    return 'TransactionTime.confirmed(confirmationTime: $confirmationTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionTime_ConfirmedImpl &&
            (identical(other.confirmationTime, confirmationTime) ||
                other.confirmationTime == confirmationTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, confirmationTime);

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionTime_ConfirmedImplCopyWith<_$TransactionTime_ConfirmedImpl>
      get copyWith => __$$TransactionTime_ConfirmedImplCopyWithImpl<
          _$TransactionTime_ConfirmedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt confirmationTime) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) {
    return confirmed(confirmationTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt confirmationTime)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) {
    return confirmed?.call(confirmationTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt confirmationTime)? confirmed,
    TResult Function(BigInt lastSeen)? unconfirmed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(confirmationTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TransactionTime_Confirmed value) confirmed,
    required TResult Function(TransactionTime_Unconfirmed value) unconfirmed,
  }) {
    return confirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TransactionTime_Confirmed value)? confirmed,
    TResult? Function(TransactionTime_Unconfirmed value)? unconfirmed,
  }) {
    return confirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TransactionTime_Confirmed value)? confirmed,
    TResult Function(TransactionTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) {
    if (confirmed != null) {
      return confirmed(this);
    }
    return orElse();
  }
}

abstract class TransactionTime_Confirmed extends TransactionTime {
  const factory TransactionTime_Confirmed(
          {required final BigInt confirmationTime}) =
      _$TransactionTime_ConfirmedImpl;
  const TransactionTime_Confirmed._() : super._();

  BigInt get confirmationTime;

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionTime_ConfirmedImplCopyWith<_$TransactionTime_ConfirmedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TransactionTime_UnconfirmedImplCopyWith<$Res> {
  factory _$$TransactionTime_UnconfirmedImplCopyWith(
          _$TransactionTime_UnconfirmedImpl value,
          $Res Function(_$TransactionTime_UnconfirmedImpl) then) =
      __$$TransactionTime_UnconfirmedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BigInt lastSeen});
}

/// @nodoc
class __$$TransactionTime_UnconfirmedImplCopyWithImpl<$Res>
    extends _$TransactionTimeCopyWithImpl<$Res,
        _$TransactionTime_UnconfirmedImpl>
    implements _$$TransactionTime_UnconfirmedImplCopyWith<$Res> {
  __$$TransactionTime_UnconfirmedImplCopyWithImpl(
      _$TransactionTime_UnconfirmedImpl _value,
      $Res Function(_$TransactionTime_UnconfirmedImpl) _then)
      : super(_value, _then);

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastSeen = null,
  }) {
    return _then(_$TransactionTime_UnconfirmedImpl(
      lastSeen: null == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as BigInt,
    ));
  }
}

/// @nodoc

class _$TransactionTime_UnconfirmedImpl extends TransactionTime_Unconfirmed {
  const _$TransactionTime_UnconfirmedImpl({required this.lastSeen}) : super._();

  @override
  final BigInt lastSeen;

  @override
  String toString() {
    return 'TransactionTime.unconfirmed(lastSeen: $lastSeen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionTime_UnconfirmedImpl &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lastSeen);

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionTime_UnconfirmedImplCopyWith<_$TransactionTime_UnconfirmedImpl>
      get copyWith => __$$TransactionTime_UnconfirmedImplCopyWithImpl<
          _$TransactionTime_UnconfirmedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BigInt confirmationTime) confirmed,
    required TResult Function(BigInt lastSeen) unconfirmed,
  }) {
    return unconfirmed(lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BigInt confirmationTime)? confirmed,
    TResult? Function(BigInt lastSeen)? unconfirmed,
  }) {
    return unconfirmed?.call(lastSeen);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BigInt confirmationTime)? confirmed,
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
    required TResult Function(TransactionTime_Confirmed value) confirmed,
    required TResult Function(TransactionTime_Unconfirmed value) unconfirmed,
  }) {
    return unconfirmed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TransactionTime_Confirmed value)? confirmed,
    TResult? Function(TransactionTime_Unconfirmed value)? unconfirmed,
  }) {
    return unconfirmed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TransactionTime_Confirmed value)? confirmed,
    TResult Function(TransactionTime_Unconfirmed value)? unconfirmed,
    required TResult orElse(),
  }) {
    if (unconfirmed != null) {
      return unconfirmed(this);
    }
    return orElse();
  }
}

abstract class TransactionTime_Unconfirmed extends TransactionTime {
  const factory TransactionTime_Unconfirmed({required final BigInt lastSeen}) =
      _$TransactionTime_UnconfirmedImpl;
  const TransactionTime_Unconfirmed._() : super._();

  BigInt get lastSeen;

  /// Create a copy of TransactionTime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionTime_UnconfirmedImplCopyWith<_$TransactionTime_UnconfirmedImpl>
      get copyWith => throw _privateConstructorUsedError;
}
