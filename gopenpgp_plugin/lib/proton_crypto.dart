import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:proton_crypto/generated_golang_bindings.dart';

String getBinarySignatureWithContext(
    String userPrivateKey, String passphrase, Uint8List data, String context) {
  String result = "";
  using((alloc) {
    final Pointer<Uint8> pData = alloc(data.length);
    pData.asTypedList(data.length).setAll(0, data);
    result = (_bindings.getBinarySignatureWithContext(
            userPrivateKey.toNativeUtf8() as Pointer<Char>,
            passphrase.toNativeUtf8() as Pointer<Char>,
            pData as Pointer<Char>,
            data.length,
            context.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
        .toDartString();
  });
  return result;
}

bool verifyBinarySignatureWithContext(
    String userPublicKey, Uint8List data, String signature, String context) {
  bool result = false;
  using((alloc) {
    final Pointer<Uint8> pData = alloc(data.length);
    pData.asTypedList(data.length).setAll(0, data);
    result = _bindings.verifyBinarySignatureWithContext(
            userPublicKey.toNativeUtf8() as Pointer<Char>,
            pData as Pointer<Char>,
            data.length,
            signature.toNativeUtf8() as Pointer<Char>,
            context.toNativeUtf8() as Pointer<Char>) ==
        1;
  });
  return result;
}

String getSignatureWithContext(
    String userPrivateKey, String passphrase, String message, String context) {
  return (_bindings.getSignatureWithContext(
          userPrivateKey.toNativeUtf8() as Pointer<Char>,
          passphrase.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>,
          context.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

bool verifySignatureWithContext(
    String userPublicKey, String message, String signature, String context) {
  return _bindings.verifySignatureWithContext(
          userPublicKey.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>,
          signature.toNativeUtf8() as Pointer<Char>,
          context.toNativeUtf8() as Pointer<Char>) ==
      1;
}

String getSignature(String userPrivateKey, String passphrase, String message) {
  return (_bindings.getSignature(
          userPrivateKey.toNativeUtf8() as Pointer<Char>,
          passphrase.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

bool verifySignature(String userPublicKey, String message, String signature) {
  return _bindings.verifySignature(
          userPublicKey.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>,
          signature.toNativeUtf8() as Pointer<Char>) ==
      1;
}

String getArmoredPublicKey(String userPrivateKey) {
  return (_bindings.getArmoredPublicKey(
          userPrivateKey.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

String encrypt(String userPrivateKey, String message) {
  return (_bindings.encrypt(userPrivateKey.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

String encryptWithKeyRing(String userPublicKeysSepInComma, String message) {
  return (_bindings.encryptWithKeyRing(
          userPublicKeysSepInComma.toNativeUtf8() as Pointer<Char>,
          message.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

String decrypt(String userPrivateKey, String passphrase, String armor) {
  return (_bindings.decrypt(
          userPrivateKey.toNativeUtf8() as Pointer<Char>,
          passphrase.toNativeUtf8() as Pointer<Char>,
          armor.toNativeUtf8() as Pointer<Char>) as Pointer<Utf8>)
      .toDartString();
}

Uint8List decryptBinaryPGP(
    String userPrivateKey, String passphrase, String armor) {
  Uint8List unArmored = unArmor(armor);
  return decryptBinary(userPrivateKey, passphrase, unArmored);
}

Uint8List encryptBinary(String userPrivateKey, Uint8List data) {
  Uint8List result = Uint8List(0);
  using((alloc) {
    final Pointer<Uint8> pData = alloc(data.length);
    pData.asTypedList(data.length).setAll(0, data);
    BinaryResult binaryResult = _bindings.encryptBinary(
        userPrivateKey.toNativeUtf8() as Pointer<Char>,
        pData as Pointer<Char>,
        data.length);
    result = pointerToUint8List(
        binaryResult.data as Pointer<Uint8>, binaryResult.length);
  });
  return result;
}

String encryptBinaryArmor(String userPrivateKey, Uint8List data) {
  String result = "";
  using((alloc) {
    final Pointer<Uint8> pData = alloc(data.length);
    pData.asTypedList(data.length).setAll(0, data);
    Pointer<Char> goResult = _bindings.encryptBinaryArmor(
        userPrivateKey.toNativeUtf8() as Pointer<Char>,
        pData as Pointer<Char>,
        data.length);
    result = String.fromCharCodes(pointerToUint8List(goResult as Pointer<Uint8>,
        getPointerLength(goResult as Pointer<Uint8>)));
  });
  return result;
}

Uint8List decryptBinary(
    String userPrivateKey, String passphrase, Uint8List encryptedBinary) {
  Uint8List result = Uint8List(0);
  using((alloc) {
    final Pointer<Uint8> pEncryptedBinary = alloc(encryptedBinary.length);
    pEncryptedBinary
        .asTypedList(encryptedBinary.length)
        .setAll(0, encryptedBinary);
    BinaryResult binaryResult = _bindings.decryptBinary(
        userPrivateKey.toNativeUtf8() as Pointer<Char>,
        passphrase.toNativeUtf8() as Pointer<Char>,
        pEncryptedBinary as Pointer<Char>,
        encryptedBinary.length);
    result = pointerToUint8List(
        binaryResult.data as Pointer<Uint8>, binaryResult.length);
  });
  return result;
}

Uint8List pointerToUint8List(Pointer<Uint8> ptr, int length) {
  List<int> intList = ptr.asTypedList(length);
  return Uint8List.fromList(intList);
}

int getPointerLength(Pointer<Uint8> ptr) {
  int length = 0;
  // TODO:: fix me
  // ignore: deprecated_member_use
  while (ptr.elementAt(length).value != 0) {
    length++;
  }
  return length;
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

const String _libName = 'proton_crypto';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    // this is workaround. Env or have a lib in build folder is better option.
    //   we can fix it later
    if (Platform.isMacOS) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return DynamicLibrary.open(
            '${Directory.current.path}/macos/libproton_crypto.dylib');
      }
    }
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libproton_crypto.so');
  }
  if (Platform.isLinux) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DynamicLibrary.open(
          '${Directory.current.path}/linux/shared/libproton_crypto.so');
    }
    return DynamicLibrary.open('proton_crypto.so');
  }
  if (Platform.isWindows) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DynamicLibrary.open('windows/shared/$_libName.dll');
    }
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final NativeLibrary _bindings = NativeLibrary(_dylib);
