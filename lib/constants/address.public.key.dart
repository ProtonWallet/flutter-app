import 'dart:convert';
import 'dart:typed_data';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/strings.dart';

class AddressPublicKey {
  final String publicKey;

  AddressPublicKey({required this.publicKey});


  String encrypt(String plainText) {
    return proton_crypto.encrypt(publicKey, plainText);
  }

  String encryptBinary(Uint8List data) {
    return proton_crypto.encryptBinary(publicKey, data).base64encode();
  }

  static String encryptWithKeys(List<AddressPublicKey> publicKeys, String plainText){
    String userPublicKeysSepInComma = publicKeys.map((e) => e.publicKey).toList().join(",");
    return proton_crypto.encryptWithKeyRing(userPublicKeysSepInComma, plainText);
  }
}
