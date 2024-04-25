import 'package:flutter/material.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/tag.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/backup.v2/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class SetupBackupView extends ViewBase<SetupBackupViewModel> {
  SetupBackupView(SetupBackupViewModel viewModel)
      : super(viewModel, const Key("SetupBackupView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Scaffold(body: buildMnemonicView(context, viewModel, viewSize));
  }

  Widget buildMnemonicView(
      BuildContext context, SetupBackupViewModel viewModel, ViewSize viewSize) {
    return Container(
        color: ProtonColors.backgroundProton,
        child: Column(children: [
          AppBar(
            surfaceTintColor: ProtonColors.backgroundProton,
            backgroundColor: ProtonColors.backgroundProton,
            title: Text(
              S.of(context).mnemonic_backup_page_title,
              style: FontManager.body2Median(ProtonColors.textNorm),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: ProtonColors.textNorm),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      color: ProtonColors.backgroundProton,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(S.of(context).mnemonic_backup_content_title,
                                  style: FontManager.titleHero(
                                      ProtonColors.textNorm)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                    S
                                        .of(context)
                                        .mnemonic_backup_content_subtitle,
                                    style: FontManager.body1Regular(
                                        ProtonColors.textWeak),
                                    textAlign: TextAlign.center),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      for (int i = 0;
                                          i < viewModel.itemList.length;
                                          i += 2)
                                        TagV2(
                                          width: 164,
                                          text: viewModel.itemList[i].title!,
                                          index: i,
                                        ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      for (int i = 1;
                                          i < viewModel.itemList.length;
                                          i += 2)
                                        TagV2(
                                          width: 164,
                                          text: viewModel.itemList[i].title!,
                                          index: i,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 22,
                              ),
                            ],
                          ),
                        ],
                      )))),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin:
                  const EdgeInsets.symmetric(horizontal: defaultButtonPadding),
              child: ButtonV5(
                  onPressed: () {
                    showConfirm(context, viewModel);
                  },
                  backgroundColor: ProtonColors.protonBlue,
                  text: S.of(context).done,
                  width: MediaQuery.of(context).size.width,
                  textStyle: FontManager.body1Median(ProtonColors.white),
                  radius: 40,
                  height: 52)),
        ]));
  }
}

void showConfirm(BuildContext context, SetupBackupViewModel viewModel) {
  showModalBottomSheet(
      context: context,
      backgroundColor: ProtonColors.backgroundProton,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(
                vertical: 30, horizontal: defaultPadding),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text(S.of(context).mnemonic_backup_confirm_title,
                      style: FontManager.titleHero(ProtonColors.textNorm)),
                  const SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: Text(
                          S.of(context).mnemonic_backup_confirm_subtitle,
                          style:
                              FontManager.body1Regular(ProtonColors.textHint))),
                  const SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonV5(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            backgroundColor: ProtonColors.protonGrey,
                            text: S.of(context).cancel,
                            width: MediaQuery.of(context).size.width / 2 -
                                defaultPadding -
                                5,
                            textStyle:
                                FontManager.body1Median(ProtonColors.textNorm),
                            radius: 40,
                            height: 55),
                        ButtonV5(
                            onPressed: () {
                              viewModel.setBackup();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            backgroundColor: ProtonColors.protonBlue,
                            text: S.of(context).done,
                            width: MediaQuery.of(context).size.width / 2 -
                                defaultPadding -
                                5,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            radius: 40,
                            height: 55),
                      ])
                ]));
      });
}
