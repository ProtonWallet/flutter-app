import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomSymbolBox extends StatelessWidget {
  final String title;
  final String content;
  final String iconPath;
  final double width;
  final double price;
  final double priceChange;
  final VoidCallback? callback;

  const CustomSymbolBox({
    super.key,
    required this.title,
    required this.content,
    required this.iconPath,
    this.width = 440,
    this.price = 0,
    this.callback,
    this.priceChange = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
          width: width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color.fromARGB(255, 226, 226, 226),
                width: 1.0,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    SvgPicture.asset(iconPath,
                        fit: BoxFit.fill, width: 32, height: 32),
                    const SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ))
                  ]),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: [
                      Text("\$${price.toStringAsFixed(2)}",
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
              GestureDetector(
                onTap: callback,
                child: Text("Buy",
                    style: FontManager.titleHeadline(ProtonColors.textNorm)),
              ),
            ],
          ))
    ]);
  }
}
