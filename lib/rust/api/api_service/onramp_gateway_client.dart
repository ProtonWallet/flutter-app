// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.33.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import '../../proton_api/errors.dart';
import '../../proton_api/payment_gateway.dart';
import '../../proton_api/user_settings.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'proton_api_service.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<OnRampGatewayClient>>
@sealed
class OnRampGatewayClient extends RustOpaque {
  OnRampGatewayClient.dcoDecode(List<dynamic> wire)
      : super.dcoDecode(wire, _kStaticData);

  OnRampGatewayClient.sseDecode(int ptr, int externalSizeOnNative)
      : super.sseDecode(ptr, externalSizeOnNative, _kStaticData);

  static final _kStaticData = RustArcStaticData(
    rustArcIncrementStrongCount: RustLib
        .instance.api.rust_arc_increment_strong_count_OnRampGatewayClient,
    rustArcDecrementStrongCount: RustLib
        .instance.api.rust_arc_decrement_strong_count_OnRampGatewayClient,
    rustArcDecrementStrongCountPtr: RustLib
        .instance.api.rust_arc_decrement_strong_count_OnRampGatewayClientPtr,
  );

  Future<String> createOnRampCheckout(
          {required String amount,
          required String btcAddress,
          required FiatCurrency fiatCurrency,
          required PaymentMethod payMethod,
          required GatewayProvider provider,
          dynamic hint}) =>
      RustLib.instance.api.onRampGatewayClientCreateOnRampCheckout(
          that: this,
          amount: amount,
          btcAddress: btcAddress,
          fiatCurrency: fiatCurrency,
          payMethod: payMethod,
          provider: provider,
          hint: hint);

  Future<Map<GatewayProvider, List<ApiCountry>>> getCountries({dynamic hint}) =>
      RustLib.instance.api
          .onRampGatewayClientGetCountries(that: this, hint: hint);

  Future<Map<GatewayProvider, List<ApiCountryFiatCurrency>>> getFiatCurrencies(
          {dynamic hint}) =>
      RustLib.instance.api
          .onRampGatewayClientGetFiatCurrencies(that: this, hint: hint);

  Future<Map<GatewayProvider, List<PaymentMethod>>> getPaymentMethods(
          {required FiatCurrency fiatSymbol, dynamic hint}) =>
      RustLib.instance.api.onRampGatewayClientGetPaymentMethods(
          that: this, fiatSymbol: fiatSymbol, hint: hint);

  Future<Map<GatewayProvider, List<Quote>>> getQuotes(
          {required String amount,
          required FiatCurrency fiatCurrency,
          PaymentMethod? payMethod,
          GatewayProvider? provider,
          dynamic hint}) =>
      RustLib.instance.api.onRampGatewayClientGetQuotes(
          that: this,
          amount: amount,
          fiatCurrency: fiatCurrency,
          payMethod: payMethod,
          provider: provider,
          hint: hint);

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<OnRampGatewayClient> newInstance(
          {required ProtonApiService service, dynamic hint}) =>
      RustLib.instance.api.onRampGatewayClientNew(service: service, hint: hint);
}