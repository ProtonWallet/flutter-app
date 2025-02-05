import 'package:flutter/material.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/components/alert.custom.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/close.button.v1.dart';
import 'package:wallet/scenes/components/custom.header.dart';
import 'package:wallet/scenes/components/page.layout.v1.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.viewmodel.dart';

class DeleteWalletAccountView extends ViewBase<DeleteWalletAccountViewModel> {
  const DeleteWalletAccountView(DeleteWalletAccountViewModel viewModel)
      : super(viewModel, const Key("DeleteWalletAccountView"));

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return PageLayoutV1(
        headerWidget: CustomHeader(
          buttonDirection: AxisDirection.right,
          padding: const EdgeInsets.all(0.0),
          button: CloseButtonV1(onPressed: () {
            Navigator.of(context).pop();
          }),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(children: [
              Assets.images.icon.deleteWarning.svg(
                width: 48,
                height: 48,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).confirm_to_delete_wallet_account(
                          viewModel.accountMenuModel.label),
                      style: ProtonStyles.headline(
                        color: ProtonColors.textNorm,
                      ),
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
                        ),
                      ),
                    Text(
                      S.of(context).confirm_to_delete_wallet_account_content,
                      style: ProtonStyles.body2Regular(
                        color: ProtonColors.textWeak,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ButtonV6(
                      onPressed: () async {
                        if (!viewModel.isDeleting) {
                          viewModel.isDeleting = true;
                          final deleted = await viewModel.deleteWalletAccount();
                          if (context.mounted && deleted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            context.showSnackbar(context.local.account_deleted);
                          }
                          viewModel.isDeleting = false;
                        }
                      },
                      backgroundColor: ProtonColors.signalError,
                      text: S.of(context).delete_account,
                      width: context.width,
                      textStyle: ProtonStyles.body1Medium(
                        color: ProtonColors.textInverted,
                      ),
                      height: 55,
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
