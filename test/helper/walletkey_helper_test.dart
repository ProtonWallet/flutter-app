import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';

import '../frb.helper.dart';
import '../helper.dart';

void main() {
  group('WalletKeyHelper', () {
    setUpAll(() async {
      await initTestRustLibrary();
    });
    testUnit('restore walletKey and decrypt', () async {
      const txid =
          "6bbfc06ef911e4b2fffe1150fa8f3729b3ee52c78ef21093b5ae45544ff690fa";

      final out = FrbTransitionLayer.getHmacHashedString(
        base64SecureKey: "MmI0OGRmZjQ2YzNhN2YyYmQ2NjFlNWEzNzljYTQwZGQ=",
        transactionId: txid,
      );
      assert(out == "O4f/ePTaBh8tNsiDaJRqQfBov6/+UU2FenCKcK14MGM=");
    });
  });
}
