import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.info/wallet.account.info.viewmodel.dart';

class WalletAccountInfoView extends ViewBase<WalletAccountInfoViewModel> {
  const WalletAccountInfoView(WalletAccountInfoViewModel viewModel)
      : super(viewModel, const Key("WalletAccountInfoView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        showHeader: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text("name: ${viewModel.accountName}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            ListTile(
              title: Text("priority: ${viewModel.accountPriority}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            ListTile(
              title: Text("poolSize: ${viewModel.accountPoolSize}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            ListTile(
              title: Text("derivationPath: ${viewModel.accountDerivationPath}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            ListTile(
              title: Text("lastUsedIndex: ${viewModel.accountLastUsedIndex}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            ListTile(
              title: Text(
                  "highestIndexFromBlockchain: ${viewModel.accountHighestIndexFromBlockchain}",
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
          ],
        ),
      );
    });
  }
}
