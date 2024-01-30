// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ApiError {
  String get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) generic,
    required TResult Function(String field0) sessionError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? generic,
    TResult? Function(String field0)? sessionError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? generic,
    TResult Function(String field0)? sessionError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiError_Generic value) generic,
    required TResult Function(ApiError_SessionError value) sessionError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiError_Generic value)? generic,
    TResult? Function(ApiError_SessionError value)? sessionError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiError_Generic value)? generic,
    TResult Function(ApiError_SessionError value)? sessionError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ApiErrorCopyWith<ApiError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiErrorCopyWith<$Res> {
  factory $ApiErrorCopyWith(ApiError value, $Res Function(ApiError) then) =
      _$ApiErrorCopyWithImpl<$Res, ApiError>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$ApiErrorCopyWithImpl<$Res, $Val extends ApiError>
    implements $ApiErrorCopyWith<$Res> {
  _$ApiErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_value.copyWith(
      field0: null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApiError_GenericImplCopyWith<$Res>
    implements $ApiErrorCopyWith<$Res> {
  factory _$$ApiError_GenericImplCopyWith(_$ApiError_GenericImpl value,
          $Res Function(_$ApiError_GenericImpl) then) =
      __$$ApiError_GenericImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$ApiError_GenericImplCopyWithImpl<$Res>
    extends _$ApiErrorCopyWithImpl<$Res, _$ApiError_GenericImpl>
    implements _$$ApiError_GenericImplCopyWith<$Res> {
  __$$ApiError_GenericImplCopyWithImpl(_$ApiError_GenericImpl _value,
      $Res Function(_$ApiError_GenericImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ApiError_GenericImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ApiError_GenericImpl implements ApiError_Generic {
  const _$ApiError_GenericImpl(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'ApiError.generic(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiError_GenericImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiError_GenericImplCopyWith<_$ApiError_GenericImpl> get copyWith =>
      __$$ApiError_GenericImplCopyWithImpl<_$ApiError_GenericImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) generic,
    required TResult Function(String field0) sessionError,
  }) {
    return generic(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? generic,
    TResult? Function(String field0)? sessionError,
  }) {
    return generic?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? generic,
    TResult Function(String field0)? sessionError,
    required TResult orElse(),
  }) {
    if (generic != null) {
      return generic(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiError_Generic value) generic,
    required TResult Function(ApiError_SessionError value) sessionError,
  }) {
    return generic(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiError_Generic value)? generic,
    TResult? Function(ApiError_SessionError value)? sessionError,
  }) {
    return generic?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiError_Generic value)? generic,
    TResult Function(ApiError_SessionError value)? sessionError,
    required TResult orElse(),
  }) {
    if (generic != null) {
      return generic(this);
    }
    return orElse();
  }
}

abstract class ApiError_Generic implements ApiError {
  const factory ApiError_Generic(final String field0) = _$ApiError_GenericImpl;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$ApiError_GenericImplCopyWith<_$ApiError_GenericImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ApiError_SessionErrorImplCopyWith<$Res>
    implements $ApiErrorCopyWith<$Res> {
  factory _$$ApiError_SessionErrorImplCopyWith(
          _$ApiError_SessionErrorImpl value,
          $Res Function(_$ApiError_SessionErrorImpl) then) =
      __$$ApiError_SessionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$ApiError_SessionErrorImplCopyWithImpl<$Res>
    extends _$ApiErrorCopyWithImpl<$Res, _$ApiError_SessionErrorImpl>
    implements _$$ApiError_SessionErrorImplCopyWith<$Res> {
  __$$ApiError_SessionErrorImplCopyWithImpl(_$ApiError_SessionErrorImpl _value,
      $Res Function(_$ApiError_SessionErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field0 = null,
  }) {
    return _then(_$ApiError_SessionErrorImpl(
      null == field0
          ? _value.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ApiError_SessionErrorImpl implements ApiError_SessionError {
  const _$ApiError_SessionErrorImpl(this.field0);

  @override
  final String field0;

  @override
  String toString() {
    return 'ApiError.sessionError(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiError_SessionErrorImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiError_SessionErrorImplCopyWith<_$ApiError_SessionErrorImpl>
      get copyWith => __$$ApiError_SessionErrorImplCopyWithImpl<
          _$ApiError_SessionErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) generic,
    required TResult Function(String field0) sessionError,
  }) {
    return sessionError(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? generic,
    TResult? Function(String field0)? sessionError,
  }) {
    return sessionError?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? generic,
    TResult Function(String field0)? sessionError,
    required TResult orElse(),
  }) {
    if (sessionError != null) {
      return sessionError(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ApiError_Generic value) generic,
    required TResult Function(ApiError_SessionError value) sessionError,
  }) {
    return sessionError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ApiError_Generic value)? generic,
    TResult? Function(ApiError_SessionError value)? sessionError,
  }) {
    return sessionError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ApiError_Generic value)? generic,
    TResult Function(ApiError_SessionError value)? sessionError,
    required TResult orElse(),
  }) {
    if (sessionError != null) {
      return sessionError(this);
    }
    return orElse();
  }
}

abstract class ApiError_SessionError implements ApiError {
  const factory ApiError_SessionError(final String field0) =
      _$ApiError_SessionErrorImpl;

  @override
  String get field0;
  @override
  @JsonKey(ignore: true)
  _$$ApiError_SessionErrorImplCopyWith<_$ApiError_SessionErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
