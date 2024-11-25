// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class AllKeyAddressKey {
  final int flags;
  final String publicKey;
  final int source;

  const AllKeyAddressKey({
    required this.flags,
    required this.publicKey,
    required this.source,
  });

  @override
  int get hashCode => flags.hashCode ^ publicKey.hashCode ^ source.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllKeyAddressKey &&
          runtimeType == other.runtimeType &&
          flags == other.flags &&
          publicKey == other.publicKey &&
          source == other.source;
}

class ProtonAddress {
  final String id;
  final String? domainId;
  final String email;
  final int status;
  final int type;
  final int receive;
  final int send;
  final String displayName;
  final List<ProtonAddressKey>? keys;

  const ProtonAddress({
    required this.id,
    this.domainId,
    required this.email,
    required this.status,
    required this.type,
    required this.receive,
    required this.send,
    required this.displayName,
    this.keys,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      domainId.hashCode ^
      email.hashCode ^
      status.hashCode ^
      type.hashCode ^
      receive.hashCode ^
      send.hashCode ^
      displayName.hashCode ^
      keys.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtonAddress &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          domainId == other.domainId &&
          email == other.email &&
          status == other.status &&
          type == other.type &&
          receive == other.receive &&
          send == other.send &&
          displayName == other.displayName &&
          keys == other.keys;
}

class ProtonAddressKey {
  final String id;
  final int version;
  final String publicKey;
  final String? privateKey;
  final String? token;
  final String? signature;
  final int primary;
  final int active;
  final int flags;

  const ProtonAddressKey({
    required this.id,
    required this.version,
    required this.publicKey,
    this.privateKey,
    this.token,
    this.signature,
    required this.primary,
    required this.active,
    required this.flags,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      version.hashCode ^
      publicKey.hashCode ^
      privateKey.hashCode ^
      token.hashCode ^
      signature.hashCode ^
      primary.hashCode ^
      active.hashCode ^
      flags.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtonAddressKey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          version == other.version &&
          publicKey == other.publicKey &&
          privateKey == other.privateKey &&
          token == other.token &&
          signature == other.signature &&
          primary == other.primary &&
          active == other.active &&
          flags == other.flags;
}
