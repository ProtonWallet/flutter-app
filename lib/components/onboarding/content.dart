import 'package:flutter/material.dart';
import 'package:wallet/components/progress.dot.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/theme/theme.font.dart';

class OnboardingContent extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final String content;
  final double width;
  final double height;
  final int totalPages;
  final int currentPage;

  const OnboardingContent({
    super.key,
    required this.width,
    required this.height,
    this.title = "",
    this.content = "",
    this.totalPages = 5,
    this.currentPage = 1,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: ProtonColors.backgroundProton,
        child: Container(
            alignment: Alignment.topCenter,
            width: width,
            height: height,
            margin: const EdgeInsets.only(left: 40, right: 40),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBoxes.box20,
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int i = 0; i < totalPages; i++)
                      CircleProgressDot(enable: i + 1 <= currentPage)
                  ]),
                  if (totalPages > 0) SizedBoxes.box20,
                  Text(title,
                      style: FontManager.titleHeadline(
                          ProtonColors.textNorm)),
                  SizedBoxes.box8,
                  Text(
                    content,
                    style: FontManager.body1Median(
                        ProtonColors.textNorm),
                    textAlign: TextAlign.center,
                  ),
                  SizedBoxes.box32,
                  Flexible(
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: children))),
                ])));
  }
}
