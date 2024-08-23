import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class EmailIntegrationDropdownV2Sheet {
  static void show(
    BuildContext context,
    HomeViewModel viewModel,
    WalletModel userWallet,
    AccountMenuModel accountMenuModel,
    List<String> usedEmailIDs, {
    VoidCallback? callback,
  }) {
    String? selectedEmailID;
    // TODO(fix): getAllIntegratedEmailIDs here
    HomeModalBottomSheet.show(context, backgroundColor: ProtonColors.white,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(
                  backgroundColor: ProtonColors.backgroundProton,
                  onPressed: () {
                    Navigator.of(context).pop();
                  })),
          Center(
            child: Text(
              S.of(context).email_integration,
              style: FontManager.titleHeadline(ProtonColors.textNorm),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).email_integration_setting_desc,
            style: FontManager.body2Regular(ProtonColors.textWeak),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (ProtonAddress protonAddress in viewModel.protonAddresses)
            Container(
                height: 60,
                alignment: Alignment.center,
                child: Stack(children: [
                  ListTile(
                    leading: Transform.translate(
                      offset: const Offset(0, 2),
                      child: Radio<String>(
                        value: usedEmailIDs.contains(protonAddress.id)
                            ? "used"
                            : protonAddress.id,
                        groupValue: usedEmailIDs.contains(protonAddress.id)
                            ? "used"
                            : selectedEmailID,
                        toggleable: true,
                        onChanged: (String? value) {
                          setState(() {
                            selectedEmailID = value;
                          });
                        },
                      ),
                    ),
                    title: Transform.translate(
                      offset: const Offset(-12, 0),
                      child: Text(protonAddress.email,
                          style:
                              FontManager.body2Regular(ProtonColors.textNorm)),
                    ),
                    onTap: () async {
                      final clickable =
                          !usedEmailIDs.contains(protonAddress.id);
                      final itemValue = usedEmailIDs.contains(protonAddress.id)
                          ? "used"
                          : protonAddress.id;
                      if (clickable) {
                        setState(() {
                          if (itemValue == selectedEmailID) {
                            selectedEmailID = null;
                          } else {
                            selectedEmailID = itemValue;
                          }
                        });
                      }
                    },
                  ),
                  if (usedEmailIDs.contains(protonAddress
                      .id)) // add an overlay, so user cannot select this
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: Colors.white.withOpacity(0.5),
                    ),
                ])),
          const SizedBox(height: 20),
          Container(
              height: 60,
              alignment: Alignment.center,
              child: Column(children: [
                ButtonV6(
                    onPressed: () async {
                      if (usedEmailIDs.contains(selectedEmailID)) {
                        LocalToast.showErrorToast(context,
                            S.of(context).email_already_linked_to_wallet);
                      } else {
                        final success =
                            await viewModel.addEmailAddressToWalletAccount(
                          userWallet.walletID,
                          userWallet,
                          accountMenuModel.accountModel,
                          selectedEmailID!,
                        );
                        if (success) {
                          setState(() {
                            if (callback != null) {
                              callback.call();
                            }
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          });
                        }
                      }
                    },
                    enable: selectedEmailID != null,
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).select_this_address,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ])),
        ],
      );
    }));
  }
}
