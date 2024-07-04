import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/add.button.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class EmailIntegrationDropdownSheet {
  static void show(BuildContext context, HomeViewModel viewModel,
      WalletModel userWallet, AccountMenuModel accountMenuModel,
      {VoidCallback? callback}) {
    List<String> usedEmailIDs = accountMenuModel.emailIds;

    /// TODO:: getAllIntegratedEmailIDs here
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          for (ProtonAddress protonAddress in viewModel.protonAddresses)
            Container(
                height: 60,
                alignment: Alignment.center,
                child: Column(children: [
                  ListTile(
                    trailing: usedEmailIDs.contains(protonAddress.id)
                        ? SvgPicture.asset(
                            "assets/images/icon/ic-checkmark.svg",
                            fit: BoxFit.fill,
                            width: 20,
                            height: 20)
                        : null,
                    title: Text(protonAddress.email,
                        style: FontManager.body2Regular(ProtonColors.textNorm)),
                    onTap: () async {
                      if (usedEmailIDs.contains(protonAddress.id)) {
                        LocalToast.showErrorToast(context,
                            S.of(context).email_already_linked_to_wallet);
                      } else {
                        await viewModel.addEmailAddressToWalletAccount(
                            userWallet.walletID,
                            userWallet,
                            accountMenuModel.accountModel,
                            protonAddress.id);
                        setState(() {
                          if (callback != null) {
                            callback.call();
                          }
                          Navigator.of(context).pop();
                        });
                      }
                    },
                  ),
                  const Divider(
                    thickness: 0.2,
                    height: 1,
                  ),
                ])),
          Container(
              height: 60,
              alignment: Alignment.center,
              child: Column(children: [
                ListTile(
                  leading: const AddButtonV1(),
                  title: Transform.translate(
                      offset: const Offset(-8, 0),
                      child: Text(S.of(context).add_a_new_address,
                          style: FontManager.body2Regular(
                              ProtonColors.protonBlue))),
                  onTap: () {},
                )
              ])),
        ],
      );
    }));
  }
}
