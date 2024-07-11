import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/theme/theme.font.dart';

enum BitcoinPriceChartDataRange {
  past1Day,
  past7Days,
  past1Month,
  past6Month,
  past1Year,
}

class BitcoinPriceChart extends StatefulWidget {
  final ProtonExchangeRate exchangeRate;
  final double priceChange;

  const BitcoinPriceChart({
    super.key,
    required this.exchangeRate,
    required this.priceChange,
  });

  @override
  BitcoinPriceChartState createState() => BitcoinPriceChartState();
}

class BitcoinPriceChartState extends State<BitcoinPriceChart> {
  List<FlSpot> dataPoints = [];
  bool isLoading = true;
  double percentile0 = 0.0;
  double percentile25 = 0.0;
  double percentile100 = 0.0;
  double percentile75 = 0.0;
  BitcoinPriceChartDataRange dataRange = BitcoinPriceChartDataRange.past1Day;
  List<BitcoinPriceChartDataRange> dataRangeOptions = [
    BitcoinPriceChartDataRange.past1Day,
    BitcoinPriceChartDataRange.past7Days,
    BitcoinPriceChartDataRange.past1Month,
    BitcoinPriceChartDataRange.past6Month,
    BitcoinPriceChartDataRange.past1Year,
  ];

  @override
  void didUpdateWidget(BitcoinPriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exchangeRate.fiatCurrency !=
        widget.exchangeRate.fiatCurrency) {
      setState(() {
        fetchData();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    Response? response;
    switch (dataRange) {
      case BitcoinPriceChartDataRange.past1Day:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1h&limit=24'));
        break;
      case BitcoinPriceChartDataRange.past7Days:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1h&limit=168'));
        break;
      case BitcoinPriceChartDataRange.past1Month:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=30'));
        break;
      case BitcoinPriceChartDataRange.past6Month:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=180'));
        break;
      case BitcoinPriceChartDataRange.past1Year:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=365'));
        break;
    }
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      List<FlSpot> spots = [];
      int index = 0;

      /// TODO:: fix logic here
      double rate2Fiat = 1.0;
      int amountInSatoshi = 10000;
      if (widget.exchangeRate.fiatCurrency != FiatCurrency.usd) {
        ProtonExchangeRate exchangeRateInUSD =
            await ExchangeRateService.getExchangeRate(FiatCurrency.usd);
        rate2Fiat = ExchangeCalculator.getNotionalInFiatCurrency(
                widget.exchangeRate, amountInSatoshi) /
            ExchangeCalculator.getNotionalInFiatCurrency(
                exchangeRateInUSD, amountInSatoshi);
      }
      List<double> values = [];
      for (var data in json) {
        double bitcoinNotionalInFiat = double.parse(data[4]) * rate2Fiat;
        spots.add(FlSpot(
          index.toDouble(),
          double.parse(bitcoinNotionalInFiat.toStringAsFixed(2)),
        ));
        values.add(bitcoinNotionalInFiat);
        index++;
      }

      if (mounted) {
        setState(() {
          dataPoints = spots;
          isLoading = false;
          if (values.isNotEmpty) {
            values.sort();
            percentile25 = values[(values.length * 0.25).floor()];
            percentile0 = values[(values.length * 0.0).floor()];
            percentile75 = values[(values.length * 0.75).floor()];
            percentile100 = values[values.length - 1];
          }
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Column(children: [
        const SizedBox(
          height: 6,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
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
                            isCurved: false,
                            barWidth: 2,
                            dotData: const FlDotData(
                              show: false,
                            ),
                            color: widget.priceChange >= 0
                                ? ProtonColors.signalSuccess
                                : ProtonColors.signalError,
                          ),
                        ],
                        borderData: FlBorderData(
                          show: false,
                          // border: Border(
                          //   left: BorderSide(
                          //     width: 1.0,
                          //     color: ProtonColors.textWeak,
                          //   ),
                          // ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor: ProtonColors.white,
                              tooltipBorder: BorderSide(
                                width: 1.0,
                                color: ProtonColors.textWeak,
                              )),
                          handleBuiltInTouches: true,
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
                                show: false,
                                alignment: Alignment.topRight,
                              ),
                            ),
                            HorizontalLine(
                              y: percentile100,
                              dashArray: [5, 5],
                              color: ProtonColors.textHint,
                              strokeWidth: 0.4,
                              label: HorizontalLineLabel(
                                show: false,
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
                                  style: FontManager.captionRegular(
                                    ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile100.ceil() == value.ceil()) {
                                return Text(
                                  percentile100.toStringAsFixed(0),
                                  style: FontManager.captionRegular(
                                    ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile25.ceil() == value.ceil()) {
                                return Text(
                                  percentile25.toStringAsFixed(0),
                                  style: FontManager.captionRegular(
                                    ProtonColors.textWeak,
                                  ),
                                );
                              }
                              if (percentile75.ceil() == value.ceil()) {
                                return Text(
                                  percentile75.toStringAsFixed(0),
                                  style: FontManager.captionRegular(
                                    ProtonColors.textWeak,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: 50,
                          )),
                          bottomTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                            showTitles: false,
                          )),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 40,
          child: Center(
            child: ChipsChoice<BitcoinPriceChartDataRange>.single(
              value: dataRange,
              onChanged: (val) => setState(() {
                if (val != dataRange) {
                  dataRange = val;
                  fetchData();
                }
              }),
              choiceItems:
                  C2Choice.listFrom<BitcoinPriceChartDataRange, String>(
                source: ["1D", "7D", "1M", "6M", "1Y"],
                value: (i, v) => dataRangeOptions[i],
                label: (i, v) => v,
                tooltip: (i, v) => v,
              ),
              padding: EdgeInsets.zero,
              choiceCheckmark: false,
              choiceStyle: C2ChipStyle.filled(
                selectedStyle: C2ChipStyle(
                  backgroundColor: ProtonColors.textHint,
                  foregroundStyle: FontManager.body2Regular(
                    ProtonColors.white,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                ),
                color: ProtonColors.white,
                foregroundStyle: FontManager.body2Regular(
                  ProtonColors.textNorm,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
