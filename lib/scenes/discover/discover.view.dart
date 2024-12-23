import 'package:flutter/material.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/discover/discover.feeds.view.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  const DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV1(
      headerWidget: CustomHeader(
        title: S.of(context).discover,
        buttonDirection: AxisDirection.left,
        padding: const EdgeInsets.only(bottom: 10.0),
        button: BackButtonV1(onPressed: () {
          Navigator.of(context).pop();
        }),
      ),
      child: viewModel.initialized
          ? DiscoverFeedsView(
              onTap: (String link) {
                ExternalUrl.shared.launchString(link);
              },
              protonFeedItems: viewModel.protonFeedItems,
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CustomLoading(),
                  )
                ],
              ),
            ),
    );
  }
}
