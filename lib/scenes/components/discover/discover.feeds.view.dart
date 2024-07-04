import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';

import 'discover.box.dart';
import 'proton.feeditem.dart';

class DiscoverFeedsView extends StatelessWidget {
  final List<ProtonFeedItem> protonFeedItems;
  final void Function(String)? onTap;
  const DiscoverFeedsView(
      {super.key, this.onTap, required this.protonFeedItems});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: protonFeedItems.map((item) {
        return _DiscoverFeedView(
          protonFeedItem: item,
          onTap: () {
            if (onTap != null) {
              onTap!(item.link);
            }
          },
          avatar: _CoverImages.getCoverImage(protonFeedItems.indexOf(item)),
        );
      }).toList(),
    );
  }
}

class _DiscoverFeedView extends StatelessWidget {
  final ProtonFeedItem protonFeedItem;
  final GestureTapCallback? onTap;
  final Widget avatar;
  // final

  const _DiscoverFeedView(
      {required this.protonFeedItem, this.onTap, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DiscoverBox(
        title: protonFeedItem.title,
        description: protonFeedItem.description,
        link: protonFeedItem.link,
        pubDate: protonFeedItem.pubDate,
        author: protonFeedItem.author,
        category: protonFeedItem.category,
        paddingSize: 0,
        avatar: avatar,
      ),
    );
  }
}

class _CoverImages {
  static final List<SvgGenImage> _imagePaths = [
    Assets.images.icon.discoverPlaceholder0,
    Assets.images.icon.discoverPlaceholder1,
    Assets.images.icon.discoverPlaceholder2,
    Assets.images.icon.discoverPlaceholder3,
    Assets.images.icon.discoverPlaceholder4
  ];

  static Widget getCoverImage(int index) {
    return _imagePaths[index % _imagePaths.length].svg(fit: BoxFit.fitHeight);
  }
}
