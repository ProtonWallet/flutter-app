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
    return toString().split('.').last;
  }
}
