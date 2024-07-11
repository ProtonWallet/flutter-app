import 'dart:ffi';
import 'dart:io';

import 'package:proton_crypto/generated_golang_bindings.dart';

const String _libName = 'proton_crypto';

/// The dynamic library in which the symbols for [NativeAddBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    // this is workaround. Env or have a lib in build folder is better option.
    //   we can fix it later
    if (Platform.isMacOS) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return DynamicLibrary.open(
            '${Directory.current.path}/macos/libs/libproton_crypto.dylib');
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
final NativeLibrary bindings = NativeLibrary(_dylib);
