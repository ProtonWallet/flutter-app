// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class ApiContactEmails {
  final String id;
  final String name;
  final String email;
  final String canonicalEmail;
  final int isProton;

  const ApiContactEmails({
    required this.id,
    required this.name,
    required this.email,
    required this.canonicalEmail,
    required this.isProton,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      canonicalEmail.hashCode ^
      isProton.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiContactEmails &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          canonicalEmail == other.canonicalEmail &&
          isProton == other.isProton;
}
