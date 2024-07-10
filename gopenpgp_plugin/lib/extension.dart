import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// extensions
extension StringUtf8CharPointer on String {
  Pointer<Char> toNativeChar(Allocator allocator) {
    return toNativeUtf8(allocator: allocator) as Pointer<Char>;
  }
}

extension CharPointerString on Pointer<Char> {
  String charToDartString() {
    return (this as Pointer<Utf8>).toDartString();
  }

  Uint8List charToUint8List(int length) {
    final ptr = this as Pointer<Uint8>;
    List<int> intList = ptr.asTypedList(length);
    return Uint8List.fromList(intList);
  }
}
