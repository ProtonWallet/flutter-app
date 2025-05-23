import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/external.url.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/custom.loading.dart';
import 'package:wallet/scenes/components/discover/discover.feeds.view.dart';
import 'package:wallet/scenes/components/page.layout.v2.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/discover/discover.viewmodel.dart';

class DiscoverView extends ViewBase<DiscoverViewModel> {
  const DiscoverView(DiscoverViewModel viewModel)
      : super(viewModel, const Key("DiscoverView"));

  @override
  Widget build(BuildContext context) {
    return PageLayoutV2(
      backgroundColor: ProtonColors.backgroundNorm,
      cbtBgColor: ProtonColors.backgroundSecondary,
      title: S.of(context).discover,
      child: viewModel.initialized
          ? _buildDiscoverFeedsView()
          : _buildLoadingView(context),
    );
  }

  /// build fees
  Widget _buildDiscoverFeedsView() {
    return DiscoverFeedsView(
      onTap: (String link) {
        ExternalUrl.shared.launchString(link);
      },
      protonFeedItems: viewModel.protonFeedItems,
    );
  }

  /// build loading view when viewModel is not initialized
  Widget _buildLoadingView(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: context.height,
      child: const Column(children: [
        SizedBox(height: 40),
        SizedBox(
          width: 40,
          height: 40,
          child: CustomLoading(),
        )
      ]),
    );
  }
}
