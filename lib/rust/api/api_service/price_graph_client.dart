// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../common/errors.dart';
import '../../frb_generated.dart';
import '../../proton_api/price_graph.dart';
import '../../proton_api/user_settings.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'proton_api_service.dart';

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<PriceGraphClient>>
abstract class PriceGraphClient implements RustOpaqueInterface {
  Future<PriceGraph> getGraphData(
      {required FiatCurrency fiatCurrency, required Timeframe timeframe});

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<PriceGraphClient> newInstance(
          {required ProtonApiService service}) =>
      RustLib.instance.api
          .crateApiApiServicePriceGraphClientPriceGraphClientNew(
              service: service);
}