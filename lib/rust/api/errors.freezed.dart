// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'errors.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BridgeError {

 Object get field0;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError&&const DeepCollectionEquality().equals(other.field0, field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(field0));

@override
String toString() {
  return 'BridgeError(field0: $field0)';
}


}

/// @nodoc
class $BridgeErrorCopyWith<$Res>  {
$BridgeErrorCopyWith(BridgeError _, $Res Function(BridgeError) __);
}


/// Adds pattern-matching-related methods to [BridgeError].
extension BridgeErrorPatterns on BridgeError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( BridgeError_ApiLock value)?  apiLock,TResult Function( BridgeError_Generic value)?  generic,TResult Function( BridgeError_MuonAuthSession value)?  muonAuthSession,TResult Function( BridgeError_MuonAuthRefresh value)?  muonAuthRefresh,TResult Function( BridgeError_MuonClient value)?  muonClient,TResult Function( BridgeError_MuonSession value)?  muonSession,TResult Function( BridgeError_AndromedaBitcoin value)?  andromedaBitcoin,TResult Function( BridgeError_ApiResponse value)?  apiResponse,TResult Function( BridgeError_ApiDeserialize value)?  apiDeserialize,TResult Function( BridgeError_BitcoinDeserialize value)?  bitcoinDeserialize,TResult Function( BridgeError_ApiSrp value)?  apiSrp,TResult Function( BridgeError_AesGcm value)?  aesGcm,TResult Function( BridgeError_WalletCrypto value)?  walletCrypto,TResult Function( BridgeError_WalletDecryption value)?  walletDecryption,TResult Function( BridgeError_WalletFeature value)?  walletFeature,TResult Function( BridgeError_Login value)?  login,TResult Function( BridgeError_Fork value)?  fork,TResult Function( BridgeError_Database value)?  database,TResult Function( BridgeError_SessionStore value)?  sessionStore,TResult Function( BridgeError_Encoding value)?  encoding,TResult Function( BridgeError_InsufficientFundsInPaperWallet value)?  insufficientFundsInPaperWallet,TResult Function( BridgeError_InvalidPaperWallet value)?  invalidPaperWallet,TResult Function( BridgeError_FeaturesAndromedaBitcoinError value)?  featuresAndromedaBitcoinError,TResult Function( BridgeError_FeaturesAndromedaCommonError value)?  featuresAndromedaCommonError,TResult Function( BridgeError_AccountExportDatetimeError value)?  accountExportDatetimeError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case BridgeError_ApiLock() when apiLock != null:
return apiLock(_that);case BridgeError_Generic() when generic != null:
return generic(_that);case BridgeError_MuonAuthSession() when muonAuthSession != null:
return muonAuthSession(_that);case BridgeError_MuonAuthRefresh() when muonAuthRefresh != null:
return muonAuthRefresh(_that);case BridgeError_MuonClient() when muonClient != null:
return muonClient(_that);case BridgeError_MuonSession() when muonSession != null:
return muonSession(_that);case BridgeError_AndromedaBitcoin() when andromedaBitcoin != null:
return andromedaBitcoin(_that);case BridgeError_ApiResponse() when apiResponse != null:
return apiResponse(_that);case BridgeError_ApiDeserialize() when apiDeserialize != null:
return apiDeserialize(_that);case BridgeError_BitcoinDeserialize() when bitcoinDeserialize != null:
return bitcoinDeserialize(_that);case BridgeError_ApiSrp() when apiSrp != null:
return apiSrp(_that);case BridgeError_AesGcm() when aesGcm != null:
return aesGcm(_that);case BridgeError_WalletCrypto() when walletCrypto != null:
return walletCrypto(_that);case BridgeError_WalletDecryption() when walletDecryption != null:
return walletDecryption(_that);case BridgeError_WalletFeature() when walletFeature != null:
return walletFeature(_that);case BridgeError_Login() when login != null:
return login(_that);case BridgeError_Fork() when fork != null:
return fork(_that);case BridgeError_Database() when database != null:
return database(_that);case BridgeError_SessionStore() when sessionStore != null:
return sessionStore(_that);case BridgeError_Encoding() when encoding != null:
return encoding(_that);case BridgeError_InsufficientFundsInPaperWallet() when insufficientFundsInPaperWallet != null:
return insufficientFundsInPaperWallet(_that);case BridgeError_InvalidPaperWallet() when invalidPaperWallet != null:
return invalidPaperWallet(_that);case BridgeError_FeaturesAndromedaBitcoinError() when featuresAndromedaBitcoinError != null:
return featuresAndromedaBitcoinError(_that);case BridgeError_FeaturesAndromedaCommonError() when featuresAndromedaCommonError != null:
return featuresAndromedaCommonError(_that);case BridgeError_AccountExportDatetimeError() when accountExportDatetimeError != null:
return accountExportDatetimeError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( BridgeError_ApiLock value)  apiLock,required TResult Function( BridgeError_Generic value)  generic,required TResult Function( BridgeError_MuonAuthSession value)  muonAuthSession,required TResult Function( BridgeError_MuonAuthRefresh value)  muonAuthRefresh,required TResult Function( BridgeError_MuonClient value)  muonClient,required TResult Function( BridgeError_MuonSession value)  muonSession,required TResult Function( BridgeError_AndromedaBitcoin value)  andromedaBitcoin,required TResult Function( BridgeError_ApiResponse value)  apiResponse,required TResult Function( BridgeError_ApiDeserialize value)  apiDeserialize,required TResult Function( BridgeError_BitcoinDeserialize value)  bitcoinDeserialize,required TResult Function( BridgeError_ApiSrp value)  apiSrp,required TResult Function( BridgeError_AesGcm value)  aesGcm,required TResult Function( BridgeError_WalletCrypto value)  walletCrypto,required TResult Function( BridgeError_WalletDecryption value)  walletDecryption,required TResult Function( BridgeError_WalletFeature value)  walletFeature,required TResult Function( BridgeError_Login value)  login,required TResult Function( BridgeError_Fork value)  fork,required TResult Function( BridgeError_Database value)  database,required TResult Function( BridgeError_SessionStore value)  sessionStore,required TResult Function( BridgeError_Encoding value)  encoding,required TResult Function( BridgeError_InsufficientFundsInPaperWallet value)  insufficientFundsInPaperWallet,required TResult Function( BridgeError_InvalidPaperWallet value)  invalidPaperWallet,required TResult Function( BridgeError_FeaturesAndromedaBitcoinError value)  featuresAndromedaBitcoinError,required TResult Function( BridgeError_FeaturesAndromedaCommonError value)  featuresAndromedaCommonError,required TResult Function( BridgeError_AccountExportDatetimeError value)  accountExportDatetimeError,}){
final _that = this;
switch (_that) {
case BridgeError_ApiLock():
return apiLock(_that);case BridgeError_Generic():
return generic(_that);case BridgeError_MuonAuthSession():
return muonAuthSession(_that);case BridgeError_MuonAuthRefresh():
return muonAuthRefresh(_that);case BridgeError_MuonClient():
return muonClient(_that);case BridgeError_MuonSession():
return muonSession(_that);case BridgeError_AndromedaBitcoin():
return andromedaBitcoin(_that);case BridgeError_ApiResponse():
return apiResponse(_that);case BridgeError_ApiDeserialize():
return apiDeserialize(_that);case BridgeError_BitcoinDeserialize():
return bitcoinDeserialize(_that);case BridgeError_ApiSrp():
return apiSrp(_that);case BridgeError_AesGcm():
return aesGcm(_that);case BridgeError_WalletCrypto():
return walletCrypto(_that);case BridgeError_WalletDecryption():
return walletDecryption(_that);case BridgeError_WalletFeature():
return walletFeature(_that);case BridgeError_Login():
return login(_that);case BridgeError_Fork():
return fork(_that);case BridgeError_Database():
return database(_that);case BridgeError_SessionStore():
return sessionStore(_that);case BridgeError_Encoding():
return encoding(_that);case BridgeError_InsufficientFundsInPaperWallet():
return insufficientFundsInPaperWallet(_that);case BridgeError_InvalidPaperWallet():
return invalidPaperWallet(_that);case BridgeError_FeaturesAndromedaBitcoinError():
return featuresAndromedaBitcoinError(_that);case BridgeError_FeaturesAndromedaCommonError():
return featuresAndromedaCommonError(_that);case BridgeError_AccountExportDatetimeError():
return accountExportDatetimeError(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( BridgeError_ApiLock value)?  apiLock,TResult? Function( BridgeError_Generic value)?  generic,TResult? Function( BridgeError_MuonAuthSession value)?  muonAuthSession,TResult? Function( BridgeError_MuonAuthRefresh value)?  muonAuthRefresh,TResult? Function( BridgeError_MuonClient value)?  muonClient,TResult? Function( BridgeError_MuonSession value)?  muonSession,TResult? Function( BridgeError_AndromedaBitcoin value)?  andromedaBitcoin,TResult? Function( BridgeError_ApiResponse value)?  apiResponse,TResult? Function( BridgeError_ApiDeserialize value)?  apiDeserialize,TResult? Function( BridgeError_BitcoinDeserialize value)?  bitcoinDeserialize,TResult? Function( BridgeError_ApiSrp value)?  apiSrp,TResult? Function( BridgeError_AesGcm value)?  aesGcm,TResult? Function( BridgeError_WalletCrypto value)?  walletCrypto,TResult? Function( BridgeError_WalletDecryption value)?  walletDecryption,TResult? Function( BridgeError_WalletFeature value)?  walletFeature,TResult? Function( BridgeError_Login value)?  login,TResult? Function( BridgeError_Fork value)?  fork,TResult? Function( BridgeError_Database value)?  database,TResult? Function( BridgeError_SessionStore value)?  sessionStore,TResult? Function( BridgeError_Encoding value)?  encoding,TResult? Function( BridgeError_InsufficientFundsInPaperWallet value)?  insufficientFundsInPaperWallet,TResult? Function( BridgeError_InvalidPaperWallet value)?  invalidPaperWallet,TResult? Function( BridgeError_FeaturesAndromedaBitcoinError value)?  featuresAndromedaBitcoinError,TResult? Function( BridgeError_FeaturesAndromedaCommonError value)?  featuresAndromedaCommonError,TResult? Function( BridgeError_AccountExportDatetimeError value)?  accountExportDatetimeError,}){
final _that = this;
switch (_that) {
case BridgeError_ApiLock() when apiLock != null:
return apiLock(_that);case BridgeError_Generic() when generic != null:
return generic(_that);case BridgeError_MuonAuthSession() when muonAuthSession != null:
return muonAuthSession(_that);case BridgeError_MuonAuthRefresh() when muonAuthRefresh != null:
return muonAuthRefresh(_that);case BridgeError_MuonClient() when muonClient != null:
return muonClient(_that);case BridgeError_MuonSession() when muonSession != null:
return muonSession(_that);case BridgeError_AndromedaBitcoin() when andromedaBitcoin != null:
return andromedaBitcoin(_that);case BridgeError_ApiResponse() when apiResponse != null:
return apiResponse(_that);case BridgeError_ApiDeserialize() when apiDeserialize != null:
return apiDeserialize(_that);case BridgeError_BitcoinDeserialize() when bitcoinDeserialize != null:
return bitcoinDeserialize(_that);case BridgeError_ApiSrp() when apiSrp != null:
return apiSrp(_that);case BridgeError_AesGcm() when aesGcm != null:
return aesGcm(_that);case BridgeError_WalletCrypto() when walletCrypto != null:
return walletCrypto(_that);case BridgeError_WalletDecryption() when walletDecryption != null:
return walletDecryption(_that);case BridgeError_WalletFeature() when walletFeature != null:
return walletFeature(_that);case BridgeError_Login() when login != null:
return login(_that);case BridgeError_Fork() when fork != null:
return fork(_that);case BridgeError_Database() when database != null:
return database(_that);case BridgeError_SessionStore() when sessionStore != null:
return sessionStore(_that);case BridgeError_Encoding() when encoding != null:
return encoding(_that);case BridgeError_InsufficientFundsInPaperWallet() when insufficientFundsInPaperWallet != null:
return insufficientFundsInPaperWallet(_that);case BridgeError_InvalidPaperWallet() when invalidPaperWallet != null:
return invalidPaperWallet(_that);case BridgeError_FeaturesAndromedaBitcoinError() when featuresAndromedaBitcoinError != null:
return featuresAndromedaBitcoinError(_that);case BridgeError_FeaturesAndromedaCommonError() when featuresAndromedaCommonError != null:
return featuresAndromedaCommonError(_that);case BridgeError_AccountExportDatetimeError() when accountExportDatetimeError != null:
return accountExportDatetimeError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String field0)?  apiLock,TResult Function( String field0)?  generic,TResult Function( String field0)?  muonAuthSession,TResult Function( String field0)?  muonAuthRefresh,TResult Function( String field0)?  muonClient,TResult Function( String field0)?  muonSession,TResult Function( String field0)?  andromedaBitcoin,TResult Function( ResponseError field0)?  apiResponse,TResult Function( String field0)?  apiDeserialize,TResult Function( String field0)?  bitcoinDeserialize,TResult Function( String field0)?  apiSrp,TResult Function( String field0)?  aesGcm,TResult Function( String field0)?  walletCrypto,TResult Function( String field0)?  walletDecryption,TResult Function( String field0)?  walletFeature,TResult Function( String field0)?  login,TResult Function( String field0)?  fork,TResult Function( String field0)?  database,TResult Function( String field0)?  sessionStore,TResult Function( String field0)?  encoding,TResult Function( String field0)?  insufficientFundsInPaperWallet,TResult Function( String field0)?  invalidPaperWallet,TResult Function( String field0)?  featuresAndromedaBitcoinError,TResult Function( String field0)?  featuresAndromedaCommonError,TResult Function( String field0)?  accountExportDatetimeError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case BridgeError_ApiLock() when apiLock != null:
return apiLock(_that.field0);case BridgeError_Generic() when generic != null:
return generic(_that.field0);case BridgeError_MuonAuthSession() when muonAuthSession != null:
return muonAuthSession(_that.field0);case BridgeError_MuonAuthRefresh() when muonAuthRefresh != null:
return muonAuthRefresh(_that.field0);case BridgeError_MuonClient() when muonClient != null:
return muonClient(_that.field0);case BridgeError_MuonSession() when muonSession != null:
return muonSession(_that.field0);case BridgeError_AndromedaBitcoin() when andromedaBitcoin != null:
return andromedaBitcoin(_that.field0);case BridgeError_ApiResponse() when apiResponse != null:
return apiResponse(_that.field0);case BridgeError_ApiDeserialize() when apiDeserialize != null:
return apiDeserialize(_that.field0);case BridgeError_BitcoinDeserialize() when bitcoinDeserialize != null:
return bitcoinDeserialize(_that.field0);case BridgeError_ApiSrp() when apiSrp != null:
return apiSrp(_that.field0);case BridgeError_AesGcm() when aesGcm != null:
return aesGcm(_that.field0);case BridgeError_WalletCrypto() when walletCrypto != null:
return walletCrypto(_that.field0);case BridgeError_WalletDecryption() when walletDecryption != null:
return walletDecryption(_that.field0);case BridgeError_WalletFeature() when walletFeature != null:
return walletFeature(_that.field0);case BridgeError_Login() when login != null:
return login(_that.field0);case BridgeError_Fork() when fork != null:
return fork(_that.field0);case BridgeError_Database() when database != null:
return database(_that.field0);case BridgeError_SessionStore() when sessionStore != null:
return sessionStore(_that.field0);case BridgeError_Encoding() when encoding != null:
return encoding(_that.field0);case BridgeError_InsufficientFundsInPaperWallet() when insufficientFundsInPaperWallet != null:
return insufficientFundsInPaperWallet(_that.field0);case BridgeError_InvalidPaperWallet() when invalidPaperWallet != null:
return invalidPaperWallet(_that.field0);case BridgeError_FeaturesAndromedaBitcoinError() when featuresAndromedaBitcoinError != null:
return featuresAndromedaBitcoinError(_that.field0);case BridgeError_FeaturesAndromedaCommonError() when featuresAndromedaCommonError != null:
return featuresAndromedaCommonError(_that.field0);case BridgeError_AccountExportDatetimeError() when accountExportDatetimeError != null:
return accountExportDatetimeError(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String field0)  apiLock,required TResult Function( String field0)  generic,required TResult Function( String field0)  muonAuthSession,required TResult Function( String field0)  muonAuthRefresh,required TResult Function( String field0)  muonClient,required TResult Function( String field0)  muonSession,required TResult Function( String field0)  andromedaBitcoin,required TResult Function( ResponseError field0)  apiResponse,required TResult Function( String field0)  apiDeserialize,required TResult Function( String field0)  bitcoinDeserialize,required TResult Function( String field0)  apiSrp,required TResult Function( String field0)  aesGcm,required TResult Function( String field0)  walletCrypto,required TResult Function( String field0)  walletDecryption,required TResult Function( String field0)  walletFeature,required TResult Function( String field0)  login,required TResult Function( String field0)  fork,required TResult Function( String field0)  database,required TResult Function( String field0)  sessionStore,required TResult Function( String field0)  encoding,required TResult Function( String field0)  insufficientFundsInPaperWallet,required TResult Function( String field0)  invalidPaperWallet,required TResult Function( String field0)  featuresAndromedaBitcoinError,required TResult Function( String field0)  featuresAndromedaCommonError,required TResult Function( String field0)  accountExportDatetimeError,}) {final _that = this;
switch (_that) {
case BridgeError_ApiLock():
return apiLock(_that.field0);case BridgeError_Generic():
return generic(_that.field0);case BridgeError_MuonAuthSession():
return muonAuthSession(_that.field0);case BridgeError_MuonAuthRefresh():
return muonAuthRefresh(_that.field0);case BridgeError_MuonClient():
return muonClient(_that.field0);case BridgeError_MuonSession():
return muonSession(_that.field0);case BridgeError_AndromedaBitcoin():
return andromedaBitcoin(_that.field0);case BridgeError_ApiResponse():
return apiResponse(_that.field0);case BridgeError_ApiDeserialize():
return apiDeserialize(_that.field0);case BridgeError_BitcoinDeserialize():
return bitcoinDeserialize(_that.field0);case BridgeError_ApiSrp():
return apiSrp(_that.field0);case BridgeError_AesGcm():
return aesGcm(_that.field0);case BridgeError_WalletCrypto():
return walletCrypto(_that.field0);case BridgeError_WalletDecryption():
return walletDecryption(_that.field0);case BridgeError_WalletFeature():
return walletFeature(_that.field0);case BridgeError_Login():
return login(_that.field0);case BridgeError_Fork():
return fork(_that.field0);case BridgeError_Database():
return database(_that.field0);case BridgeError_SessionStore():
return sessionStore(_that.field0);case BridgeError_Encoding():
return encoding(_that.field0);case BridgeError_InsufficientFundsInPaperWallet():
return insufficientFundsInPaperWallet(_that.field0);case BridgeError_InvalidPaperWallet():
return invalidPaperWallet(_that.field0);case BridgeError_FeaturesAndromedaBitcoinError():
return featuresAndromedaBitcoinError(_that.field0);case BridgeError_FeaturesAndromedaCommonError():
return featuresAndromedaCommonError(_that.field0);case BridgeError_AccountExportDatetimeError():
return accountExportDatetimeError(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String field0)?  apiLock,TResult? Function( String field0)?  generic,TResult? Function( String field0)?  muonAuthSession,TResult? Function( String field0)?  muonAuthRefresh,TResult? Function( String field0)?  muonClient,TResult? Function( String field0)?  muonSession,TResult? Function( String field0)?  andromedaBitcoin,TResult? Function( ResponseError field0)?  apiResponse,TResult? Function( String field0)?  apiDeserialize,TResult? Function( String field0)?  bitcoinDeserialize,TResult? Function( String field0)?  apiSrp,TResult? Function( String field0)?  aesGcm,TResult? Function( String field0)?  walletCrypto,TResult? Function( String field0)?  walletDecryption,TResult? Function( String field0)?  walletFeature,TResult? Function( String field0)?  login,TResult? Function( String field0)?  fork,TResult? Function( String field0)?  database,TResult? Function( String field0)?  sessionStore,TResult? Function( String field0)?  encoding,TResult? Function( String field0)?  insufficientFundsInPaperWallet,TResult? Function( String field0)?  invalidPaperWallet,TResult? Function( String field0)?  featuresAndromedaBitcoinError,TResult? Function( String field0)?  featuresAndromedaCommonError,TResult? Function( String field0)?  accountExportDatetimeError,}) {final _that = this;
switch (_that) {
case BridgeError_ApiLock() when apiLock != null:
return apiLock(_that.field0);case BridgeError_Generic() when generic != null:
return generic(_that.field0);case BridgeError_MuonAuthSession() when muonAuthSession != null:
return muonAuthSession(_that.field0);case BridgeError_MuonAuthRefresh() when muonAuthRefresh != null:
return muonAuthRefresh(_that.field0);case BridgeError_MuonClient() when muonClient != null:
return muonClient(_that.field0);case BridgeError_MuonSession() when muonSession != null:
return muonSession(_that.field0);case BridgeError_AndromedaBitcoin() when andromedaBitcoin != null:
return andromedaBitcoin(_that.field0);case BridgeError_ApiResponse() when apiResponse != null:
return apiResponse(_that.field0);case BridgeError_ApiDeserialize() when apiDeserialize != null:
return apiDeserialize(_that.field0);case BridgeError_BitcoinDeserialize() when bitcoinDeserialize != null:
return bitcoinDeserialize(_that.field0);case BridgeError_ApiSrp() when apiSrp != null:
return apiSrp(_that.field0);case BridgeError_AesGcm() when aesGcm != null:
return aesGcm(_that.field0);case BridgeError_WalletCrypto() when walletCrypto != null:
return walletCrypto(_that.field0);case BridgeError_WalletDecryption() when walletDecryption != null:
return walletDecryption(_that.field0);case BridgeError_WalletFeature() when walletFeature != null:
return walletFeature(_that.field0);case BridgeError_Login() when login != null:
return login(_that.field0);case BridgeError_Fork() when fork != null:
return fork(_that.field0);case BridgeError_Database() when database != null:
return database(_that.field0);case BridgeError_SessionStore() when sessionStore != null:
return sessionStore(_that.field0);case BridgeError_Encoding() when encoding != null:
return encoding(_that.field0);case BridgeError_InsufficientFundsInPaperWallet() when insufficientFundsInPaperWallet != null:
return insufficientFundsInPaperWallet(_that.field0);case BridgeError_InvalidPaperWallet() when invalidPaperWallet != null:
return invalidPaperWallet(_that.field0);case BridgeError_FeaturesAndromedaBitcoinError() when featuresAndromedaBitcoinError != null:
return featuresAndromedaBitcoinError(_that.field0);case BridgeError_FeaturesAndromedaCommonError() when featuresAndromedaCommonError != null:
return featuresAndromedaCommonError(_that.field0);case BridgeError_AccountExportDatetimeError() when accountExportDatetimeError != null:
return accountExportDatetimeError(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class BridgeError_ApiLock extends BridgeError {
  const BridgeError_ApiLock(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_ApiLockCopyWith<BridgeError_ApiLock> get copyWith => _$BridgeError_ApiLockCopyWithImpl<BridgeError_ApiLock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_ApiLock&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.apiLock(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_ApiLockCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_ApiLockCopyWith(BridgeError_ApiLock value, $Res Function(BridgeError_ApiLock) _then) = _$BridgeError_ApiLockCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_ApiLockCopyWithImpl<$Res>
    implements $BridgeError_ApiLockCopyWith<$Res> {
  _$BridgeError_ApiLockCopyWithImpl(this._self, this._then);

  final BridgeError_ApiLock _self;
  final $Res Function(BridgeError_ApiLock) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_ApiLock(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_Generic extends BridgeError {
  const BridgeError_Generic(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_GenericCopyWith<BridgeError_Generic> get copyWith => _$BridgeError_GenericCopyWithImpl<BridgeError_Generic>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_Generic&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.generic(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_GenericCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_GenericCopyWith(BridgeError_Generic value, $Res Function(BridgeError_Generic) _then) = _$BridgeError_GenericCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_GenericCopyWithImpl<$Res>
    implements $BridgeError_GenericCopyWith<$Res> {
  _$BridgeError_GenericCopyWithImpl(this._self, this._then);

  final BridgeError_Generic _self;
  final $Res Function(BridgeError_Generic) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_Generic(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_MuonAuthSession extends BridgeError {
  const BridgeError_MuonAuthSession(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_MuonAuthSessionCopyWith<BridgeError_MuonAuthSession> get copyWith => _$BridgeError_MuonAuthSessionCopyWithImpl<BridgeError_MuonAuthSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_MuonAuthSession&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.muonAuthSession(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_MuonAuthSessionCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_MuonAuthSessionCopyWith(BridgeError_MuonAuthSession value, $Res Function(BridgeError_MuonAuthSession) _then) = _$BridgeError_MuonAuthSessionCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_MuonAuthSessionCopyWithImpl<$Res>
    implements $BridgeError_MuonAuthSessionCopyWith<$Res> {
  _$BridgeError_MuonAuthSessionCopyWithImpl(this._self, this._then);

  final BridgeError_MuonAuthSession _self;
  final $Res Function(BridgeError_MuonAuthSession) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_MuonAuthSession(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_MuonAuthRefresh extends BridgeError {
  const BridgeError_MuonAuthRefresh(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_MuonAuthRefreshCopyWith<BridgeError_MuonAuthRefresh> get copyWith => _$BridgeError_MuonAuthRefreshCopyWithImpl<BridgeError_MuonAuthRefresh>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_MuonAuthRefresh&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.muonAuthRefresh(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_MuonAuthRefreshCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_MuonAuthRefreshCopyWith(BridgeError_MuonAuthRefresh value, $Res Function(BridgeError_MuonAuthRefresh) _then) = _$BridgeError_MuonAuthRefreshCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_MuonAuthRefreshCopyWithImpl<$Res>
    implements $BridgeError_MuonAuthRefreshCopyWith<$Res> {
  _$BridgeError_MuonAuthRefreshCopyWithImpl(this._self, this._then);

  final BridgeError_MuonAuthRefresh _self;
  final $Res Function(BridgeError_MuonAuthRefresh) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_MuonAuthRefresh(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_MuonClient extends BridgeError {
  const BridgeError_MuonClient(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_MuonClientCopyWith<BridgeError_MuonClient> get copyWith => _$BridgeError_MuonClientCopyWithImpl<BridgeError_MuonClient>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_MuonClient&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.muonClient(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_MuonClientCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_MuonClientCopyWith(BridgeError_MuonClient value, $Res Function(BridgeError_MuonClient) _then) = _$BridgeError_MuonClientCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_MuonClientCopyWithImpl<$Res>
    implements $BridgeError_MuonClientCopyWith<$Res> {
  _$BridgeError_MuonClientCopyWithImpl(this._self, this._then);

  final BridgeError_MuonClient _self;
  final $Res Function(BridgeError_MuonClient) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_MuonClient(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_MuonSession extends BridgeError {
  const BridgeError_MuonSession(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_MuonSessionCopyWith<BridgeError_MuonSession> get copyWith => _$BridgeError_MuonSessionCopyWithImpl<BridgeError_MuonSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_MuonSession&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.muonSession(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_MuonSessionCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_MuonSessionCopyWith(BridgeError_MuonSession value, $Res Function(BridgeError_MuonSession) _then) = _$BridgeError_MuonSessionCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_MuonSessionCopyWithImpl<$Res>
    implements $BridgeError_MuonSessionCopyWith<$Res> {
  _$BridgeError_MuonSessionCopyWithImpl(this._self, this._then);

  final BridgeError_MuonSession _self;
  final $Res Function(BridgeError_MuonSession) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_MuonSession(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_AndromedaBitcoin extends BridgeError {
  const BridgeError_AndromedaBitcoin(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_AndromedaBitcoinCopyWith<BridgeError_AndromedaBitcoin> get copyWith => _$BridgeError_AndromedaBitcoinCopyWithImpl<BridgeError_AndromedaBitcoin>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_AndromedaBitcoin&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.andromedaBitcoin(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_AndromedaBitcoinCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_AndromedaBitcoinCopyWith(BridgeError_AndromedaBitcoin value, $Res Function(BridgeError_AndromedaBitcoin) _then) = _$BridgeError_AndromedaBitcoinCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_AndromedaBitcoinCopyWithImpl<$Res>
    implements $BridgeError_AndromedaBitcoinCopyWith<$Res> {
  _$BridgeError_AndromedaBitcoinCopyWithImpl(this._self, this._then);

  final BridgeError_AndromedaBitcoin _self;
  final $Res Function(BridgeError_AndromedaBitcoin) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_AndromedaBitcoin(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_ApiResponse extends BridgeError {
  const BridgeError_ApiResponse(this.field0): super._();
  

@override final  ResponseError field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_ApiResponseCopyWith<BridgeError_ApiResponse> get copyWith => _$BridgeError_ApiResponseCopyWithImpl<BridgeError_ApiResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_ApiResponse&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.apiResponse(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_ApiResponseCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_ApiResponseCopyWith(BridgeError_ApiResponse value, $Res Function(BridgeError_ApiResponse) _then) = _$BridgeError_ApiResponseCopyWithImpl;
@useResult
$Res call({
 ResponseError field0
});




}
/// @nodoc
class _$BridgeError_ApiResponseCopyWithImpl<$Res>
    implements $BridgeError_ApiResponseCopyWith<$Res> {
  _$BridgeError_ApiResponseCopyWithImpl(this._self, this._then);

  final BridgeError_ApiResponse _self;
  final $Res Function(BridgeError_ApiResponse) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_ApiResponse(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as ResponseError,
  ));
}


}

/// @nodoc


class BridgeError_ApiDeserialize extends BridgeError {
  const BridgeError_ApiDeserialize(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_ApiDeserializeCopyWith<BridgeError_ApiDeserialize> get copyWith => _$BridgeError_ApiDeserializeCopyWithImpl<BridgeError_ApiDeserialize>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_ApiDeserialize&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.apiDeserialize(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_ApiDeserializeCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_ApiDeserializeCopyWith(BridgeError_ApiDeserialize value, $Res Function(BridgeError_ApiDeserialize) _then) = _$BridgeError_ApiDeserializeCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_ApiDeserializeCopyWithImpl<$Res>
    implements $BridgeError_ApiDeserializeCopyWith<$Res> {
  _$BridgeError_ApiDeserializeCopyWithImpl(this._self, this._then);

  final BridgeError_ApiDeserialize _self;
  final $Res Function(BridgeError_ApiDeserialize) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_ApiDeserialize(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_BitcoinDeserialize extends BridgeError {
  const BridgeError_BitcoinDeserialize(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_BitcoinDeserializeCopyWith<BridgeError_BitcoinDeserialize> get copyWith => _$BridgeError_BitcoinDeserializeCopyWithImpl<BridgeError_BitcoinDeserialize>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_BitcoinDeserialize&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.bitcoinDeserialize(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_BitcoinDeserializeCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_BitcoinDeserializeCopyWith(BridgeError_BitcoinDeserialize value, $Res Function(BridgeError_BitcoinDeserialize) _then) = _$BridgeError_BitcoinDeserializeCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_BitcoinDeserializeCopyWithImpl<$Res>
    implements $BridgeError_BitcoinDeserializeCopyWith<$Res> {
  _$BridgeError_BitcoinDeserializeCopyWithImpl(this._self, this._then);

  final BridgeError_BitcoinDeserialize _self;
  final $Res Function(BridgeError_BitcoinDeserialize) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_BitcoinDeserialize(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_ApiSrp extends BridgeError {
  const BridgeError_ApiSrp(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_ApiSrpCopyWith<BridgeError_ApiSrp> get copyWith => _$BridgeError_ApiSrpCopyWithImpl<BridgeError_ApiSrp>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_ApiSrp&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.apiSrp(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_ApiSrpCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_ApiSrpCopyWith(BridgeError_ApiSrp value, $Res Function(BridgeError_ApiSrp) _then) = _$BridgeError_ApiSrpCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_ApiSrpCopyWithImpl<$Res>
    implements $BridgeError_ApiSrpCopyWith<$Res> {
  _$BridgeError_ApiSrpCopyWithImpl(this._self, this._then);

  final BridgeError_ApiSrp _self;
  final $Res Function(BridgeError_ApiSrp) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_ApiSrp(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_AesGcm extends BridgeError {
  const BridgeError_AesGcm(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_AesGcmCopyWith<BridgeError_AesGcm> get copyWith => _$BridgeError_AesGcmCopyWithImpl<BridgeError_AesGcm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_AesGcm&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.aesGcm(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_AesGcmCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_AesGcmCopyWith(BridgeError_AesGcm value, $Res Function(BridgeError_AesGcm) _then) = _$BridgeError_AesGcmCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_AesGcmCopyWithImpl<$Res>
    implements $BridgeError_AesGcmCopyWith<$Res> {
  _$BridgeError_AesGcmCopyWithImpl(this._self, this._then);

  final BridgeError_AesGcm _self;
  final $Res Function(BridgeError_AesGcm) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_AesGcm(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_WalletCrypto extends BridgeError {
  const BridgeError_WalletCrypto(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_WalletCryptoCopyWith<BridgeError_WalletCrypto> get copyWith => _$BridgeError_WalletCryptoCopyWithImpl<BridgeError_WalletCrypto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_WalletCrypto&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.walletCrypto(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_WalletCryptoCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_WalletCryptoCopyWith(BridgeError_WalletCrypto value, $Res Function(BridgeError_WalletCrypto) _then) = _$BridgeError_WalletCryptoCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_WalletCryptoCopyWithImpl<$Res>
    implements $BridgeError_WalletCryptoCopyWith<$Res> {
  _$BridgeError_WalletCryptoCopyWithImpl(this._self, this._then);

  final BridgeError_WalletCrypto _self;
  final $Res Function(BridgeError_WalletCrypto) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_WalletCrypto(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_WalletDecryption extends BridgeError {
  const BridgeError_WalletDecryption(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_WalletDecryptionCopyWith<BridgeError_WalletDecryption> get copyWith => _$BridgeError_WalletDecryptionCopyWithImpl<BridgeError_WalletDecryption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_WalletDecryption&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.walletDecryption(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_WalletDecryptionCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_WalletDecryptionCopyWith(BridgeError_WalletDecryption value, $Res Function(BridgeError_WalletDecryption) _then) = _$BridgeError_WalletDecryptionCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_WalletDecryptionCopyWithImpl<$Res>
    implements $BridgeError_WalletDecryptionCopyWith<$Res> {
  _$BridgeError_WalletDecryptionCopyWithImpl(this._self, this._then);

  final BridgeError_WalletDecryption _self;
  final $Res Function(BridgeError_WalletDecryption) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_WalletDecryption(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_WalletFeature extends BridgeError {
  const BridgeError_WalletFeature(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_WalletFeatureCopyWith<BridgeError_WalletFeature> get copyWith => _$BridgeError_WalletFeatureCopyWithImpl<BridgeError_WalletFeature>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_WalletFeature&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.walletFeature(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_WalletFeatureCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_WalletFeatureCopyWith(BridgeError_WalletFeature value, $Res Function(BridgeError_WalletFeature) _then) = _$BridgeError_WalletFeatureCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_WalletFeatureCopyWithImpl<$Res>
    implements $BridgeError_WalletFeatureCopyWith<$Res> {
  _$BridgeError_WalletFeatureCopyWithImpl(this._self, this._then);

  final BridgeError_WalletFeature _self;
  final $Res Function(BridgeError_WalletFeature) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_WalletFeature(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_Login extends BridgeError {
  const BridgeError_Login(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_LoginCopyWith<BridgeError_Login> get copyWith => _$BridgeError_LoginCopyWithImpl<BridgeError_Login>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_Login&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.login(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_LoginCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_LoginCopyWith(BridgeError_Login value, $Res Function(BridgeError_Login) _then) = _$BridgeError_LoginCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_LoginCopyWithImpl<$Res>
    implements $BridgeError_LoginCopyWith<$Res> {
  _$BridgeError_LoginCopyWithImpl(this._self, this._then);

  final BridgeError_Login _self;
  final $Res Function(BridgeError_Login) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_Login(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_Fork extends BridgeError {
  const BridgeError_Fork(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_ForkCopyWith<BridgeError_Fork> get copyWith => _$BridgeError_ForkCopyWithImpl<BridgeError_Fork>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_Fork&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.fork(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_ForkCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_ForkCopyWith(BridgeError_Fork value, $Res Function(BridgeError_Fork) _then) = _$BridgeError_ForkCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_ForkCopyWithImpl<$Res>
    implements $BridgeError_ForkCopyWith<$Res> {
  _$BridgeError_ForkCopyWithImpl(this._self, this._then);

  final BridgeError_Fork _self;
  final $Res Function(BridgeError_Fork) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_Fork(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_Database extends BridgeError {
  const BridgeError_Database(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_DatabaseCopyWith<BridgeError_Database> get copyWith => _$BridgeError_DatabaseCopyWithImpl<BridgeError_Database>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_Database&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.database(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_DatabaseCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_DatabaseCopyWith(BridgeError_Database value, $Res Function(BridgeError_Database) _then) = _$BridgeError_DatabaseCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_DatabaseCopyWithImpl<$Res>
    implements $BridgeError_DatabaseCopyWith<$Res> {
  _$BridgeError_DatabaseCopyWithImpl(this._self, this._then);

  final BridgeError_Database _self;
  final $Res Function(BridgeError_Database) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_Database(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_SessionStore extends BridgeError {
  const BridgeError_SessionStore(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_SessionStoreCopyWith<BridgeError_SessionStore> get copyWith => _$BridgeError_SessionStoreCopyWithImpl<BridgeError_SessionStore>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_SessionStore&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.sessionStore(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_SessionStoreCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_SessionStoreCopyWith(BridgeError_SessionStore value, $Res Function(BridgeError_SessionStore) _then) = _$BridgeError_SessionStoreCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_SessionStoreCopyWithImpl<$Res>
    implements $BridgeError_SessionStoreCopyWith<$Res> {
  _$BridgeError_SessionStoreCopyWithImpl(this._self, this._then);

  final BridgeError_SessionStore _self;
  final $Res Function(BridgeError_SessionStore) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_SessionStore(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_Encoding extends BridgeError {
  const BridgeError_Encoding(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_EncodingCopyWith<BridgeError_Encoding> get copyWith => _$BridgeError_EncodingCopyWithImpl<BridgeError_Encoding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_Encoding&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.encoding(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_EncodingCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_EncodingCopyWith(BridgeError_Encoding value, $Res Function(BridgeError_Encoding) _then) = _$BridgeError_EncodingCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_EncodingCopyWithImpl<$Res>
    implements $BridgeError_EncodingCopyWith<$Res> {
  _$BridgeError_EncodingCopyWithImpl(this._self, this._then);

  final BridgeError_Encoding _self;
  final $Res Function(BridgeError_Encoding) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_Encoding(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_InsufficientFundsInPaperWallet extends BridgeError {
  const BridgeError_InsufficientFundsInPaperWallet(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_InsufficientFundsInPaperWalletCopyWith<BridgeError_InsufficientFundsInPaperWallet> get copyWith => _$BridgeError_InsufficientFundsInPaperWalletCopyWithImpl<BridgeError_InsufficientFundsInPaperWallet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_InsufficientFundsInPaperWallet&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.insufficientFundsInPaperWallet(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_InsufficientFundsInPaperWalletCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_InsufficientFundsInPaperWalletCopyWith(BridgeError_InsufficientFundsInPaperWallet value, $Res Function(BridgeError_InsufficientFundsInPaperWallet) _then) = _$BridgeError_InsufficientFundsInPaperWalletCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_InsufficientFundsInPaperWalletCopyWithImpl<$Res>
    implements $BridgeError_InsufficientFundsInPaperWalletCopyWith<$Res> {
  _$BridgeError_InsufficientFundsInPaperWalletCopyWithImpl(this._self, this._then);

  final BridgeError_InsufficientFundsInPaperWallet _self;
  final $Res Function(BridgeError_InsufficientFundsInPaperWallet) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_InsufficientFundsInPaperWallet(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_InvalidPaperWallet extends BridgeError {
  const BridgeError_InvalidPaperWallet(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_InvalidPaperWalletCopyWith<BridgeError_InvalidPaperWallet> get copyWith => _$BridgeError_InvalidPaperWalletCopyWithImpl<BridgeError_InvalidPaperWallet>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_InvalidPaperWallet&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.invalidPaperWallet(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_InvalidPaperWalletCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_InvalidPaperWalletCopyWith(BridgeError_InvalidPaperWallet value, $Res Function(BridgeError_InvalidPaperWallet) _then) = _$BridgeError_InvalidPaperWalletCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_InvalidPaperWalletCopyWithImpl<$Res>
    implements $BridgeError_InvalidPaperWalletCopyWith<$Res> {
  _$BridgeError_InvalidPaperWalletCopyWithImpl(this._self, this._then);

  final BridgeError_InvalidPaperWallet _self;
  final $Res Function(BridgeError_InvalidPaperWallet) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_InvalidPaperWallet(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_FeaturesAndromedaBitcoinError extends BridgeError {
  const BridgeError_FeaturesAndromedaBitcoinError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_FeaturesAndromedaBitcoinErrorCopyWith<BridgeError_FeaturesAndromedaBitcoinError> get copyWith => _$BridgeError_FeaturesAndromedaBitcoinErrorCopyWithImpl<BridgeError_FeaturesAndromedaBitcoinError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_FeaturesAndromedaBitcoinError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.featuresAndromedaBitcoinError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_FeaturesAndromedaBitcoinErrorCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_FeaturesAndromedaBitcoinErrorCopyWith(BridgeError_FeaturesAndromedaBitcoinError value, $Res Function(BridgeError_FeaturesAndromedaBitcoinError) _then) = _$BridgeError_FeaturesAndromedaBitcoinErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_FeaturesAndromedaBitcoinErrorCopyWithImpl<$Res>
    implements $BridgeError_FeaturesAndromedaBitcoinErrorCopyWith<$Res> {
  _$BridgeError_FeaturesAndromedaBitcoinErrorCopyWithImpl(this._self, this._then);

  final BridgeError_FeaturesAndromedaBitcoinError _self;
  final $Res Function(BridgeError_FeaturesAndromedaBitcoinError) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_FeaturesAndromedaBitcoinError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_FeaturesAndromedaCommonError extends BridgeError {
  const BridgeError_FeaturesAndromedaCommonError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_FeaturesAndromedaCommonErrorCopyWith<BridgeError_FeaturesAndromedaCommonError> get copyWith => _$BridgeError_FeaturesAndromedaCommonErrorCopyWithImpl<BridgeError_FeaturesAndromedaCommonError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_FeaturesAndromedaCommonError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.featuresAndromedaCommonError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_FeaturesAndromedaCommonErrorCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_FeaturesAndromedaCommonErrorCopyWith(BridgeError_FeaturesAndromedaCommonError value, $Res Function(BridgeError_FeaturesAndromedaCommonError) _then) = _$BridgeError_FeaturesAndromedaCommonErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_FeaturesAndromedaCommonErrorCopyWithImpl<$Res>
    implements $BridgeError_FeaturesAndromedaCommonErrorCopyWith<$Res> {
  _$BridgeError_FeaturesAndromedaCommonErrorCopyWithImpl(this._self, this._then);

  final BridgeError_FeaturesAndromedaCommonError _self;
  final $Res Function(BridgeError_FeaturesAndromedaCommonError) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_FeaturesAndromedaCommonError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BridgeError_AccountExportDatetimeError extends BridgeError {
  const BridgeError_AccountExportDatetimeError(this.field0): super._();
  

@override final  String field0;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BridgeError_AccountExportDatetimeErrorCopyWith<BridgeError_AccountExportDatetimeError> get copyWith => _$BridgeError_AccountExportDatetimeErrorCopyWithImpl<BridgeError_AccountExportDatetimeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BridgeError_AccountExportDatetimeError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'BridgeError.accountExportDatetimeError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $BridgeError_AccountExportDatetimeErrorCopyWith<$Res> implements $BridgeErrorCopyWith<$Res> {
  factory $BridgeError_AccountExportDatetimeErrorCopyWith(BridgeError_AccountExportDatetimeError value, $Res Function(BridgeError_AccountExportDatetimeError) _then) = _$BridgeError_AccountExportDatetimeErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$BridgeError_AccountExportDatetimeErrorCopyWithImpl<$Res>
    implements $BridgeError_AccountExportDatetimeErrorCopyWith<$Res> {
  _$BridgeError_AccountExportDatetimeErrorCopyWithImpl(this._self, this._then);

  final BridgeError_AccountExportDatetimeError _self;
  final $Res Function(BridgeError_AccountExportDatetimeError) _then;

/// Create a copy of BridgeError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(BridgeError_AccountExportDatetimeError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
