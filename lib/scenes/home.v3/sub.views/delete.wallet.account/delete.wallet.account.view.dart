import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class DeleteWalletAccountView extends ViewBase<DeleteWalletAccountViewModel> {
  const DeleteWalletAccountView(DeleteWalletAccountViewModel viewModel)
      : super(viewModel, const Key("DeleteWalletAccountView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        expanded: MediaQuery.of(context).size.height < 500,
        showHeader: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerRight,
              child: CloseButtonV1(onPressed: () {
                Navigator.of(context).pop();
              })),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.deleteWarning.svg(
                width: 72,
                height: 72,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).confirm_to_delete_wallet_account(
                          viewModel.accountMenuModel.label),
                      style: FontManager.titleHeadline(ProtonColors.textNorm),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    if (viewModel.accountMenuModel.balance > 0)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AlertCustom(
                            content: S
                                .of(context)
                                .confirm_to_delete_wallet_account_has_balance_warning,
                            canClose: false,
                            leadingWidget: Assets.images.icon.alertWarning.svg(
                              width: 22,
                              height: 22,
                              fit: BoxFit.fill,
                            ),
                            border: Border.all(
                              color: Colors.transparent,
                              width: 0,
                            ),
                            backgroundColor: ProtonColors.errorBackground,
                            color: ProtonColors.signalError,
                          )),
                    Text(S.of(context).confirm_to_delete_wallet_account_content,
                        style: FontManager.body2Regular(ProtonColors.textWeak)),
                    const SizedBox(height: 40),
                    ButtonV6(
                      onPressed: () async {
                        if (!viewModel.isDeleting) {
                          viewModel.isDeleting = true;
                          final deleted = await viewModel.deleteWalletAccount();
                          if (context.mounted && deleted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            CommonHelper.showSnackbar(
                              context,
                              S.of(context).account_deleted,
                            );
                          }
                          viewModel.isDeleting = false;
                        }
                      },
                      backgroundColor: ProtonColors.signalError,
                      text: S.of(context).delete_account,
                      width: MediaQuery.of(context).size.width,
                      textStyle: FontManager.body1Median(
                          ProtonColors.backgroundSecondary),
                      height: 48,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      );
    });
  }
}
