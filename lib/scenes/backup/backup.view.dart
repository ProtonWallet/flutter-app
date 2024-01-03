import 'package:flutter/material.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/tag.v1.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

import '../../components/onboarding/content.dart';
import '../core/view.navigatior.identifiers.dart';

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
                                  text:
                                      viewModel.itemListShuffled[index].title!,
                                  enable: viewModel.itemListShuffled[index].active!,
                                  index: viewModel.itemListShuffled[index].index!,
                                  onTap: (){
                                    viewModel.updateTag(index);
                                  },
                                ))),
                  ])),
        ),
        OnboardingContent(
            totalPages: 6,
            currentPage: 4,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: "Did you save it?",
            content:
                "Verify that you saved your secret recovery phrase by tapping the first (1st) then the last (12th) word.",
            children: [
              ButtonV5(
                  onPressed: () {
                    if (viewModel.checkUserMnemonic()) {
                      viewModel.coordinator
                          .move(ViewIdentifiers.passphrase, context);
                    } else {
                      LocalToast.showToast(
                          context, "Wrong mnemonic order",
                          isWarning: true,
                          icon: const Icon(Icons.warning, color: Colors.white),
                          duration: 2);
                    }
                  },
                  text: "Continue",
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
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          color: ProtonColors.backgroundSecondary,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Tags(
              //   itemCount: viewModel.itemList.length, // required
              //   itemBuilder: (int index) {
              //     final item = viewModel.itemList[index];
              //     return ItemTags(
              //       key: Key(index.toString()),
              //       index: index,
              //       // required
              //       title: "${item.index}. ${item.title}",
              //       customData: item.customData,
              //       textStyle: const TextStyle(
              //         fontSize: 14,
              //       ),
              //       pressEnabled: false,
              //       combine: ItemTagsCombine.withTextBefore,
              //       borderRadius: BorderRadius.circular(10),
              //       textActiveColor: const Color(0xFF3A3AA8),
              //       activeColor: const Color(0xFFE1E1FA),
              //     );
              //   },
              // ),
              Wrap(
                  spacing: 2.0,
                  runSpacing: 6.0,
                  alignment: WrapAlignment.center,
                  children: List.generate(
                      viewModel.itemList.length,
                      (index) => TagV1(
                            text: viewModel.itemList[index].title!,
                            index: index+1,
                            enable: true,
                          ))),
              SizedBoxes.box24,
              Text(
                "Save these 12 words securely and never share them with anyone.",
                style: FontManager.captionRegular(ProtonColors.textHint),
              )
            ]),
          ),
        ),
        OnboardingContent(
            totalPages: 6,
            currentPage: 3,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            title: "Your mnemonic",
            content:
                "This is your secret recovery phrase. If you lose access to your account, this phrase will help you recover your wallet.",
            children: [
              ButtonV5(
                  onPressed: () {
                    viewModel.updateState(true);
                  },
                  text: "Continue",
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  height: 48),
            ]),
      ],
    );
  }
}
