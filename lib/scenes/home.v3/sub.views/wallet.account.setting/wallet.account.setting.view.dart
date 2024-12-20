import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.viewmodel.dart';

class WalletAccountSettingView extends ViewBase<WalletAccountSettingViewModel> {
  const WalletAccountSettingView(WalletAccountSettingViewModel viewModel)
      : super(viewModel, const Key("WalletAccountSettingView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        expanded: false,
        showHeader: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// this feature only expose for internal test and CS
            if (viewModel.isMobileClientDebugMode())
              ListTile(
                  leading: Icon(Icons.privacy_tip_outlined,
                      size: 18, color: ProtonColors.textNorm),
                  title: Transform.translate(
                      offset: const Offset(-8, 0),
                      child: Text("Account info",
                          style: ProtonStyles.body2Regular(
                            color: ProtonColors.textNorm,
                          ))),
                  onTap: () {
                    Navigator.of(context).pop();
                    viewModel.move(NavID.walletAccountInfo);
                  }),
            ListTile(
                leading: Icon(Icons.receipt_rounded,
                    size: 18, color: ProtonColors.textNorm),
                title: Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Text(S.of(context).addresses,
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.textNorm,
                        ))),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.move(NavID.walletAccountAddressList);
                }),
            const SizedBox(
              height: 5,
            ),
            ListTile(
                leading: Icon(Icons.delete_rounded,
                    size: 18, color: ProtonColors.signalError),
                title: Transform.translate(
                    offset: const Offset(-8, 0),
                    child: Text(S.of(context).delete_account,
                        style: ProtonStyles.body2Regular(
                          color: ProtonColors.signalError,
                        ))),
                onTap: () {
                  Navigator.of(context).pop();
                  viewModel.move(NavID.deleteWalletAccount);
                }),
          ],
        ),
      );
    });
  }
}
