import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/scenes/core/responsive.dart';

class BitcoinPriceHomepageChart extends StatefulWidget {
  final ProtonExchangeRate exchangeRate;
  final double priceChange;
  final PriceGraphDataProvider priceGraphDataProvider;

  const BitcoinPriceHomepageChart({
    required this.exchangeRate,
    required this.priceChange,
    required this.priceGraphDataProvider,
    super.key,
  });

  @override
  BitcoinPriceHomepageChartState createState() =>
      BitcoinPriceHomepageChartState();
}

class BitcoinPriceHomepageChartState extends State<BitcoinPriceHomepageChart> {
  List<FlSpot> dataPoints = [];
  bool isLoading = true;
  double priceChange = 0.0;
  double percentile0 = 0.0;
  double percentile25 = 0.0;
  double percentile100 = 0.0;
  double percentile75 = 0.0;
  String dataRangeString = "1D";
  Timeframe timeFrame = Timeframe.oneDay;
  List<Timeframe> dataRangeOptions = [
    Timeframe.oneDay,
    Timeframe.oneWeek,
    Timeframe.oneMonth,
  ];

  @override
  void didUpdateWidget(BitcoinPriceHomepageChart oldWidget) {
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
          fiatCurrency: widget.exchangeRate.fiatCurrency, timeFrame: timeFrame);
    } catch (e) {
      logger.d(e.toString());
    }
    final List<double> prices = [];
    final List<FlSpot> spots = [];
    int index = 0;
    if (priceGraph != null) {
      for (DataPoint dataPoint in priceGraph.graphData) {
        final double price = dataPoint.exchangeRate / widget.exchangeRate.cents;
        prices.add(price);
        spots.add(FlSpot(
          index.toDouble(),
          price,
        ));
        index++;
      }
    }

    if (mounted) {
      setState(() {
        dataPoints = spots;
        isLoading = false;
        priceChange = (prices.last - prices.first) / prices.first * 100;
        if (prices.isNotEmpty) {
          prices.sort();
          percentile25 = prices[(prices.length * 0.25).floor()];
          percentile0 = prices[(prices.length * 0.0).floor()];
          percentile75 = prices[(prices.length * 0.75).floor()];
          percentile100 = prices[prices.length - 1];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(children: [
        Column(children: [
          Container(
            width: Responsive.isDesktop(context)
                ? MediaQuery.of(context).size.width - drawerMaxWidth - 240
                : MediaQuery.of(context).size.width - 240,
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
        Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 24,
          color: ProtonColors.textHint,
        ),
      ]),
    );
  }
}
