import 'dart:typed_data';

import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';

class WalletKeyHelper {
  /// cryptographically secure pseudo-random number generation (CSPRNG)
  static Uint8List getSecureRandom(BigInt length) {
    return FrbWalletKeyHelper.getSecureRandom(length: length);
  }
}
