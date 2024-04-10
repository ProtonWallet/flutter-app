import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/constants/proton.color.dart';

class CustomNewsBox extends StatelessWidget {
  final String title;
  final String content;
  final String iconPath;
  final double width;

  const CustomNewsBox({
    super.key,
    required this.title,
    required this.content,
    required this.iconPath,
    this.width = 440,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Container(
          width: width,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: ProtonColors.surfaceLight,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color.fromARGB(255, 226, 226, 226),
                width: 1.0,
              )),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    SvgPicture.asset(iconPath,
                        fit: BoxFit.fill, width: 32, height: 32),
                    const SizedBox(width: 10),
                    Text(title,
                        style: TextStyle(
                          color: ProtonColors.textNorm,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ))
                  ])),
              const SizedBox(
                height: 5,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(content,
                      style: TextStyle(
                        color: ProtonColors.textWeak,
                        fontSize: 16,
                      ))),
            ],
          ))
    ]);
  }
}
