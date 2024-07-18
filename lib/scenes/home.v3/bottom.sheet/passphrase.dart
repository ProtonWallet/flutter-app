import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/scenes/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/components/textfield.text.v2.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class PassphraseSheet {
  static void show(BuildContext context, HomeViewModel viewModel,
      WalletMenuModel walletMenuModel) {
    Future.delayed(const Duration(milliseconds: 200), () {
      viewModel.walletRecoverPassphraseFocusNode.requestFocus();
    });
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 10),
        // TODO(fix): need customize desc here
        // AlertWarning(
        //     content:
        //     S.of(context).config_wallet_passphrase_guide,
        //     width: MediaQuery.of(context).size.width),
        // const SizedBox(height: 12),
        Text(
          walletMenuModel.walletName,
          style: FontManager.titleHeadline(ProtonColors.textNorm),
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).wallet_passphrase_unlock_desc,
          style: FontManager.body2Regular(ProtonColors.textWeak),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(children: [
            TextFieldTextV2(
              labelText: S.of(context).passphrase_label,
              hintText: S.of(context).passphrase_recovery_hint,
              alwaysShowHint: true,
              textController: viewModel.walletRecoverPassphraseController,
              myFocusNode: viewModel.walletRecoverPassphraseFocusNode,
              validation: (String value) {
                if (value.isEmpty) {
                  return "Required";
                }
                return "";
              },
              isPassword: true,
            ),
          ]),
        ),
        if (!viewModel.isWalletPassphraseMatch)
          Text(S.of(context).wrong_passphrase,
              style: FontManager.body2Median(ProtonColors.signalError)),
        const SizedBox(height: 6),
        Container(
            padding: const EdgeInsets.only(top: 20),
            margin:
                const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
            child: ButtonV6(
                onPressed: () async {
                  // TODO(fix): move some logic to VM
                  final String passphrase =
                      viewModel.walletRecoverPassphraseController.text;
                  final bool match = await WalletManager.checkFingerprint(
                      walletMenuModel.walletModel, passphrase);
                  setState(() {
                    viewModel.isWalletPassphraseMatch = match;
                  });
                  if (match) {
                    try {
                      viewModel.errorMessage = "";
                      await viewModel
                          .dataProviderManager.walletPassphraseProvider
                          .saveWalletPassphrase(
                        WalletPassphrase(
                          walletID: walletMenuModel.walletModel.walletID,
                          passphrase: passphrase,
                        ),
                      );
                    } on BridgeError catch (e, stacktrace) {
                      viewModel.errorMessage = parseSampleDisplayError(e);
                      logger
                          .e("importWallet error: $e, stacktrace: $stacktrace");
                    } catch (e) {
                      viewModel.errorMessage = e.toString();
                    }
                    if (viewModel.errorMessage.isNotEmpty) {
                      CommonHelper.showErrorDialog(viewModel.errorMessage);
                      viewModel.errorMessage = "";
                    }
                  }
                  viewModel.walletRecoverPassphraseController.text = "";
                  if (context.mounted && match) {
                    walletMenuModel.hasValidPassword = true;
                    for (AccountMenuModel accountMenuModel
                        in walletMenuModel.accounts) {
                      viewModel.dataProviderManager.bdkTransactionDataProvider
                          .syncWallet(
                        walletMenuModel.walletModel,
                        accountMenuModel.accountModel,
                        forceSync: true,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
                backgroundColor: ProtonColors.protonBlue,
                text: S.of(context).submit,
                width: MediaQuery.of(context).size.width,
                textStyle:
                    FontManager.body1Median(ProtonColors.backgroundSecondary),
                height: 48)),
      ]);
    }));
  }
}
