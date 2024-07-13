import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.homepage.dart';
import 'package:wallet/scenes/components/bottom.sheets/bitcoin.price.detail.dart';
import 'package:wallet/theme/theme.font.dart';

class BitcoinPriceBox extends StatelessWidget {
  final String title;
  final double price;
  final double priceChange;
  final ProtonExchangeRate exchangeRate;

  const BitcoinPriceBox({
    required this.title, required this.exchangeRate, super.key,
    this.price = 0,
    this.priceChange = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: 24,
            ),
            decoration: BoxDecoration(
              color: ProtonColors.white,
              border: Border(
                top: BorderSide(
                  color: ProtonColors.textHint,
                  width: 0.2,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      BitcoinPriceDetailSheet.show(
                        context,
                        exchangeRate,
                        priceChange,
                      );
                    },
                    child: Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                color: ProtonColors.textWeak,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              )),
                          exchangeRate.id == "default"
                              ? const SizedBox(
                                  width: 160,
                                  child: CardLoading(
                                    height: 16,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    margin: EdgeInsets.only(top: 4),
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(children: [
                                    AnimatedFlipCounter(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        prefix: Provider.of<
                                                UserSettingProvider>(context)
                                            .getFiatCurrencySign(
                                                fiatCurrency:
                                                    exchangeRate.fiatCurrency),
                                        thousandSeparator: ",",
                                        value: ExchangeCalculator
                                            .getNotionalInFiatCurrency(
                                                exchangeRate, 100000000),
                                        // value: price,
                                        fractionDigits: defaultDisplayDigits,
                                        textStyle: FontManager.body2Median(
                                            ProtonColors.textNorm)),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    priceChange > 0
                                        ? AnimatedFlipCounter(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            prefix: "+",
                                            value: priceChange,
                                            suffix: "% (1d)",
                                            fractionDigits: 2,
                                            textStyle: FontManager.body2Regular(
                                                ProtonColors.signalSuccess))
                                        : AnimatedFlipCounter(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            prefix: "",
                                            value: priceChange,
                                            suffix: "% (1d)",
                                            fractionDigits: 2,
                                            textStyle: FontManager.body2Regular(
                                                ProtonColors.signalError)),
                                  ]),
                                )
                        ],
                      ),
                      if (exchangeRate.id != "default")
                        Expanded(
                          child: BitcoinPriceHomepageChart(
                            exchangeRate: exchangeRate,
                            width: MediaQuery.of(context).size.width - 260,
                            priceChange: priceChange,
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            )),
      )
    ]);
  }
}
