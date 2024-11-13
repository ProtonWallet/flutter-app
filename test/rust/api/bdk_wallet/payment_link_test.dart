import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/rust/api/bdk_wallet/payment_link.dart';
import 'package:wallet/rust/common/network.dart';

import '../../../frb.helper.dart';
import '../../../helper.dart';

void main() {
  setUpAll(() async {
    await initTestRustLibrary();
  });
  testUnit('payment link ...', () async {
    var paymentLink = FrbPaymentLink.tryParse(
      str:
          "bitcoin:tb1qnmsyczn68t628m4uct5nqgjr7vf3w6mc0lvkfn?amount=0.00192880&label=Fermi%20Pasta&message=Thanks%20for%20your%20donation",
      network: Network.testnet,
    );
    assert(paymentLink.toAddress() ==
        "tb1qnmsyczn68t628m4uct5nqgjr7vf3w6mc0lvkfn");

    paymentLink = FrbPaymentLink.tryParse(
      str: "tb1qnmsyczn68t628m4uct5nqgjr7vf3w6mc0lvkfn",
      network: Network.testnet,
    );
    assert(paymentLink.toAddress() ==
        "tb1qnmsyczn68t628m4uct5nqgjr7vf3w6mc0lvkfn");
  });
}
