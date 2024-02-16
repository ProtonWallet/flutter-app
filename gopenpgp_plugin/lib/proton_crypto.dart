import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:proton_crypto/generated_golang_bindings.dart';

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

const String _libName = 'proton_crypto';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libproton_crypto.so');
  }
  if (Platform.isWindows) {
    if (Platform.environment.containsKey('FLUTTER_TEST')){
        return DynamicLibrary.open('windows/shared/$_libName.dll');
    }
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final NativeLibrary _bindings = NativeLibrary(_dylib);
