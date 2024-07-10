import 'package:flutter/material.dart';
import 'package:wallet/helper/url.external.dart';
import 'package:wallet/scenes/components/discover/discover.feeds.view.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  const DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
        title: S.of(context).discover,
        child: DiscoverFeedsView(
          onTap: (String link) {
            ExternalUrl.shared.launchString(link);
          },
          protonFeedItems: viewModel.protonFeedItems,
        ));
  }
}
