// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.21.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Future<int> addOne({required int left, required int right, dynamic hint}) =>
    RustLib.instance.api.addOne(left: left, right: right, hint: hint);

Future<int> addThree({required int left, required int right, dynamic hint}) =>
    RustLib.instance.api.addThree(left: left, right: right, hint: hint);

String greet({required String name, dynamic hint}) =>
    RustLib.instance.api.greet(name: name, hint: hint);

String helloworld({dynamic hint}) =>
    RustLib.instance.api.helloworld(hint: hint);