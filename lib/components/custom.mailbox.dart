import 'package:flutter/material.dart';

import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomMailBox extends StatelessWidget {
  final String mail;
  final String subTitle;
  final VoidCallback? onTap;

  const CustomMailBox(
      {super.key, required this.mail, required this.subTitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width - 52,
          decoration: BoxDecoration(
              color: ProtonColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mail,
                    style: FontManager.body1Regular(ProtonColors.textNorm),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    subTitle,
                    style: FontManager.captionRegular(ProtonColors.textHint),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: ProtonColors.textNorm,
                size: 16,
              )
            ],
          ),
        ));
  }
}
