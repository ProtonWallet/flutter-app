import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/tag.proton.discover.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';

class CustomDiscoverBox extends StatelessWidget {
  final String title;
  final String description;
  final String pubDate;
  final String link;
  final String avatarPath;
  final String category;
  final String author;
  final double paddingSize;
  final Color? backgroundColor;

  const CustomDiscoverBox({
    super.key,
    required this.title,
    required this.description,
    required this.avatarPath,
    required this.pubDate,
    required this.link,
    required this.category,
    required this.author,
    this.backgroundColor,
    this.paddingSize = defaultPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: paddingSize),
        decoration: BoxDecoration(
            color: backgroundColor??ProtonColors.backgroundProton,
            borderRadius: BorderRadius.circular(16.0)),
        padding: const EdgeInsets.all(defaultPadding),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          SizedBox(
              width: 100,
              height: 100,
              child: SvgPicture.asset(avatarPath, fit: BoxFit.fitHeight)),
          const SizedBox(width: defaultPadding),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: FontManager.body2Median(ProtonColors.textNorm)),
              const SizedBox(height: 2),
              Text(pubDate,
                  style: FontManager.captionRegular(ProtonColors.textWeak)),
              Row(
                children: [
                  TagProtonDiscover(text: category),
                  TagProtonDiscover(text: author)
                ],
              )
            ],
          ))
        ]));
  }
}
