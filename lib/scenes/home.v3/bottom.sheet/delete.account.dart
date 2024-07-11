import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class DeleteAccountSheet {
  static void show(BuildContext context, HomeViewModel viewModel,
      WalletModel userWallet, AccountMenuModel userAccount) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      bool isDeleting = false;
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: CloseButtonV1(onPressed: () {
                  Navigator.of(context).pop();
                })),
            Transform.translate(
                offset: const Offset(0, -20),
                child: Column(children: [
                  SvgPicture.asset("assets/images/icon/delete_warning.svg",
                      fit: BoxFit.fill, width: 72, height: 72),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).confirm_to_delete_wallet_account(
                                  userAccount.label),
                              style: FontManager.titleHeadline(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (userAccount.balance > 0)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AlertCustom(
                                    content: S
                                        .of(context)
                                        .confirm_to_delete_wallet_account_has_balance_warning,
                                    canClose: false,
                                    leadingWidget: SvgPicture.asset(
                                        "assets/images/icon/alert_warning.svg",
                                        fit: BoxFit.fill,
                                        width: 22,
                                        height: 22),
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 0,
                                    ),
                                    backgroundColor:
                                        ProtonColors.errorBackground,
                                    color: ProtonColors.signalError,
                                  )),
                            Text(
                                S
                                    .of(context)
                                    .confirm_to_delete_wallet_account_content,
                                style: FontManager.body2Regular(
                                    ProtonColors.textWeak)),
                            const SizedBox(height: 40),
                            ButtonV6(
                                onPressed: () async {
                                  if (isDeleting == false) {
                                    isDeleting = true;
                                    await viewModel.deleteAccount(
                                        userWallet, userAccount.accountModel);
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      CommonHelper.showSnackbar(context,
                                          S.of(context).account_deleted);
                                    }
                                    isDeleting = false;
                                  }
                                },
                                backgroundColor: ProtonColors.signalError,
                                text: S.of(context).delete_account,
                                width: MediaQuery.of(context).size.width,
                                textStyle: FontManager.body1Median(
                                    ProtonColors.backgroundSecondary),
                                height: 48),
                          ])),
                ])),
          ]);
    }));
  }
}
