// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.33.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../common/errors.dart';
import '../../common/network.dart';
import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FrbDerivationPath>>
@sealed
class FrbDerivationPath extends RustOpaque {
  FrbDerivationPath.dcoDecode(List<dynamic> wire)
      : super.dcoDecode(wire, _kStaticData);

  FrbDerivationPath.sseDecode(int ptr, int externalSizeOnNative)
      : super.sseDecode(ptr, externalSizeOnNative, _kStaticData);

  static final _kStaticData = RustArcStaticData(
    rustArcIncrementStrongCount:
        RustLib.instance.api.rust_arc_increment_strong_count_FrbDerivationPath,
    rustArcDecrementStrongCount:
        RustLib.instance.api.rust_arc_decrement_strong_count_FrbDerivationPath,
    rustArcDecrementStrongCountPtr: RustLib
        .instance.api.rust_arc_decrement_strong_count_FrbDerivationPathPtr,
  );

  static FrbDerivationPath fromParts(
          {required int purpose,
          required Network network,
          required int accountIndex,
          dynamic hint}) =>
      RustLib.instance.api.frbDerivationPathFromParts(
          purpose: purpose,
          network: network,
          accountIndex: accountIndex,
          hint: hint);

  factory FrbDerivationPath({required String path, dynamic hint}) =>
      RustLib.instance.api.frbDerivationPathNew(path: path, hint: hint);
}