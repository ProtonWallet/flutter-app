import 'dart:convert';
import 'dart:typed_data';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;

class AddressKey {
  final String privateKey;
  final String passphrase;

  AddressKey({required this.privateKey, required this.passphrase});

  String decryptBinary(String? binaryEncryptedString) {
    if (binaryEncryptedString != null) {
      Uint8List bytes = proton_crypto.decryptBinary(
          privateKey, passphrase, base64Decode(binaryEncryptedString));
      String? decryptedMessage = utf8.decode(bytes);
      if (decryptedMessage != "null") {
        return decryptedMessage;
      }
    }
    return "";
  }

  String decrypt(String encryptedArmor) {
    return "";
  }
}
