import 'package:wallet/rust/proton_api/user_settings.dart';

extension BitcoinUnitExtension on List<BitcoinUnit> {
  List<String> get toUpperCaseList {
    return map((v) => v.name.toUpperCase()).toList();
  }
}
