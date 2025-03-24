import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';

extension FrbAddressDetailsExt on FrbAddressDetails {
  String get shortAddress {
    return CommonHelper.shorterBitcoinAddress(
      address,
      leftLength: 12,
      rightLength: 12,
    );
  }
}
