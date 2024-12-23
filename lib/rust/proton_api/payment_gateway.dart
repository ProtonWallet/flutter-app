// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class ApiCountry {
  final String code;
  final String fiatCurrency;
  final String name;

  const ApiCountry({
    required this.code,
    required this.fiatCurrency,
    required this.name,
  });

  @override
  int get hashCode => code.hashCode ^ fiatCurrency.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiCountry &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          fiatCurrency == other.fiatCurrency &&
          name == other.name;
}

class ApiSimpleFiatCurrency {
  final String name;
  final String symbol;
  final String? minimumAmount;

  const ApiSimpleFiatCurrency({
    required this.name,
    required this.symbol,
    this.minimumAmount,
  });

  @override
  int get hashCode => name.hashCode ^ symbol.hashCode ^ minimumAmount.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiSimpleFiatCurrency &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          symbol == other.symbol &&
          minimumAmount == other.minimumAmount;
}

enum GatewayProvider {
  banxa,
  ramp,
  moonPay,
  unsupported,
  ;
}

enum PaymentMethod {
  applePay,
  bankTransfer,
  card,
  googlePay,
  instantPayment,
  paypal,
  unsupported,
  ;
}

class Quote {
  final String bitcoinAmount;
  final String fiatAmount;
  final String fiatCurrencySymbol;
  final String networkFee;
  final String paymentGatewayFee;
  final PaymentMethod paymentMethod;
  final String? purchaseAmount;
  final String? paymentProcessingFee;
  final String? orderId;

  const Quote({
    required this.bitcoinAmount,
    required this.fiatAmount,
    required this.fiatCurrencySymbol,
    required this.networkFee,
    required this.paymentGatewayFee,
    required this.paymentMethod,
    this.purchaseAmount,
    this.paymentProcessingFee,
    this.orderId,
  });

  @override
  int get hashCode =>
      bitcoinAmount.hashCode ^
      fiatAmount.hashCode ^
      fiatCurrencySymbol.hashCode ^
      networkFee.hashCode ^
      paymentGatewayFee.hashCode ^
      paymentMethod.hashCode ^
      purchaseAmount.hashCode ^
      paymentProcessingFee.hashCode ^
      orderId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote &&
          runtimeType == other.runtimeType &&
          bitcoinAmount == other.bitcoinAmount &&
          fiatAmount == other.fiatAmount &&
          fiatCurrencySymbol == other.fiatCurrencySymbol &&
          networkFee == other.networkFee &&
          paymentGatewayFee == other.paymentGatewayFee &&
          paymentMethod == other.paymentMethod &&
          purchaseAmount == other.purchaseAmount &&
          paymentProcessingFee == other.paymentProcessingFee &&
          orderId == other.orderId;
}
