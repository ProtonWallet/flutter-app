// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class ApiMnemonicUserKey {
  final String id;
  final String privateKey;
  final String salt;

  const ApiMnemonicUserKey({
    required this.id,
    required this.privateKey,
    required this.salt,
  });

  @override
  int get hashCode => id.hashCode ^ privateKey.hashCode ^ salt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiMnemonicUserKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          privateKey == other.privateKey &&
          salt == other.salt;
}

class GetAuthInfoResponseBody {
  final int code;
  final String modulus;
  final String serverEphemeral;
  final int version;
  final String salt;
  final String srpSession;
  final TwoFA twoFa;

  const GetAuthInfoResponseBody({
    required this.code,
    required this.modulus,
    required this.serverEphemeral,
    required this.version,
    required this.salt,
    required this.srpSession,
    required this.twoFa,
  });

  @override
  int get hashCode =>
      code.hashCode ^
      modulus.hashCode ^
      serverEphemeral.hashCode ^
      version.hashCode ^
      salt.hashCode ^
      srpSession.hashCode ^
      twoFa.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAuthInfoResponseBody &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          modulus == other.modulus &&
          serverEphemeral == other.serverEphemeral &&
          version == other.version &&
          salt == other.salt &&
          srpSession == other.srpSession &&
          twoFa == other.twoFa;
}

class GetAuthModulusResponse {
  final int code;
  final String modulus;
  final String modulusId;

  const GetAuthModulusResponse({
    required this.code,
    required this.modulus,
    required this.modulusId,
  });

  @override
  int get hashCode => code.hashCode ^ modulus.hashCode ^ modulusId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAuthModulusResponse &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          modulus == other.modulus &&
          modulusId == other.modulusId;
}

class MnemonicAuth {
  final int version;
  final String modulusId;
  final String salt;
  final String verifier;

  const MnemonicAuth({
    required this.version,
    required this.modulusId,
    required this.salt,
    required this.verifier,
  });

  @override
  int get hashCode =>
      version.hashCode ^ modulusId.hashCode ^ salt.hashCode ^ verifier.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MnemonicAuth &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          modulusId == other.modulusId &&
          salt == other.salt &&
          verifier == other.verifier;
}

class MnemonicUserKey {
  final String id;
  final String privateKey;

  const MnemonicUserKey({
    required this.id,
    required this.privateKey,
  });

  @override
  int get hashCode => id.hashCode ^ privateKey.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MnemonicUserKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          privateKey == other.privateKey;
}

class ProtonSrpClientProofs {
  final String clientEphemeral;
  final String clientProof;
  final String srpSession;
  final String? twoFactorCode;

  const ProtonSrpClientProofs({
    required this.clientEphemeral,
    required this.clientProof,
    required this.srpSession,
    this.twoFactorCode,
  });

  @override
  int get hashCode =>
      clientEphemeral.hashCode ^
      clientProof.hashCode ^
      srpSession.hashCode ^
      twoFactorCode.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtonSrpClientProofs &&
          runtimeType == other.runtimeType &&
          clientEphemeral == other.clientEphemeral &&
          clientProof == other.clientProof &&
          srpSession == other.srpSession &&
          twoFactorCode == other.twoFactorCode;
}

class ProtonUser {
  final String id;
  final String name;
  final BigInt usedSpace;
  final String currency;
  final int credit;
  final BigInt createTime;
  final BigInt maxSpace;
  final BigInt maxUpload;
  final int role;
  final int private;
  final int subscribed;
  final int services;
  final int delinquent;
  final String? organizationPrivateKey;
  final String email;
  final String displayName;
  final List<ProtonUserKey>? keys;
  final int mnemonicStatus;

  const ProtonUser({
    required this.id,
    required this.name,
    required this.usedSpace,
    required this.currency,
    required this.credit,
    required this.createTime,
    required this.maxSpace,
    required this.maxUpload,
    required this.role,
    required this.private,
    required this.subscribed,
    required this.services,
    required this.delinquent,
    this.organizationPrivateKey,
    required this.email,
    required this.displayName,
    this.keys,
    required this.mnemonicStatus,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      usedSpace.hashCode ^
      currency.hashCode ^
      credit.hashCode ^
      createTime.hashCode ^
      maxSpace.hashCode ^
      maxUpload.hashCode ^
      role.hashCode ^
      private.hashCode ^
      subscribed.hashCode ^
      services.hashCode ^
      delinquent.hashCode ^
      organizationPrivateKey.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      keys.hashCode ^
      mnemonicStatus.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtonUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          usedSpace == other.usedSpace &&
          currency == other.currency &&
          credit == other.credit &&
          createTime == other.createTime &&
          maxSpace == other.maxSpace &&
          maxUpload == other.maxUpload &&
          role == other.role &&
          private == other.private &&
          subscribed == other.subscribed &&
          services == other.services &&
          delinquent == other.delinquent &&
          organizationPrivateKey == other.organizationPrivateKey &&
          email == other.email &&
          displayName == other.displayName &&
          keys == other.keys &&
          mnemonicStatus == other.mnemonicStatus;
}

class ProtonUserKey {
  final String id;
  final int version;
  final String privateKey;
  final String? recoverySecret;
  final String? recoverySecretSignature;
  final String? token;
  final String fingerprint;
  final int primary;
  final int active;

  const ProtonUserKey({
    required this.id,
    required this.version,
    required this.privateKey,
    this.recoverySecret,
    this.recoverySecretSignature,
    this.token,
    required this.fingerprint,
    required this.primary,
    required this.active,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      version.hashCode ^
      privateKey.hashCode ^
      recoverySecret.hashCode ^
      recoverySecretSignature.hashCode ^
      token.hashCode ^
      fingerprint.hashCode ^
      primary.hashCode ^
      active.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtonUserKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version &&
          privateKey == other.privateKey &&
          recoverySecret == other.recoverySecret &&
          recoverySecretSignature == other.recoverySecretSignature &&
          token == other.token &&
          fingerprint == other.fingerprint &&
          primary == other.primary &&
          active == other.active;
}

class TwoFA {
  final int enabled;

  const TwoFA({
    required this.enabled,
  });

  @override
  int get hashCode => enabled.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwoFA &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled;
}

class UpdateMnemonicSettingsRequestBody {
  final List<MnemonicUserKey> mnemonicUserKeys;
  final String mnemonicSalt;
  final MnemonicAuth mnemonicAuth;

  const UpdateMnemonicSettingsRequestBody({
    required this.mnemonicUserKeys,
    required this.mnemonicSalt,
    required this.mnemonicAuth,
  });

  @override
  int get hashCode =>
      mnemonicUserKeys.hashCode ^ mnemonicSalt.hashCode ^ mnemonicAuth.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMnemonicSettingsRequestBody &&
          runtimeType == other.runtimeType &&
          mnemonicUserKeys == other.mnemonicUserKeys &&
          mnemonicSalt == other.mnemonicSalt &&
          mnemonicAuth == other.mnemonicAuth;
}