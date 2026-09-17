import 'package:flutter/widgets.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/fiat.currency.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

extension StringToBitcoinUnitExtension on String {
  BitcoinUnit toBitcoinUnit() {
    return BitcoinUnit.values.firstWhere(
      (e) => e.toString().split('.').last == toLowerCase(),
    );
  }
}

extension StringToFiatCurrencyExtension on String {
  FiatCurrency toFiatCurrency() {
    return FiatCurrency.values.firstWhere(
      (e) => e.toString().split('.').last == toLowerCase(),
    );
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
      fiatCurrency ?? defaultFiatCurrency,
    );
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
