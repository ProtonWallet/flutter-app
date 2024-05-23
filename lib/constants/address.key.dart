import 'dart:convert';
import 'dart:typed_data';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/strings.dart';

class AddressKey {
  final String id;
  final String privateKey;
  final String passphrase;

  AddressKey({required this.id, required this.privateKey, required this.passphrase});

  String decryptBinary(String? binaryEncryptedString) {
    if (binaryEncryptedString != null) {
      Uint8List bytes = proton_crypto.decryptBinary(
          privateKey, passphrase, binaryEncryptedString.base64decode());
      String? decryptedMessage = utf8.decode(bytes);
      if (decryptedMessage != "null") {
        return decryptedMessage;
      }
    }
    return "";
  }

  String decrypt(String encryptedArmor) {
    return proton_crypto.decrypt(privateKey, passphrase, encryptedArmor);
  }

  String encrypt(String plainText) {
    return proton_crypto.encrypt(privateKey, plainText);
  }

  String encryptBinary(Uint8List data) {
    return proton_crypto.encryptBinary(privateKey, data).base64encode();
  }
}
