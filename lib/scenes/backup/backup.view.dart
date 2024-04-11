import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/components/tag.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class SetupBackupView extends ViewBase<SetupBackupViewModel> {
  SetupBackupView(SetupBackupViewModel viewModel)
      : super(viewModel, const Key("SetupBackupView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        body: viewModel.isVerifyingUserMnemonic
            ? buildConfirmMnemonicView(context, viewModel, viewSize)
            : buildMnemonicView(context, viewModel, viewSize));
  }

  Widget buildConfirmMnemonicView(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                          spacing: 2.0,
                          runSpacing: 6.0,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                              viewModel.itemListShuffled.length,
                              (index) => TagV1(
                                    text: viewModel
                                        .itemListShuffled[index].title!,
                                    enable: viewModel
                                        .itemListShuffled[index].active!,
                                    index: viewModel
                                        .itemListShuffled[index].index!,
                                    onTap: () {
                                      viewModel.updateTag(index);
                                    },
                                  ))),
                    ])),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
              onPressed: () {
                viewModel.updateState(false);
              },
            ),
          ),
        ]),
        OnboardingContent(
            totalPages: 6,
            currentPage: 4,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: S.of(context).did_you_save_it,
            content: S.of(context).verify_you_saved_secret_phrase_,
            children: [
              ButtonV5(
                  onPressed: () {
                    if (viewModel.checkUserMnemonic()) {
                      viewModel.move(ViewIdentifiers.passphrase);
                    } else {
                      LocalToast.showErrorToast(
                          context, S.of(context).wrong_mnemonic_order);
                    }
                  },
                  text: S.of(context).continue_buttion,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
            ]),
      ],
    );
  }

  Widget buildMnemonicView(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            color: ProtonColors.backgroundSecondary,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                        spacing: 2.0,
                        runSpacing: 6.0,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                            viewModel.itemList.length,
                            (index) => TagV1(
                                  text: viewModel.itemList[index].title!,
                                  index: index + 1,
                                  enable: true,
                                ))),
                    SizedBoxes.box24,
                    Text(
                      S.of(context).save_12_words_securely,
                      style: FontManager.captionRegular(ProtonColors.textHint),
                    )
                  ]),
            ),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ]),
        OnboardingContent(
            totalPages: 6,
            currentPage: 3,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: S.of(context).your_mnemonic,
            content: S.of(context).this_is_your_secret_recovery_phrase,
            children: [
              ButtonV5(
                  onPressed: () {
                    viewModel.updateState(true);
                  },
                  text: S.of(context).continue_buttion,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
            ]),
      ],
    );
  }
}
