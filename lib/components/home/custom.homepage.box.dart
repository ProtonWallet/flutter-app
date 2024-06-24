import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/bitcoin.price.chart.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomHomePageBox extends StatelessWidget {
  final String title;
  final SvgGenImage icon;
  final double price;
  final double priceChange;
  final List<Widget> children;
  final ProtonExchangeRate exchangeRate;

  const CustomHomePageBox({
    super.key,
    required this.title,
    required this.icon,
    this.price = 0,
    this.children = const [],
    this.priceChange = 0,
    required this.exchangeRate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
        child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: ProtonColors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: Column(
              children: [
                Row(children: [
                  icon.svg(fit: BoxFit.fill, width: 44, height: 44),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            color: ProtonColors.textWeak,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(children: [
                          AnimatedFlipCounter(
                              duration: const Duration(milliseconds: 500),
                              prefix: Provider.of<UserSettingProvider>(context)
                                  .getFiatCurrencyName(
                                      fiatCurrency: exchangeRate.fiatCurrency),
                              value:
                                  ExchangeCalculator.getNotionalInFiatCurrency(
                                      exchangeRate, 100000000),
                              // value: price,
                              fractionDigits: defaultDisplayDigits,
                              textStyle: FontManager.body1Median(
                                  ProtonColors.textNorm)),
                          const SizedBox(
                            width: 8,
                          ),
                          priceChange > 0
                              ? AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 500),
                                  prefix: "▲",
                                  value: priceChange,
                                  suffix: "% (1d)",
                                  fractionDigits: 2,
                                  textStyle: FontManager.body2Regular(
                                      ProtonColors.signalSuccess))
                              : AnimatedFlipCounter(
                                  duration: const Duration(milliseconds: 500),
                                  prefix: "▼",
                                  value: priceChange,
                                  suffix: "% (1d)",
                                  fractionDigits: 2,
                                  textStyle: FontManager.body2Regular(
                                      ProtonColors.signalError)),
                        ]),
                      )
                    ],
                  ),
                ]),
                const SizedBox(
                  height: 10,
                ),
                const Divider(thickness: 0.4),

                /// bitcoin price chart
                BitcoinPriceChart(exchangeRate: exchangeRate),
                const Divider(thickness: 0.4),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: children,
                ),
                const SizedBox(
                  height: 4,
                ),
              ],
            )),
      )
    ]);
  }
}
