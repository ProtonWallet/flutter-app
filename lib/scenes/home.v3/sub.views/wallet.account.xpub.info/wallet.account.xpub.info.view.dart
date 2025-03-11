import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.viewmodel.dart';

class WalletAccountXpubInfoView
    extends ViewBase<WalletAccountXpubInfoViewModelImpl> {
  const WalletAccountXpubInfoView(WalletAccountXpubInfoViewModelImpl viewModel)
      : super(viewModel, const Key("WalletAccountXpubInfoView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        backgroundColor: ProtonColors.backgroundSecondary,
        headerWidget: CustomHeader(
          title: "Public key (XPUB)",
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(
              backgroundColor: ProtonColors.backgroundNorm,
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(viewModel.xpub,
                  style: ProtonStyles.body2Regular(
                    color: ProtonColors.textNorm,
                  )),
            ),
            SizedBox(
              height: 12,
            ),
            ButtonV6(
              onPressed: () async {
                viewModel.copyXpubToClipboard();
                Fluttertoast.showToast(msg: S.of(context).xpub_copied);
                Navigator.of(context).pop();
              },
              backgroundColor: ProtonColors.protonBlue,
              text: S.of(context).copy_button,
              width: MediaQuery.of(context).size.width,
              textStyle: ProtonStyles.body1Medium(
                color: ProtonColors.textInverted,
              ),
              height: 52,
            ),
          ],
        ),
      );
    });
  }
}
