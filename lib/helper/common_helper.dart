import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
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
    var snackBar = SnackBar(
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

  static bool isBitcoinAddress(String bitcoinAddress) {
    return (bitcoinAddress.toLowerCase().startsWith("tb") ||
            bitcoinAddress.toLowerCase().startsWith("bc") ||
            bitcoinAddress.toLowerCase().startsWith("1")) &&
        bitcoinAddress.length > 24;
  }

  static void showErrorDialog(String errorMessage) {
    BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.of(context).something_went_wrong),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                child: Text(S.of(context).ok),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text(S.of(context).report_a_problem),
                onPressed: () {
                  Share.share(errorMessage,
                      subject: S.of(context).something_went_wrong);
                },
              ),
            ],
          );
        },
      );
    }
  }

  static FiatCurrency getFiatCurrencyByName(String name) {
    return FiatCurrency.values.firstWhere((v) => v.name.toUpperCase() == name,
        orElse: () => defaultFiatCurrency);
  }

  static String formatLocaleTime(BuildContext context, int timestamp) {
    var millis = timestamp;
    var dt = DateTime.fromMillisecondsSinceEpoch(millis * 1000);
    var now = DateTime.now();
    var difference = now.difference(dt);
    if (difference.inDays >= 1) {
      var dateLocalFormat =
          DateFormat.yMd(Platform.localeName).add_jm().format(dt);
      return dateLocalFormat.toString();
    } else if (difference.inHours >= 1) {
      return S.of(context).n_hour_ago(difference.inHours.toInt());
    } else {
      return S.of(context).n_minutes_ago(difference.inMinutes.toInt());
    }
  }
}
