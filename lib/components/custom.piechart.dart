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
  int touchedIndex = -1;
  double width = 400;
  double height = 260;
  List data = [];
  static List colors = [
    const Color.fromARGB(255, 112, 49, 172),
    const Color.fromARGB(255, 60, 157, 78),
    const Color.fromARGB(255, 201, 77, 109),
    const Color.fromARGB(255, 228, 191, 88),
    const Color.fromARGB(255, 65, 116, 201),
  ];

  CustomPieChart(
      {super.key, this.data = const [], this.width = 400, this.height = 260});

  @override
  _CustomPieChartState createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return Container();
    return Container(
        width: widget.width,
        height: widget.height,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 200,
              height: 200,
              child: PieChart(
                  PieChartData(
                    sections: getSections(),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            widget.touchedIndex = -1;
                            return;
                          }
                          widget.touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: true),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 60),
                  // Optional
                  swapAnimationCurve: Curves.linear)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < min(5, widget.data.length); i++)
                Row(children: [
                  Indicator(
                    color: CustomPieChart.colors[i],
                    text: widget.data[i].name,
                    isSquare: true,
                    textColor: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(
                    width: 12,
                  )
                ]),
            ],
          ),
        ]));
  }

  List<PieChartSectionData>? getSections() {
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < min(5, widget.data.length); i++) {
      final isTouched = i == widget.touchedIndex;
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
