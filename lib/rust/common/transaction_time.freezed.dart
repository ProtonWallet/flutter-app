// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_time.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionTime {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionTime);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TransactionTime()';
}


}

/// @nodoc
class $TransactionTimeCopyWith<$Res>  {
$TransactionTimeCopyWith(TransactionTime _, $Res Function(TransactionTime) __);
}


/// Adds pattern-matching-related methods to [TransactionTime].
extension TransactionTimePatterns on TransactionTime {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TransactionTime_Confirmed value)?  confirmed,TResult Function( TransactionTime_Unconfirmed value)?  unconfirmed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TransactionTime_Confirmed() when confirmed != null:
return confirmed(_that);case TransactionTime_Unconfirmed() when unconfirmed != null:
return unconfirmed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TransactionTime_Confirmed value)  confirmed,required TResult Function( TransactionTime_Unconfirmed value)  unconfirmed,}){
final _that = this;
switch (_that) {
case TransactionTime_Confirmed():
return confirmed(_that);case TransactionTime_Unconfirmed():
return unconfirmed(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TransactionTime_Confirmed value)?  confirmed,TResult? Function( TransactionTime_Unconfirmed value)?  unconfirmed,}){
final _that = this;
switch (_that) {
case TransactionTime_Confirmed() when confirmed != null:
return confirmed(_that);case TransactionTime_Unconfirmed() when unconfirmed != null:
return unconfirmed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( BigInt confirmationTime)?  confirmed,TResult Function( BigInt lastSeen)?  unconfirmed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TransactionTime_Confirmed() when confirmed != null:
return confirmed(_that.confirmationTime);case TransactionTime_Unconfirmed() when unconfirmed != null:
return unconfirmed(_that.lastSeen);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( BigInt confirmationTime)  confirmed,required TResult Function( BigInt lastSeen)  unconfirmed,}) {final _that = this;
switch (_that) {
case TransactionTime_Confirmed():
return confirmed(_that.confirmationTime);case TransactionTime_Unconfirmed():
return unconfirmed(_that.lastSeen);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( BigInt confirmationTime)?  confirmed,TResult? Function( BigInt lastSeen)?  unconfirmed,}) {final _that = this;
switch (_that) {
case TransactionTime_Confirmed() when confirmed != null:
return confirmed(_that.confirmationTime);case TransactionTime_Unconfirmed() when unconfirmed != null:
return unconfirmed(_that.lastSeen);case _:
  return null;

}
}

}

/// @nodoc


class TransactionTime_Confirmed extends TransactionTime {
  const TransactionTime_Confirmed({required this.confirmationTime}): super._();
  

 final  BigInt confirmationTime;

/// Create a copy of TransactionTime
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionTime_ConfirmedCopyWith<TransactionTime_Confirmed> get copyWith => _$TransactionTime_ConfirmedCopyWithImpl<TransactionTime_Confirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionTime_Confirmed&&(identical(other.confirmationTime, confirmationTime) || other.confirmationTime == confirmationTime));
}


@override
int get hashCode => Object.hash(runtimeType,confirmationTime);

@override
String toString() {
  return 'TransactionTime.confirmed(confirmationTime: $confirmationTime)';
}


}

/// @nodoc
abstract mixin class $TransactionTime_ConfirmedCopyWith<$Res> implements $TransactionTimeCopyWith<$Res> {
  factory $TransactionTime_ConfirmedCopyWith(TransactionTime_Confirmed value, $Res Function(TransactionTime_Confirmed) _then) = _$TransactionTime_ConfirmedCopyWithImpl;
@useResult
$Res call({
 BigInt confirmationTime
});




}
/// @nodoc
class _$TransactionTime_ConfirmedCopyWithImpl<$Res>
    implements $TransactionTime_ConfirmedCopyWith<$Res> {
  _$TransactionTime_ConfirmedCopyWithImpl(this._self, this._then);

  final TransactionTime_Confirmed _self;
  final $Res Function(TransactionTime_Confirmed) _then;

/// Create a copy of TransactionTime
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? confirmationTime = null,}) {
  return _then(TransactionTime_Confirmed(
confirmationTime: null == confirmationTime ? _self.confirmationTime : confirmationTime // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

/// @nodoc


class TransactionTime_Unconfirmed extends TransactionTime {
  const TransactionTime_Unconfirmed({required this.lastSeen}): super._();
  

 final  BigInt lastSeen;

/// Create a copy of TransactionTime
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionTime_UnconfirmedCopyWith<TransactionTime_Unconfirmed> get copyWith => _$TransactionTime_UnconfirmedCopyWithImpl<TransactionTime_Unconfirmed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionTime_Unconfirmed&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen));
}


@override
int get hashCode => Object.hash(runtimeType,lastSeen);

@override
String toString() {
  return 'TransactionTime.unconfirmed(lastSeen: $lastSeen)';
}


}

/// @nodoc
abstract mixin class $TransactionTime_UnconfirmedCopyWith<$Res> implements $TransactionTimeCopyWith<$Res> {
  factory $TransactionTime_UnconfirmedCopyWith(TransactionTime_Unconfirmed value, $Res Function(TransactionTime_Unconfirmed) _then) = _$TransactionTime_UnconfirmedCopyWithImpl;
@useResult
$Res call({
 BigInt lastSeen
});




}
/// @nodoc
class _$TransactionTime_UnconfirmedCopyWithImpl<$Res>
    implements $TransactionTime_UnconfirmedCopyWith<$Res> {
  _$TransactionTime_UnconfirmedCopyWithImpl(this._self, this._then);

  final TransactionTime_Unconfirmed _self;
  final $Res Function(TransactionTime_Unconfirmed) _then;

/// Create a copy of TransactionTime
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? lastSeen = null,}) {
  return _then(TransactionTime_Unconfirmed(
lastSeen: null == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as BigInt,
  ));
}


}

// dart format on
