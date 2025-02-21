import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';

class BitcoinPriceChart extends StatefulWidget {
  final ProtonExchangeRate exchangeRate;
  final PriceGraphDataProvider priceGraphDataProvider;
  final Timeframe defaultTimeFrame;

  const BitcoinPriceChart({
    required this.exchangeRate,
    required this.priceGraphDataProvider,
    this.defaultTimeFrame = Timeframe.oneDay,
    super.key,
  });

  @override
  BitcoinPriceChartState createState() => BitcoinPriceChartState();
}

class BitcoinPriceChartState extends State<BitcoinPriceChart> {
  List<FlSpot> dataPoints = [];
  bool isLoading = true;
  double priceChange = 0.0;
  double percentile0 = 0.0;
  double percentile25 = 0.0;
  double percentile100 = 0.0;
  double percentile75 = 0.0;
  String dataRangeString = "1D";
  Timeframe timeFrame = Timeframe.oneDay;
  final dataRangeOptions = [
    Timeframe.oneDay,
    Timeframe.oneWeek,
    Timeframe.oneMonth,
  ];

  @override
  void didUpdateWidget(BitcoinPriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exchangeRate.fiatCurrency !=
        widget.exchangeRate.fiatCurrency) {
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    timeFrame = widget.defaultTimeFrame;
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    switch (timeFrame) {
      case Timeframe.oneDay:
        dataRangeString = "1D";
      case Timeframe.oneWeek:
        dataRangeString = "7D";
      case Timeframe.oneMonth:
        dataRangeString = "1M";
      case Timeframe.unsupported:
        dataRangeString = "1D";
    }

    PriceGraph? priceGraph;
    try {
      priceGraph = await widget.priceGraphDataProvider.getPriceGraph(
        fiatCurrency: widget.exchangeRate.fiatCurrency,
        timeFrame: timeFrame,
      );
    } catch (e) {
      logger.d(e.toString());
    }
    final List<double> prices = [];
    final List<FlSpot> spots = [];
    int index = 0;
    if (priceGraph != null) {
      for (final dataPoint in priceGraph.graphData) {
        final price = dataPoint.exchangeRate / widget.exchangeRate.cents;
        prices.add(price);
        spots.add(
          FlSpot(index.toDouble(), price),
        );
        index++;
      }
    }

    if (mounted) {
      setState(() {
        dataPoints = spots;
        isLoading = false;
        if (prices.isNotEmpty) {
          priceChange = (prices.last - prices.first) / prices.first * 100;
          prices.sort();
          percentile25 = prices[(prices.length * 0.25).floor()];
          percentile0 = prices[(prices.length * 0.0).floor()];
          percentile75 = prices[(prices.length * 0.75).floor()];
          percentile100 = prices[prices.length - 1];
        }
      });
    }
  }

  Widget buildChart(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Column(children: [
        const SizedBox(height: 6),
        Container(
          width: context.width,
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          height: 140,
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(color: ProtonColors.protonBlue)
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
                            dotData: const FlDotData(
                              show: false,
                            ),
                            color: priceChange >= 0
                                ? ProtonColors.notificationSuccess
                                : ProtonColors.notificationError,
                          ),
                        ],
                        borderData: FlBorderData(
                          show: false,
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => ProtonColors.textInverted,
                              tooltipBorder: BorderSide(
                                color: ProtonColors.textWeak,
                              )),
                        ),
                        gridData: const FlGridData(
                          drawVerticalLine: false,
                          drawHorizontalLine: false,
                        ),
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: percentile0,
                              dashArray: [5, 5],
                              color: ProtonColors.textHint,
                              strokeWidth: 0.4,
                              label: HorizontalLineLabel(
                                alignment: Alignment.topRight,
                              ),
                            ),
                            HorizontalLine(
                              y: percentile100,
                              dashArray: [5, 5],
                              color: ProtonColors.textHint,
                              strokeWidth: 0.4,
                              label: HorizontalLineLabel(
                                alignment: Alignment.topRight,
                              ),
                            ),
                          ],
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, titleMeta) {
                              if (percentile0.ceil() == value.ceil()) {
                                return Text(
                                  percentile0.toStringAsFixed(0),
                                  style: ProtonStyles.captionRegular(
                                    color: ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile100.ceil() == value.ceil()) {
                                return Text(
                                  percentile100.toStringAsFixed(0),
                                  style: ProtonStyles.captionRegular(
                                    color: ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile25.ceil() == value.ceil()) {
                                return Text(
                                  percentile25.toStringAsFixed(0),
                                  style: ProtonStyles.captionRegular(
                                    color: ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile75.ceil() == value.ceil()) {
                                return Text(
                                  percentile75.toStringAsFixed(0),
                                  style: ProtonStyles.captionRegular(
                                    color: ProtonColors.textWeak,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 50,
                          )),
                          bottomTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: context.width,
          height: 40,
          child: Center(
            child: ChipsChoice<Timeframe>.single(
              value: timeFrame,
              onChanged: (val) => setState(() {
                if (val != timeFrame) {
                  timeFrame = val;
                  fetchData();
                }
              }),
              choiceItems: C2Choice.listFrom<Timeframe, String>(
                source: ["1D", "7D", "1M"],
                value: (i, v) => dataRangeOptions[i],
                label: (i, v) => v,
                tooltip: (i, v) => v,
              ),
              padding: EdgeInsets.zero,
              choiceStyle: C2ChipStyle.filled(
                selectedStyle: C2ChipStyle(
                  backgroundColor: ProtonColors.textHint,
                  foregroundStyle: ProtonStyles.body2Regular(
                    color: ProtonColors.textInverted,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                ),
                color: ProtonColors.textInverted,
                foregroundStyle: ProtonStyles.body2Regular(
                  color: ProtonColors.textNorm,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: defaultPadding),
      Text(
        S.of(context).btc_price,
        style: ProtonStyles.body2Medium(color: ProtonColors.textHint),
        textAlign: TextAlign.left,
      ),
      const SizedBox(height: 4),
      AnimatedFlipCounter(
        duration: const Duration(milliseconds: 500),
        thousandSeparator: ",",
        prefix: CommonHelper.getFiatCurrencySign(
          widget.exchangeRate.fiatCurrency,
        ),
        value: ExchangeCalculator.getNotionalInFiatCurrency(
          widget.exchangeRate,
          btc2satoshi,
        ),
        // value: price,
        fractionDigits: ExchangeCalculator.getDisplayDigit(
          widget.exchangeRate,
        ),
        textStyle: ProtonStyles.subheadline(
          color: ProtonColors.textNorm,
          fontSize: 24,
        ),
      ),
      const SizedBox(height: 4),
      priceChange > 0
          ? AnimatedFlipCounter(
              duration: const Duration(milliseconds: 500),
              prefix: "+",
              value: priceChange,
              suffix: "% ($dataRangeString)",
              fractionDigits: 2,
              textStyle: ProtonStyles.body2Medium(
                color: ProtonColors.notificationSuccess,
              ))
          : AnimatedFlipCounter(
              duration: const Duration(milliseconds: 500),
              prefix: "",
              value: priceChange,
              suffix: "% ($dataRangeString)",
              fractionDigits: 2,
              textStyle: ProtonStyles.body2Medium(
                color: ProtonColors.notificationError,
              )),
      const SizedBox(height: 8),
      buildChart(context),
      const SizedBox(height: 8),
    ]);
  }
}
