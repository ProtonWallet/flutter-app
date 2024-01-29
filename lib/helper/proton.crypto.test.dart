import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../ffi_golang/generated_go_bindings.dart';

String encrypt(Pointer<Utf8> userPrivateKey, Pointer<Utf8> message) =>
    (_bindings.encrypt(
                userPrivateKey as Pointer<Char>, message as Pointer<Char>)
            as Pointer<Utf8>)
        .toDartString();

String decrypt(Pointer<Utf8> userPrivateKey, Pointer<Utf8> passphrase,
        Pointer<Utf8> armor) =>
    (_bindings.decrypt(
            userPrivateKey as Pointer<Char>,
            passphrase as Pointer<Char>,
            armor as Pointer<Char>) as Pointer<Utf8>)
        .toDartString();

final DynamicLibrary _dylib = () {
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('proton_crypto.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('lib/dynamic_libs/proton_crypto.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();
final ProtonCrypto _bindings = ProtonCrypto(_dylib);
