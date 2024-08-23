import 'dart:core';

import 'package:flutter/services.dart';

class MoonPayConfiguration {
  String hostApiKey;
  String fiatCurrency;
  double fiatValue;
  String paymentMethod;
  String showAddressForm;
  String userAddress;

  MoonPayConfiguration({
    required this.hostApiKey,
    required this.fiatCurrency,
    required this.fiatValue,
    required this.paymentMethod,
    required this.showAddressForm,
    required this.userAddress,
  });

  dynamic toMap() {
    return {
      'hostApiKey': hostApiKey,
      'fiatCurrency': fiatCurrency,
      'fiatValue': fiatValue,
      'paymentMethod': paymentMethod,
      'showAddressForm': showAddressForm,
      'userAddress': userAddress,
    };
  }
}

/// Wrapper class for Ramp Flutter widget
class OnRampMoonPay {
  final _channel = const MethodChannel('me.proton.wallet/onramp.moon.pay');

  Function()? onRampClosed;

  void _handleOnClosed() {
    onRampClosed!();
  }

  Future<void> _didRecieveMethodCall(MethodCall call) async {
    switch (call.method) {
      case "moon.pay.on.closed":
        _handleOnClosed();
    }
  }

  Future<void> showMoonPay(MoonPayConfiguration configuration) async {
    _channel.setMethodCallHandler(_didRecieveMethodCall);
    await _channel.invokeMethod('moon.pay.show', configuration.toMap());
  }
}
