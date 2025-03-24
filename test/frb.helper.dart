import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/rust/frb_generated.dart';

// Reusable helper function for setting up the Rust library
@isTest
Future<void> initTestRustLibrary({
  String stem = 'proton_wallet_common',
  String ioDirectory = 'rust/target/debug/',
  String webPrefix = "",
}) async {
  final config = ExternalLibraryLoaderConfig(
    stem: stem,
    ioDirectory: ioDirectory,
    webPrefix: webPrefix,
  );

  // Load the external Rust library
  final externalLib = await loadExternalLibrary(config);

  // Initialize the Rust library
  RustLib.init(externalLibrary: externalLib);

  // Verify that the library has been initialized
  assert(RustLib.instance.initialized);
}
