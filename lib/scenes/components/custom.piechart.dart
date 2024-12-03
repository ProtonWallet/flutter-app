import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

import 'indicator.v1.dart';

class ChartData {
  String name;
  double value;

  ChartData({required this.name, required this.value});
}

class CustomPieChart extends StatefulWidget {
  final double width;
  final double height;
  final List data;
  // TODO(fix): move this to constants/proton.color.dart when design is finalized
  static List colors = [
    const Color.fromARGB(255, 112, 49, 172),
    const Color.fromARGB(255, 60, 157, 78),
    const Color.fromARGB(255, 201, 77, 109),
    const Color.fromARGB(255, 228, 191, 88),
    const Color.fromARGB(255, 65, 116, 201),
  ];

  const CustomPieChart(
      {super.key, this.data = const [], this.width = 400, this.height = 260});

  @override
  CustomPieChartState createState() => CustomPieChartState();
}

class CustomPieChartState extends State<CustomPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return Container();
    return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 200,
              height: 200,
              child: PieChart(
                  PieChartData(
                    sections: getSections(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, response) {
                        if (event.isInterestedForInteractions &&
                            response?.touchedSection != null) {
                          setState(() => touchedIndex =
                              response!.touchedSection!.touchedSectionIndex);
                        } else {
                          setState(() => touchedIndex = -1);
                        }
                      },
                    ),
                    borderData: FlBorderData(show: true),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 60))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 0; i < min(5, widget.data.length); i++)
              Row(children: [
                Indicator(
                  color: CustomPieChart.colors[i],
                  text: widget.data[i].name,
                  isSquare: true,
                  textColor: ProtonColors.textWeak,
                ),
                const SizedBox(
                  width: 12,
                )
              ]),
          ]),
        ]));
  }

  List<PieChartSectionData>? getSections() {
    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < min(5, widget.data.length); i++) {
      final isTouched = i == touchedIndex;
      final textStyle = isTouched
          ? FontManager.captionSemiBold(ProtonColors.white)
          : FontManager.overlineSemiBold(ProtonColors.white);
      final radius = isTouched ? 62.0 : 48.0;
      sections.add(PieChartSectionData(
        color: CustomPieChart.colors[i],
        value: widget.data[i].value,
        title: widget.data[i].value.toString(),
        radius: radius,
        titleStyle: textStyle,
      ));
    }
    return sections;
  }
}
