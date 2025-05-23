// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../../frb_generated.dart';
import '../../../srp/proofs.dart';
import '../../errors.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class FrbSrpClient {
  const FrbSrpClient.raw();

  static Future<SRPProofB64> generateProofs(
          {required String loginPassword,
          required int version,
          required String salt,
          required String modulus,
          required String serverEphemeral}) =>
      RustLib.instance.api
          .crateApiProtonWalletSrpSrpClientFrbSrpClientGenerateProofs(
              loginPassword: loginPassword,
              version: version,
              salt: salt,
              modulus: modulus,
              serverEphemeral: serverEphemeral);

  factory FrbSrpClient() =>
      RustLib.instance.api.crateApiProtonWalletSrpSrpClientFrbSrpClientNew();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrbSrpClient && runtimeType == other.runtimeType;
}
