import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/exchange.caculator.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';
import 'package:wallet/scenes/core/responsive.dart';

class BitcoinPriceHomepageChart extends StatefulWidget {
  final ProtonExchangeRate exchangeRate;
  final double width;
  final double priceChange;

  const BitcoinPriceHomepageChart({
    required this.exchangeRate,
    required this.width,
    required this.priceChange,
    super.key,
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
      // TODO(check): this code doesnt look right
      // ignore: unnecessary_lambdas
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
      case BitcoinPriceChartDataRange.past7Days:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1h&limit=168'));
      case BitcoinPriceChartDataRange.past1Month:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=30'));
      case BitcoinPriceChartDataRange.past6Month:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=180'));
      case BitcoinPriceChartDataRange.past1Year:
        response = await http.get(Uri.parse(
            'https://api.binance.com/api/v1/klines?symbol=BTCUSDT&interval=1d&limit=365'));
    }
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final List<FlSpot> spots = [];
      int index = 0;

      // TODO(fix): fix logic here
      double rate2Fiat = 1.0;
      const int amountInSatoshi = 10000;
      if (widget.exchangeRate.fiatCurrency != FiatCurrency.usd) {
        final ProtonExchangeRate exchangeRateInUSD =
            await ExchangeRateService.getExchangeRate(FiatCurrency.usd);
        rate2Fiat = ExchangeCalculator.getNotionalInFiatCurrency(
                widget.exchangeRate, amountInSatoshi) /
            ExchangeCalculator.getNotionalInFiatCurrency(
                exchangeRateInUSD, amountInSatoshi);
      }
      final List<double> values = [];
      for (var data in json) {
        final double bitcoinNotionalInFiat = double.parse(data[4]) * rate2Fiat;
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
      child: Row(children: [
        Expanded(
          child: Column(children: [
            Container(
              width: Responsive.isDesktop(context)
                  ? MediaQuery.of(context).size.width * 2 / 3 - 300
                  : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 40,
              child: isLoading
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ProtonColors.protonBlue,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
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
                        lineTouchData: const LineTouchData(
                          enabled: false,
                        ),
                        gridData: const FlGridData(
                          drawVerticalLine: false,
                          drawHorizontalLine: false,
                        ),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(),
                          bottomTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          topTitles: AxisTitles(),
                        ),
                      ),
                    ),
            ),
          ]),
        ),
        Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 24,
          color: ProtonColors.textHint,
        ),
      ]),
    );
  }
}
