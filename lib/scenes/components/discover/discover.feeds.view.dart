import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';

import 'discover.box.dart';
import 'proton.feeditem.dart';

class DiscoverFeedsView extends StatelessWidget {
  final List<ProtonFeedItem> protonFeedItems;
  final void Function(String)? onTap;

  const DiscoverFeedsView({
    required this.protonFeedItems,
    super.key,
    this.onTap,
  });

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
          avatar: _CoverImages.getCoverImage(
            item.title,
            protonFeedItems.indexOf(item),
          ),
        );
      }).toList(),
    );
  }
}

class _DiscoverFeedView extends StatelessWidget {
  final ProtonFeedItem protonFeedItem;
  final GestureTapCallback? onTap;
  final Widget avatar;

  const _DiscoverFeedView({
    required this.protonFeedItem,
    required this.avatar,
    this.onTap,
  });

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
  static Widget getCoverImage(String title, int index) {
    if (title.toLowerCase().contains("guide for newcomers")) {
      return Assets.images.icon.discoverBitcoinGuide.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    if (title.toLowerCase().contains("what is bitcoin")) {
      return Assets.images.icon.discoverWhatIsBitcoin.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    if (title.toLowerCase().contains("proton wallet launch")) {
      return Assets.images.icon.discoverProtonWalletLaunch.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    if (title.toLowerCase().contains("proton wallet security")) {
      return Assets.images.icon.discoverProtonWalletSecurity.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    if (title.toLowerCase().contains("bitcoin via email")) {
      return Assets.images.icon.discoverBve.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    if (title.toLowerCase().contains("protect your proton wallet")) {
      return Assets.images.icon.discoverHowToProtect.image(
        fit: BoxFit.fill,
        width: 104,
        height: 104,
      );
    }
    return Assets.images.icon.discoverWhatIsBitcoin.image(
      fit: BoxFit.fill,
      width: 104,
      height: 104,
    );
  }
}
