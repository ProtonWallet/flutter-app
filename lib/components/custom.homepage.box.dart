import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomHomePageBox extends StatelessWidget {
  final String title;
  final String iconPath;
  final double width;
  final double price;
  final double priceChange;
  final List<Widget> children;

  const CustomHomePageBox({
    super.key,
    required this.title,
    required this.iconPath,
    this.width = 440,
    this.price = 0,
    this.children = const [],
    this.priceChange = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
          width: width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: ProtonColors.surfaceLight,
              borderRadius: BorderRadius.circular(24.0),
              ),
          child: Column(
            children: [
              Row(children: [
                SvgPicture.asset(iconPath,
                    fit: BoxFit.fill, width: 44, height: 44),
                const SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: ProtonColors.textWeak,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text("\$${price.toStringAsFixed(5)}",
                            style:
                                FontManager.body1Median(ProtonColors.textNorm)),
                        const SizedBox(
                          width: 8,
                        ),
                        priceChange > 0
                            ? Text("▲${priceChange.toStringAsFixed(2)}% (1d)",
                                style: FontManager.body2Regular(
                                    ProtonColors.signalSuccess))
                            : Text("▼${priceChange.toStringAsFixed(2)}% (1d)",
                                style: FontManager.body2Regular(
                                    ProtonColors.signalError)),
                      ]),
                    )
                  ],
                ),
              ]),
              const SizedBox(
                height: 6,
              ),
              const Divider(thickness: 0.4),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              ),
              const SizedBox(
                height: 4,
              ),
            ],
          ))
    ]);
  }
}
