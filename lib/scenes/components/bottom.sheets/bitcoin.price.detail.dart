import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';

class BitcoinPriceDetailSheet {
  static void show(
    BuildContext context,
    ProtonExchangeRate exchangeRate,
    PriceGraphDataProvider priceGraphDataProvider,
  ) {
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.backgroundSecondary,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(
                    backgroundColor: ProtonColors.backgroundNorm,
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: BitcoinPriceChart(
                exchangeRate: exchangeRate,
                priceGraphDataProvider: priceGraphDataProvider,
              ),
            ),
          ],
        ));
  }
}
