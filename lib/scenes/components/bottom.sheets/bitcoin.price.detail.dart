import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/theme/theme.font.dart';

class BitcoinPriceDetailSheet {
  static void show(
    BuildContext context,
    ProtonExchangeRate exchangeRate,
    double priceChange,
  ) {
    HomeModalBottomSheet.show(context,
        backgroundColor: ProtonColors.white,
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).btc_price,
                      style: FontManager.body2Regular(ProtonColors.textHint),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    AnimatedFlipCounter(
                        duration: const Duration(milliseconds: 500),
                        prefix: Provider.of<UserSettingProvider>(
                          context,
                          listen: false,
                        ).getFiatCurrencySign(
                            fiatCurrency: exchangeRate.fiatCurrency),
                        value: ExchangeCalculator.getNotionalInFiatCurrency(
                            exchangeRate, 100000000),
                        // value: price,
                        fractionDigits: defaultDisplayDigits,
                        textStyle:
                            FontManager.titleHeadline(ProtonColors.textNorm)),
                    const SizedBox(
                      height: 2,
                    ),
                    priceChange > 0
                        ? AnimatedFlipCounter(
                            duration: const Duration(milliseconds: 500),
                            prefix: "+",
                            value: priceChange,
                            suffix: "% (1d)",
                            fractionDigits: 2,
                            textStyle: FontManager.body2Regular(
                                ProtonColors.signalSuccess))
                        : AnimatedFlipCounter(
                            duration: const Duration(milliseconds: 500),
                            prefix: "-",
                            value: priceChange,
                            suffix: "% (1d)",
                            fractionDigits: 2,
                            textStyle: FontManager.body2Regular(
                                ProtonColors.signalError)),
                    const SizedBox(
                      height: 8,
                    ),
                    BitcoinPriceChart(
                      exchangeRate: exchangeRate,
                      priceChange: priceChange,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ]),
            ),
          ],
        ));
  }
}
