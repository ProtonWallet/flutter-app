import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/tag.proton.discover.dart';
import 'package:wallet/theme/theme.font.dart';

/// Discover Box
class DiscoverBox extends StatelessWidget {
  final String title;
  final String description;
  final String pubDate;
  final String link;
  final String category;
  final String author;
  final double paddingSize;
  final Color? backgroundColor;
  final Widget avatar;

  const DiscoverBox({
    required this.title,
    required this.description,
    required this.avatar,
    required this.pubDate,
    required this.link,
    required this.category,
    required this.author,
    super.key,
    this.backgroundColor,
    this.paddingSize = defaultPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: paddingSize),
      padding: EdgeInsets.all(paddingSize),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _Avatar(avatar: avatar),
          const SizedBox(width: defaultPadding),
          Expanded(
            child: _Details(
              title: title,
              pubDate: pubDate,
              category: category,
              author: author,
            ),
          ),
        ],
      ),
    );
  }
}

/// Discover box Avatar part
class _Avatar extends StatelessWidget {
  final Widget avatar;
  const _Avatar({required this.avatar});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: avatar,
    );
  }
}

/// Discover box Details part
class _Details extends StatelessWidget {
  final String title;
  final String pubDate;
  final String category;
  final String author;

  const _Details({
    required this.title,
    required this.pubDate,
    required this.category,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: FontManager.body2Median(ProtonColors.textNorm)),
        const SizedBox(height: 2),
        Text(pubDate, style: FontManager.captionRegular(ProtonColors.textWeak)),
        Wrap(
          children: [
            TagProtonDiscover(text: category),
            TagProtonDiscover(text: author),
          ],
        ),
      ],
    );
  }
}
