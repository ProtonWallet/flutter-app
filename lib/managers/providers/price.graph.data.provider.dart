import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/price_graph_client.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class PriceGraphDataProvider extends DataProvider {
  /// api client
  final PriceGraphClient? priceClient;

  PriceGraphDataProvider(
    this.priceClient,
  );

  Future<PriceGraph?> getPriceGraph({
    required FiatCurrency fiatCurrency,
    required Timeframe timeFrame,
  }) async {
    return priceClient?.getGraphData(
        fiatCurrency: fiatCurrency, timeframe: timeFrame);
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}
