import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';
import 'dart:convert';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/responsive.dart';

class BitcoinPriceHomepageChart extends StatefulWidget {
  final ProtonExchangeRate exchangeRate;
  final double width;
  final double priceChange;

  const BitcoinPriceHomepageChart({
    super.key,
    required this.exchangeRate,
    required this.width,
    required this.priceChange,
  });

  @override
  BitcoinPriceHomepageChartState createState() =>
      BitcoinPriceHomepageChartState();
}

class BitcoinPriceHomepageChartState extends State<BitcoinPriceHomepageChart> {
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
  void didUpdateWidget(BitcoinPriceHomepageChart oldWidget) {
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
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Responsive.isDesktop(context)
                      ? MediaQuery.of(context).size.width * 2 / 3 - 300
                      : null,
                  padding: const EdgeInsets.only(
                    left: 8,
                  ),
                  height: 40,
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: ProtonColors.protonBlue)
                      : LineChart(
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
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: false,
                              )),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: false,
                              )),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: false,
                              )),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: false,
                              )),
                            ),
                          ),
                        ),
                ),
              ]),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 24,
          color: ProtonColors.textWeak,
        ),
      ]),
    );
  }
}
