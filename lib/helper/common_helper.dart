import 'dart:io';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/bottom.sheets/error.bottom.sheet.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/theme/theme.font.dart';

class CommonHelper {
  static FiatCurrency getFiatCurrency(String str) {
    switch (str) {
      case "USD":
        return FiatCurrency.usd;
      case "EUR":
        return FiatCurrency.eur;
      case "CHF":
        return FiatCurrency.chf;
      default:
        return FiatCurrency.eur;
    }
  }

  static void showSnackbar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      backgroundColor: isError ? ProtonColors.signalError : null,
      content: Center(
          child: Text(
        message,
        style: FontManager.body2Regular(ProtonColors.white),
      )),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String getFirstNChar(String str, int n) {
    if (n >= str.length) {
      return str;
    }
    if (n > 1) {
      return "${str.substring(0, n)}..";
    }
    return str.substring(0, n);
  }

  static Widget getBitcoinIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: ClipOval(
        child: Assets.images.icon.bitcoin.svg(
          fit: BoxFit.cover,
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  static Widget getCountryIcon(FiatCurrency fiatCurrency) {
    return fiatCurrency == FiatCurrency.eur
        ? SizedBox(
            width: 20,
            height: 20,
            child: ClipOval(
              child: Assets.images.icon.euro.svg(
                fit: BoxFit.cover,
                width: 20,
                height: 20,
              ),
            ),
          )
        : CountryFlag.fromCountryCode(
            FiatCurrencyHelper.toCountryCode(fiatCurrency),
            shape: const Circle(),
            width: 20,
            height: 20,
          );
  }

  static bool isBitcoinAddress(String bitcoinAddress) {
    // TODO(fix): improve me
    if (appConfig.coinType == bitcoin) {
      return (bitcoinAddress.toLowerCase().startsWith("bc") ||
              bitcoinAddress.toLowerCase().startsWith("1") ||
              bitcoinAddress.toLowerCase().startsWith("3")) &&
          bitcoinAddress.length > 24;
    } else if (appConfig.coinType == bitcoinTestnet) {
      /// testnet
      return bitcoinAddress.toLowerCase().startsWith("tb") &&
          bitcoinAddress.length > 24;
    } else {
      /// regtest
      return bitcoinAddress.toLowerCase().startsWith("bcrt") &&
          bitcoinAddress.length > 24;
    }
  }

  static String shorterBitcoinAddress(String bitcoinAddress) {
    if (isBitcoinAddress(bitcoinAddress)) {
      return "${bitcoinAddress.substring(0, 8)}...${bitcoinAddress.substring(bitcoinAddress.length - 4)}";
    }
    return bitcoinAddress;
  }

  static void showErrorDialog(String errorMessage, {VoidCallback? callback}) {
    final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      ErrorBottomSheet.show(
        context,
        errorMessage,
        callback,
      );
    }
  }

  static String getFiatCurrencySign(FiatCurrency fiatCurrency) {
    final FiatCurrencyInfo? fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency];
    return fiatCurrencyInfo != null ? fiatCurrencyInfo.sign : "\$";
  }

  static String getFiatCurrencySymbol(FiatCurrency fiatCurrency) {
    final FiatCurrencyInfo? fiatCurrencyInfo = fiatCurrency2Info[fiatCurrency];
    return fiatCurrencyInfo != null
        ? fiatCurrencyInfo.symbol.toUpperCase()
        : "USD";
  }

  static String formatDouble(
    double number, {
    int? displayDigits = defaultDisplayDigits,
  }) {
    if (displayDigits == 0 || number == number.toInt()) {
      return NumberFormat('#,###').format(number);
    }
    const String zero = '0';
    final String repeated = zero * displayDigits!;
    return NumberFormat('#,##0.$repeated').format(number);
  }

  static FiatCurrency getFiatCurrencyByName(String name) {
    return FiatCurrency.values.firstWhere((v) => v.name.toUpperCase() == name,
        orElse: () => defaultFiatCurrency);
  }

  static String formatLocaleTime(BuildContext context, int timestamp) {
    final millis = timestamp;
    final dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inDays >= 1) {
      final dateLocalFormat = DateFormat.yMMMMd(Platform.localeName).format(dt);
      return dateLocalFormat;
    } else if (difference.inHours >= 1) {
      return S.of(context).n_hour_ago(difference.inHours);
    } else {
      return S.of(context).n_minutes_ago(difference.inMinutes);
    }
  }

  static String formatLocaleTimeWithSendOrReceiveOn(
    BuildContext context,
    int timestamp, {
    required bool isSend,
  }) {
    final millis = timestamp;
    final dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inDays >= 1) {
      final dateLocalFormat = DateFormat.yMMMMd(Platform.localeName).format(dt);
      return isSend
          ? S.of(context).sent_on(dateLocalFormat)
          : S.of(context).received_on(dateLocalFormat);
    } else if (difference.inHours >= 1) {
      final String timeAgo = S.of(context).n_hour_ago(difference.inHours);
      return isSend
          ? S.of(context).sent_time_ago(timeAgo)
          : S.of(context).received_time_ago(timeAgo);
    } else {
      final String timeAgo = S.of(context).n_minutes_ago(difference.inMinutes);
      return isSend
          ? S.of(context).sent_time_ago(timeAgo)
          : S.of(context).received_time_ago(timeAgo);
    }
  }

  static bool isPrimaryAccount(String derivationPath){
    final String cleanPath = derivationPath.replaceAll("m/", "");
    return cleanPath == "84'/0'/0'";
  }
}
