import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/deletion/deletion.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import '../../components/onboarding/content.dart';
import '../../helper/local_toast.dart';

class WalletDeletionView extends ViewBase<WalletDeletionViewModel> {
  WalletDeletionView(WalletDeletionViewModel viewModel)
      : super(viewModel, const Key("WalletDeletionView"));

  @override
  Widget buildWithViewModel(BuildContext context,
      WalletDeletionViewModel viewModel, ViewSize viewSize) {
    return Scaffold(body: buildMain(context, viewModel, viewSize));
  }

  Widget buildMain(BuildContext context, WalletDeletionViewModel viewModel,
      ViewSize viewSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 7,
                    bottom: MediaQuery.of(context).size.height / 7),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 100.0,
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: ProtonColors.signalError,
                    size: 80,
                  ),
                  // child: SvgPicture.asset(
                  //   'assets/images/wallet_creation/passphrase_icon.svg',
                  //   fit: BoxFit.contain,
                  // ),
                )),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: ProtonColors.textNorm),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ]),
        Container(
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          child: OnboardingContent(
              totalPages: 0,
              currentPage: 0,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              title: "Confirm to delete",
              content:
                  "Please backup your mnemonic before you delete your wallet. This mnemonic can help you to restore your wallet next time.",
              children: [
                ButtonV5(
                    onPressed: () {
                      viewModel.copyMnemonic(context);
                    },
                    text: "Save Mnemonic",
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
                SizedBoxes.box12,
                ButtonV5(
                  onPressed: () async {
                    await viewModel.deleteWallet();
                    if (context.mounted) {
                      LocalToast.showToast(context, "Wallet deleted!");
                      viewModel.coordinator.end();
                      Navigator.of(context).popUntil((route) {
                        if (route.settings.name == null) {
                          return false;
                        }
                        return route.settings.name ==
                            "[<'HomeNavigationView'>]";
                      });
                    }
                  },
                  text: "Delete this wallet",
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: ProtonColors.white,
                  borderColor: ProtonColors.interactionNorm,
                  textStyle:
                      FontManager.body1Median(ProtonColors.interactionNorm),
                  height: 48,
                  enable: viewModel.hasSaveMnemonic,
                ),
              ]),
        ),
      ],
    );
  }
}
