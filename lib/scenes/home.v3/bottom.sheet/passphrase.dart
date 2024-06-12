import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/managers/wallet/proton.wallet.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/components/bottom.sheets/base.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/theme/theme.font.dart';

class PassphraseSheet {
  static void show(
      BuildContext context, HomeViewModel viewModel, WalletModel walletModel) {
    HomeModalBottomSheet.show(context, child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // TODO:: need customize desc here
            // AlertWarning(
            //     content:
            //     S.of(context).config_wallet_passphrase_guide,
            //     width: MediaQuery.of(context).size.width),
            // const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: TextFieldTextV2(
                labelText: S.of(context).passphrase_label,
                textController: viewModel.walletRecoverPassphraseController,
                myFocusNode: viewModel.walletRecoverPassphraseFocusNode,
                validation: (String value) {
                  if (value.isEmpty) {
                    return "Required";
                  }
                  return "";
                },
              ),
            ),
            if (viewModel.isWalletPassphraseMatch == false)
              Text(S.of(context).wrong_passphrase,
                  style: FontManager.body2Median(ProtonColors.signalError)),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.only(top: 20),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () async {
                      String passphrase =
                          viewModel.walletRecoverPassphraseController.text;
                      bool match = await WalletManager.checkFingerprint(
                          walletModel, passphrase);
                      setState(() {
                        viewModel.isWalletPassphraseMatch = match;
                      });
                      if (match) {
                        EasyLoading.show(
                            status: "apply passphrase to wallet",
                            maskType: EasyLoadingMaskType.black);
                        try {
                          if (context.mounted) {
                            Provider.of<ProtonWalletProvider>(context,
                                    listen: false)
                                .setPassphrase(walletModel, passphrase);
                          } else {
                            viewModel.errorMessage =
                                "setPassphrase(): context.mounted == false";
                          }
                        } catch (e) {
                          viewModel.errorMessage = e.toString();
                        }
                        if (viewModel.errorMessage.isNotEmpty) {
                          CommonHelper.showErrorDialog(viewModel.errorMessage);
                          viewModel.errorMessage = "";
                        }
                        EasyLoading.dismiss();
                      }
                      viewModel.walletRecoverPassphraseController.text = "";
                      if (context.mounted && match) {
                        Navigator.of(context).pop();
                      }
                    },
                    backgroundColor: ProtonColors.protonBlue,
                    text: S.of(context).submit,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(
                        ProtonColors.backgroundSecondary),
                    height: 48)),
          ]);
    }));
  }
}
