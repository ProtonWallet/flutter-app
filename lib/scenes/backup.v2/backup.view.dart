import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/onboarding/content.dart';
import 'package:wallet/components/tag.v1.dart';
import 'package:wallet/components/tag.v2.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/backup.v2/backup.viewmodel.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

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
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ProtonColors.textNorm),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Column(
          children: [
            Text(S.of(context).your_mnemonic,
                style: FontManager.titleHero(ProtonColors.textNorm)),
            const SizedBox(
              height: 6,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(S.of(context).this_is_your_secret_recovery_phrase,
                  style: FontManager.body1Regular(ProtonColors.textWeak),
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
                    for (int i = 0; i < viewModel.itemList.length; i += 2)
                      TagV2(
                        width: 160,
                        text: viewModel.itemList[i].title!,
                        index: i,
                      ),
                  ],
                ),
                Column(
                  children: [
                    for (int i = 1; i < viewModel.itemList.length; i += 2)
                      TagV2(
                        width: 160,
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
            GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: viewModel.strMnemonic))
                      .then((_) {
                    LocalToast.showToast(
                        context, S.of(context).copied_mnemonic);
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy_sharp, size: 16),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      S.of(context).copy_button,
                      style: FontManager.body2Regular(ProtonColors.textNorm),
                    )
                  ],
                )),
            Container(
                padding: const EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(
                    horizontal: defaultButtonPadding),
                child: ButtonV5(
                    onPressed: () {
                      viewModel.setBackup();
                      Navigator.pop(context);
                    },
                    backgroundColor: ProtonColors.backgroundBlack,
                    text: S.of(context).ok_i_have_save,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48)),
          ],
        ),
      ],
    ));
  }
}
