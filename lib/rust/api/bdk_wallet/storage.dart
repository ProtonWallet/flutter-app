// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.33.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// The type `OnchainStore` is not used by any `pub` functions, thus it is ignored.
// The type `STATIC_CHANGESET` is not used by any `pub` functions, thus it is ignored.

class OnchainStoreFactory {
  final String folderPath;

  const OnchainStoreFactory.raw({
    required this.folderPath,
  });

  factory OnchainStoreFactory({required String folderPath, dynamic hint}) =>
      RustLib.instance.api
          .onchainStoreFactoryNew(folderPath: folderPath, hint: hint);

  @override
  int get hashCode => folderPath.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnchainStoreFactory &&
          runtimeType == other.runtimeType &&
          folderPath == other.folderPath;
}