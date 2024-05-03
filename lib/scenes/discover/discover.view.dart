import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/custom.discover.box.dart';
import 'package:wallet/components/page.layout.v1.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, DiscoverViewModel viewModel, ViewSize viewSize) {
    return PageLayoutV1(
        title: S.of(context).discover,
        child: Column(
          children: [
            for (ProtonFeedItem protonFeedItem in viewModel.protonFeedItems)
              GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(protonFeedItem.link));
                  },
                  child: CustomDiscoverBox(
                    title: protonFeedItem.title,
                    description: protonFeedItem.description,
                    link: protonFeedItem.link,
                    pubDate: protonFeedItem.pubDate,
                    avatarPath:
                        "assets/images/icon/discover_placeholder_${viewModel.protonFeedItems.indexOf(protonFeedItem) % 5}.svg",
                    author: protonFeedItem.author,
                    category: protonFeedItem.category,
                    paddingSize: 0,
                  ))
          ],
        ));
  }
}
