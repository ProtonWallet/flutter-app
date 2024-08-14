import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.homepage.dart';
import 'package:wallet/scenes/components/bottom.sheets/bitcoin.price.detail.dart';
import 'package:wallet/theme/theme.font.dart';

class BitcoinPriceBox extends StatefulWidget {
  final String title;
  final PriceGraphDataProvider priceGraphDataProvider;
  final ProtonExchangeRate exchangeRate;

  const BitcoinPriceBox({
    required this.title,
    required this.exchangeRate,
    required this.priceGraphDataProvider,
    super.key,
  });

  @override
  BitcoinPriceBoxState createState() => BitcoinPriceBoxState();
}

class BitcoinPriceBoxState extends State<BitcoinPriceBox> {
  bool isLoading = false;

  double priceChange = 0.0;
  Timeframe timeFrame = Timeframe.oneDay;

  @override
  void didUpdateWidget(BitcoinPriceBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exchangeRate.fiatCurrency !=
        widget.exchangeRate.fiatCurrency) {
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (widget.exchangeRate.id == defaultExchangeRate.id) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    PriceGraph? priceGraph;

    try {
      priceGraph = await widget.priceGraphDataProvider.getPriceGraph(
          fiatCurrency: widget.exchangeRate.fiatCurrency, timeFrame: timeFrame);
    } catch (e) {
      logger.d(e.toString());
    }
    final List<double> prices = [];
    if (priceGraph != null) {
      for (DataPoint dataPoint in priceGraph.graphData) {
        final double price = dataPoint.exchangeRate / widget.exchangeRate.cents;
        prices.add(price);
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
        if (prices.isNotEmpty) {
          priceChange = (prices.last - prices.first) / prices.first * 100;
        }
      });
    }
  }

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
                      if (widget.exchangeRate.id != defaultExchangeRate.id ||
                          isLoading) {
                        BitcoinPriceDetailSheet.show(
                          context,
                          widget.exchangeRate,
                          widget.priceGraphDataProvider,
                        );
                      }
                    },
                    child: Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title,
                              style: TextStyle(
                                color: ProtonColors.textWeak,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              )),
                          (widget.exchangeRate.id == defaultExchangeRate.id ||
                                  isLoading)
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
                                        prefix:
                                            Provider.of<UserSettingProvider>(
                                                    context)
                                                .getFiatCurrencySign(
                                                    fiatCurrency: widget
                                                        .exchangeRate
                                                        .fiatCurrency),
                                        thousandSeparator: ",",
                                        value: ExchangeCalculator
                                            .getNotionalInFiatCurrency(
                                                widget.exchangeRate,
                                                btc2satoshi),
                                        // value: price,
                                        fractionDigits:
                                            ExchangeCalculator.getDisplayDigit(
                                                widget.exchangeRate),
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
                      if (widget.exchangeRate.id != defaultExchangeRate.id ||
                          isLoading)
                        Expanded(
                          child: BitcoinPriceHomepageChart(
                            exchangeRate: widget.exchangeRate,
                            priceGraphDataProvider:
                                widget.priceGraphDataProvider,
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
