import 'package:flutter/material.dart';
import 'package:wallet/components/progress.dot.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

import '../../constants/sizedbox.dart';
import '../button.v5.dart';

class OnboardingContent extends StatelessWidget {
  List<Widget> children = [];
  String title = "";
  String content = "";
  double width;
  double height;
  int totalPages = 5;
  int currentPage = 1;

  OnboardingContent({
    super.key,
    required this.width,
    required this.height,
    this.children = const [],
    this.title = "",
    this.content = "",
    this.totalPages = 5,
    this.currentPage = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topCenter,
        width: width,
        height: height,
        margin: const EdgeInsets.only(left: 40, right: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBoxes.box20,
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 0; i < totalPages; i++)
              CircleProgressDot(enable: i + 1 <= currentPage)
          ]),
          SizedBoxes.box20,
          Text(title,
              style: FontManager.titleHeadline(
                  Theme.of(context).colorScheme.primary)),
          SizedBoxes.box8,
          Text(
            content,
            style:
                FontManager.body1Median(Theme.of(context).colorScheme.primary),
          ),
          SizedBoxes.box32,
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: children))),
        ]));
  }
}
