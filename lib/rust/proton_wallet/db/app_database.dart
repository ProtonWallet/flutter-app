// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'dao/account_dao.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class AppDatabase {
  final int version;
  final int resetVersion;
  final bool dbReset;
  final AccountDao? accountDao;

  const AppDatabase({
    required this.version,
    required this.resetVersion,
    required this.dbReset,
    this.accountDao,
  });

  @override
  int get hashCode =>
      version.hashCode ^
      resetVersion.hashCode ^
      dbReset.hashCode ^
      accountDao.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppDatabase &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          resetVersion == other.resetVersion &&
          dbReset == other.dbReset &&
          accountDao == other.accountDao;
}