import 'dart:convert';
import 'dart:typed_data';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/strings.dart';

class AddressKey {
  final String id;
  final String privateKey;
  final String passphrase;

  AddressKey(
      {required this.id, required this.privateKey, required this.passphrase});

  String decryptBinary(String? binaryEncryptedString) {
    if (binaryEncryptedString != null) {
      try {
        Uint8List bytes = proton_crypto.decryptBinary(
            privateKey, passphrase, binaryEncryptedString.base64decode());
        String? decryptedMessage = utf8.decode(bytes);
        if (decryptedMessage != "null") {
          return decryptedMessage;
        }
      } catch (e) {
        return "";
      }
    }
    return "";
  }

  String decrypt(String encryptedArmor) {
    try {
      return proton_crypto.decrypt(privateKey, passphrase, encryptedArmor);
    } catch (e) {
      return "";
    }
  }

  String encrypt(String plainText) {
    try {
      return proton_crypto.encrypt(privateKey, plainText);
    } catch (e) {
      rethrow;
    }
  }

  String encryptBinary(Uint8List data) {
    try {
      return proton_crypto.encryptBinary(privateKey, data).base64encode();
    } catch (e) {
      rethrow;
    }
  }
}
