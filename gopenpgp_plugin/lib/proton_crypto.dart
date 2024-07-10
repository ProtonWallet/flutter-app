import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:proton_crypto/exception.dart';
import 'package:proton_crypto/extension.dart';
import 'package:proton_crypto/library.dart';

class VerifyCleartextMessagResult {
  var verified = false;
  var message = "";

  VerifyCleartextMessagResult(this.verified, this.message);
}

// getBinarySignatureWithContext
String getBinarySignatureWithContext(
  String userPrivateKey,
  String passphrase,
  Uint8List data,
  String context,
) {
  String result = "";
  using((arena) {
    final Pointer<Uint8> dataPtr = arena(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final passphrasePtr = passphrase.toNativeChar(arena);
    final contextPtr = context.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    var goResult = bindings.getBinarySignatureWithContext(
      privateKeyPtr,
      passphrasePtr,
      dataPtr as Pointer<Char>,
      data.length,
      contextPtr,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// verifyCleartextMessageArmored
VerifyCleartextMessagResult verifyCleartextMessageArmored(
  String userPublicKey,
  String signature,
) {
  VerifyCleartextMessagResult res = VerifyCleartextMessagResult(false, "");
  using((arena) {
    final publicKeyPtr = userPublicKey.toNativeChar(arena);
    final signaturePtr = signature.toNativeChar(arena);
    var goResult = bindings.verifyCleartextMessageArmored(
      publicKeyPtr,
      signaturePtr,
    );
    res.message = goResult.r0.charToDartString();
    res.verified = goResult.r1 == 1;
  });
  return res;
}

// verifyBinarySignatureWithContext
bool verifyBinarySignatureWithContext(
  String userPublicKey,
  Uint8List data,
  String signature,
  String context,
) {
  bool result = false;
  using((arena) {
    final Pointer<Uint8> dataPtr = arena(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);

    final publicKeyPtr = userPublicKey.toNativeChar(arena);
    final signaturePtr = signature.toNativeChar(arena);
    final contextPtr = context.toNativeChar(arena);

    var goResult = bindings.verifyBinarySignatureWithContext(
      publicKeyPtr,
      dataPtr as Pointer<Char>,
      data.length,
      signaturePtr,
      contextPtr,
    );
    result = goResult == 1;
  });
  return result;
}

// getSignatureWithContext
String getSignatureWithContext(
  String userPrivateKey,
  String passphrase,
  String message,
  String context,
) {
  String result = "";
  using((arena) {
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final passphrasePtr = passphrase.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final contextPtr = context.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();
    var goResult = bindings.getSignatureWithContext(
      privateKeyPtr,
      passphrasePtr,
      messagePtr,
      contextPtr,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// verifySignatureWithContext
bool verifySignatureWithContext(
  String userPublicKey,
  String message,
  String signature,
  String context,
) {
  bool result = false;
  using((arena) {
    final publicKeyPtr = userPublicKey.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final signaturePtr = signature.toNativeChar(arena);
    final contextPtr = context.toNativeChar(arena);

    var goResult = bindings.verifySignatureWithContext(
      publicKeyPtr,
      messagePtr,
      signaturePtr,
      contextPtr,
    );
    result = goResult == 1;
  });
  return result;
}

// getSignature
String getSignature(
  String userPrivateKey,
  String passphrase,
  String message,
) {
  String result = "";
  using((arena) {
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final passphrasePtr = passphrase.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();
    var goResult = bindings.getSignature(
      privateKeyPtr,
      passphrasePtr,
      messagePtr,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// verifySignature
bool verifySignature(
  String userPublicKey,
  String message,
  String signature,
) {
  bool result = false;
  using((arena) {
    final publicKeyPtr = userPublicKey.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final signaturePtr = signature.toNativeChar(arena);
    var goResult = bindings.verifySignature(
      publicKeyPtr,
      messagePtr,
      signaturePtr,
    );
    result = goResult == 1;
  });
  return result;
}

// getArmoredPublicKey
String getArmoredPublicKey(String userPrivateKey) {
  String result = "";
  using((arena) {
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();
    var goResult = bindings.getArmoredPublicKey(privateKeyPtr, errPtr);
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// encrypt
String encrypt(String userPrivateKey, String message) {
  String result = "";
  using((arena) {
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();
    var goResult = bindings.encrypt(privateKeyPtr, messagePtr, errPtr);
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// encryptWithKeyRing
String encryptWithKeyRing(String userPublicKeysSepInComma, String message) {
  String result = "";
  using((arena) {
    final publicKeysSepInCommaPtr =
        userPublicKeysSepInComma.toNativeChar(arena);
    final messagePtr = message.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    var goResult = bindings.encryptWithKeyRing(
      publicKeysSepInCommaPtr,
      messagePtr,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// decrypt
String decrypt(
  String userPrivateKey,
  String passphrase,
  String armor,
) {
  String result = "";
  using((arena) {
    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final passphrasePtr = passphrase.toNativeChar(arena);
    final armorPtr = armor.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();
    var goResult = bindings.decrypt(
      privateKeyPtr,
      passphrasePtr,
      armorPtr,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// decryptBinaryPGP
Uint8List decryptBinaryPGP(
  String userPrivateKey,
  String passphrase,
  String armor,
) {
  Uint8List unArmored = unArmor(armor);
  return decryptBinary(userPrivateKey, passphrase, unArmored);
}

// encryptBinary
Uint8List encryptBinary(String userPrivateKey, Uint8List data) {
  Uint8List result = Uint8List(0);
  using((arena) {
    final Pointer<Uint8> dataPtr = arena(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);

    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    var goResult = bindings.encryptBinary(
      privateKeyPtr,
      dataPtr as Pointer<Char>,
      data.length,
      errPtr,
    );

    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.data.charToUint8List(goResult.length);
    }
  });
  return result;
}

// encryptBinaryArmor
String encryptBinaryArmor(String userPrivateKey, Uint8List data) {
  String result = "";
  using((arena) {
    final Pointer<Uint8> dataPtr = arena(data.length);
    dataPtr.asTypedList(data.length).setAll(0, data);

    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    var goResult = bindings.encryptBinaryArmor(
      privateKeyPtr,
      dataPtr as Pointer<Char>,
      data.length,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

// decryptBinary
Uint8List decryptBinary(
  String userPrivateKey,
  String passphrase,
  Uint8List encryptedBinary,
) {
  Uint8List result = Uint8List(0);
  using((arena) {
    final Pointer<Uint8> dataPtr = arena(encryptedBinary.length);
    dataPtr.asTypedList(encryptedBinary.length).setAll(0, encryptedBinary);

    final privateKeyPtr = userPrivateKey.toNativeChar(arena);
    final passphrasePtr = passphrase.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    var goResult = bindings.decryptBinary(
      privateKeyPtr,
      passphrasePtr,
      dataPtr as Pointer<Char>,
      encryptedBinary.length,
      errPtr,
    );
    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.data.charToUint8List(goResult.length);
    }
  });
  return result;
}

/// change private key password
String changePrivateKeyPassword(
  String privateKey,
  String oldPassphrase,
  String newPassphrase,
) {
  String result = "";
  using((arena) {
    final privateKeyPtr = privateKey.toNativeChar(arena);
    final oldPassphrasePtr = oldPassphrase.toNativeChar(arena);
    final newPassphrasePtr = newPassphrase.toNativeChar(arena);
    final Pointer<Pointer<Char>> errPtr = arena<Pointer<Char>>();

    Pointer<Char> goResult = bindings.changePrivateKeyPassphrase(
      privateKeyPtr,
      oldPassphrasePtr,
      newPassphrasePtr,
      errPtr,
    );

    if (errPtr.value != nullptr) {
      final errorMessage = errPtr.value.charToDartString();
      throw CryptoException.from(errorMessage);
    } else {
      result = goResult.charToDartString();
    }
  });
  return result;
}

Uint8List unArmor(String armoredMessage) {
  Uint8List result = Uint8List(0);
  int beginIndex = armoredMessage.indexOf('-----BEGIN PGP MESSAGE-----');
  if (beginIndex == -1) {
    return result;
  }

  int endIndex =
      armoredMessage.indexOf('-----END PGP MESSAGE-----', beginIndex);
  if (endIndex == -1) {
    return result;
  }

  String body = armoredMessage.substring(
      beginIndex + '-----BEGIN PGP MESSAGE-----'.length, endIndex);
  body = body.trim();
  if (!body.contains("\n\n")) {
    return result;
  }
  body = body.split("\n\n")[1];
  List<String> lines = body.split('\n');
  lines.removeLast();
  body = lines.join('');
  while (body.length % 4 != 0) {
    body += "=";
  }
  result = base64Decode(body);
  return result;
}
