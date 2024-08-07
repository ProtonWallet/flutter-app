import 'package:flutter/widgets.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

extension StringToBitcoinUnitExtension on String {
  BitcoinUnit toBitcoinUnit() {
    return BitcoinUnit.values
        .firstWhere((e) => e.toString().split('.').last == toLowerCase());
  }
}

extension StringToFiatCurrencyExtension on String {
  FiatCurrency toFiatCurrency() {
    return FiatCurrency.values
        .firstWhere((e) => e.toString().split('.').last == toLowerCase());
  }
}

extension FiatCurrencyToStringExtension on FiatCurrency {
  String enumToString() {
    return toString().split('.').last;
  }
}

extension BitcoinUnitToStringExtension on BitcoinUnit {
  String enumToString() {
    return toString().split('.').last;
  }
}

extension GatewayProviderToStringExtension on GatewayProvider {
  String enumToString() {
    switch (this) {
      case GatewayProvider.banxa:
        return 'Banxa';
      case GatewayProvider.ramp:
        return 'Ramp';
      case GatewayProvider.moonPay:
        return 'MoonPay';
      case GatewayProvider.unsupported:
        return 'Unsupported';
    }
  }
}

extension GatewayProviderImageExtension on GatewayProvider {
  Widget getIcon() {
    switch (this) {
      case GatewayProvider.banxa:
        return Assets.images.icon.banxa.svg(
          fit: BoxFit.fill,
        );
      case GatewayProvider.ramp:
        break;
      case GatewayProvider.moonPay:
        return Assets.images.icon.moonpay.svg(
          fit: BoxFit.fill,
        );
      case GatewayProvider.unsupported:
        break;
    }

    /// default return ramp icon
    return Assets.images.icon.ramp.svg(
      fit: BoxFit.fill,
    );
  }
}

extension PaymentMethodToStringExtension on PaymentMethod {
  String enumToString() {
    switch (this) {
      case PaymentMethod.applePay:
        return "Apple Pay";
      case PaymentMethod.bankTransfer:
        return "Bank Transfer";
      case PaymentMethod.card:
        return "Credit Card";
      case PaymentMethod.googlePay:
        return "Google Pay";
      case PaymentMethod.instantPayment:
        return "Instant Payment";
      case PaymentMethod.unsupported:
        return "Unknown Payment Method";
    }
  }
}

extension PaymentMethodImageExtension on PaymentMethod {
  Widget getIcon() {
    switch (this) {
      case PaymentMethod.applePay:
        return Assets.images.icon.applePay.svg(
          fit: BoxFit.fill,
        );
      case PaymentMethod.bankTransfer:
        break;
      case PaymentMethod.card:
        break;
      case PaymentMethod.googlePay:
        break;
      case PaymentMethod.instantPayment:
        break;
      case PaymentMethod.unsupported:
    }

    /// default return card icon
    return Assets.images.icon.creditCard.svg(
      fit: BoxFit.fill,
    );
  }
}

extension FiatCurrencyWrapperFullNameExtension on FiatCurrencyWrapper {
  String toFullName() {
    if (bitcoinCurrency != null) {
      if (bitcoinCurrency!.bitcoinUnit == BitcoinUnit.btc) {
        return "BTC (₿) - Bitcoin";
      } else if (bitcoinCurrency!.bitcoinUnit == BitcoinUnit.sats) {
        return "SATS (sat) - Satoshi";
      }
      return "Unknown";
    }
    return FiatCurrencyHelper.getFullName(fiatCurrency ?? defaultFiatCurrency);
  }
}

extension FiatCurrencyWrapperShortNameExtension on FiatCurrencyWrapper {
  String toShortName() {
    if (bitcoinCurrency != null) {
      if (bitcoinCurrency!.bitcoinUnit == BitcoinUnit.btc) {
        return "BTC";
      } else if (bitcoinCurrency!.bitcoinUnit == BitcoinUnit.sats) {
        return "SATS";
      }
    }
    return FiatCurrencyHelper.getDisplayName(
        fiatCurrency ?? defaultFiatCurrency);
  }
}

extension FiatCurrencyWrapperImageExtension on FiatCurrencyWrapper {
  Widget getIcon() {
    if (bitcoinCurrency != null) {
      return CommonHelper.getBitcoinIcon();
    }
    return CommonHelper.getCountryIcon(fiatCurrency ?? defaultFiatCurrency);
  }
}
