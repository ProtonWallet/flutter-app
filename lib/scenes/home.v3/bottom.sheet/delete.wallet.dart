import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v5.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class DeleteWalletSheet {
  static void show(BuildContext context, HomeViewModel viewModel,
      WalletMenuModel walletMenuModel, bool hasBalance,
      {bool isInvalidWallet = false}) {
    bool isDeleting = false;
    HomeModalBottomSheet.show(context,
        child: Column(
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
                              S.of(context).confirm_to_delete_wallet(
                                  walletMenuModel.walletName),
                              style: FontManager.titleHeadline(
                                  ProtonColors.textNorm),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            if (hasBalance)
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AlertCustom(
                                    content: S
                                        .of(context)
                                        .confirm_to_delete_wallet_has_balance_warning,
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
                            Text(S.of(context).confirm_to_delete_wallet_content,
                                style: FontManager.body2Regular(
                                    ProtonColors.textWeak)),
                            const SizedBox(height: 40),
                            ButtonV5(
                                onPressed: () async {
                                  Clipboard.setData(ClipboardData(
                                    text: await WalletManager.getMnemonicWithID(
                                        walletMenuModel.walletModel.walletID),
                                  )).then((_) {
                                    if (context.mounted) {
                                      logger.i(S.of(context).copied_mnemonic);
                                      LocalToast.showToast(context,
                                          S.of(context).copied_mnemonic);
                                    }
                                  });
                                },
                                text: S.of(context).save_mnemonic,
                                width: MediaQuery.of(context).size.width,
                                textStyle: FontManager.body1Median(
                                    ProtonColors.textNorm),
                                backgroundColor: ProtonColors.textWeakPressed,
                                borderColor: ProtonColors.textWeakPressed,
                                height: 48),
                            const SizedBox(
                              height: 8,
                            ),
                            ButtonV6(
                              onPressed: () async {
                                if (isDeleting == false) {
                                  isDeleting = true;
                                  await viewModel.deleteWallet(
                                      walletMenuModel.walletModel);
                                  if (context.mounted) {
                                    if (isInvalidWallet == false) {
                                      Navigator.of(context)
                                          .pop(); // pop up this bottomSheet
                                      Navigator.of(context)
                                          .pop(); // pop up wallet setting bottomSheet
                                    } else {
                                      Navigator.of(context)
                                          .pop(); // pop up this bottomSheet
                                    }
                                    CommonHelper.showSnackbar(
                                        context, S.of(context).wallet_deleted);
                                  }
                                  isDeleting = false;
                                }
                              },
                              text: S.of(context).delete_wallet_now,
                              width: MediaQuery.of(context).size.width,
                              backgroundColor: ProtonColors.signalError,
                              borderColor: ProtonColors.signalError,
                              textStyle:
                                  FontManager.body1Median(ProtonColors.white),
                              height: 48,
                            ),
                          ])),
                ])),
          ],
        ));
  }
}
