import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/transaction.addresses.switch/transaction.addresses.switch.viewmodel.dart';

class TransactionAddressesSwitchView
    extends ViewBase<TransactionAddressesSwitchViewModel> {
  const TransactionAddressesSwitchView(
      TransactionAddressesSwitchViewModel viewModel)
      : super(viewModel, const Key("TransactionAddressesSwitchView"));

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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  ListTile(
                    trailing: Assets.images.icon.icCheckmark
                        .svg(fit: BoxFit.fill, width: 20, height: 20),
                    title: Text(
                      S.of(context).transactions,
                      style: ProtonStyles.body2Regular(
                        color: ProtonColors.textNorm,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                  ListTile(
                    title: Text(
                      S.of(context).addresses,
                      style: ProtonStyles.body2Regular(
                        color: ProtonColors.textNorm,
                      ),
                    ),
                    onTap: () {
                      viewModel.coordinator.showWalletAccountAddressList();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ));
    });
  }
}
