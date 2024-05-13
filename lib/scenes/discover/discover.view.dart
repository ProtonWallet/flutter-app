import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/components/discover/discover.feeds.view.dart';
import 'package:wallet/components/page.layout.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  const DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, DiscoverViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        backgroundColor: ProtonColors.backgroundProton,
        body: SafeArea(
            child: PageLayoutV1(
                title: S.of(context).discover,
                child: DiscoverFeedsView(
                  onTap: (String link) {
                    launchUrl(Uri.parse(link));
                  },
                  protonFeedItems: viewModel.protonFeedItems,
                ))));
  }
}
