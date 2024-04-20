import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/custom.discover.box.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, DiscoverViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        backgroundColor: ProtonColors.white,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          backgroundColor: ProtonColors.white,
          title: Text(S.of(context).discover,
              style: FontManager.titleHeadline(ProtonColors.textNorm)),
          scrolledUnderElevation:
              0.0, // don't change background color when scroll down
        ),
        body: SingleChildScrollView(
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
                  ))
          ],
        )));
  }
}
