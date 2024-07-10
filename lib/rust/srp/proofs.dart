// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class SRPProofB64 {
  final String clientEphemeral;
  final String clientProof;
  final String expectedServerProof;

  const SRPProofB64({
    required this.clientEphemeral,
    required this.clientProof,
    required this.expectedServerProof,
  });

  @override
  int get hashCode =>
      clientEphemeral.hashCode ^
      clientProof.hashCode ^
      expectedServerProof.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SRPProofB64 &&
          runtimeType == other.runtimeType &&
          clientEphemeral == other.clientEphemeral &&
          clientProof == other.clientProof &&
          expectedServerProof == other.expectedServerProof;
}

class SRPVerifierB64 {
  final int version;
  final String salt;
  final String verifier;

  const SRPVerifierB64({
    required this.version,
    required this.salt,
    required this.verifier,
  });

  @override
  int get hashCode => version.hashCode ^ salt.hashCode ^ verifier.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SRPVerifierB64 &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          salt == other.salt &&
          verifier == other.verifier;
}