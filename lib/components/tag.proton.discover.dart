import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class TagProtonDiscover extends StatelessWidget {
  final String text;

  const TagProtonDiscover(
      {super.key,
      this.text = "",});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
                margin: const EdgeInsets.only(left: 0, right: 4, top: 4),
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 4.0, bottom: 4.0),
                decoration: BoxDecoration(
                    color: ProtonColors.white,
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  text,
                  style: FontManager.overlineRegular(ProtonColors.protonBlue),
                )),
      ],
    );
  }
}
