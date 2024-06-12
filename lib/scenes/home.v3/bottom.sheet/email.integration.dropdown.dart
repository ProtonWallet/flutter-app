import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/add.button.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class EmailIntegrationDropdownSheet {
  static void show(
      BuildContext context, HomeViewModel viewModel, AccountModel userAccount) {
    List<String> usedEmailIDs =
        Provider.of<ProtonWalletProvider>(context, listen: false)
            .protonWallet
            .getAllIntegratedEmailIDs();
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
                    onTap: () {
                      if (usedEmailIDs.contains(protonAddress.id)) {
                        LocalToast.showErrorToast(context,
                            S.of(context).email_already_linked_to_wallet);
                      } else {
                        setState(() {
                          viewModel.addEmailAddressToWalletAccount(
                              Provider.of<ProtonWalletProvider>(context,
                                      listen: false)
                                  .protonWallet
                                  .currentWallet!
                                  .serverWalletID,
                              userAccount.serverAccountID,
                              protonAddress.id);
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
