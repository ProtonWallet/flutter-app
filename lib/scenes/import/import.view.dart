import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/components/alert.custom.dart';
import 'package:wallet/components/bottom.sheets/placeholder.dart';
import 'package:wallet/components/textfield.text.v2.dart';
import 'package:wallet/components/underline.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:wallet/l10n/generated/locale.dart';

class ImportView extends ViewBase<ImportViewModel> {
  const ImportView(ImportViewModel viewModel)
      : super(viewModel, const Key("ImportView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ImportViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          title: Text(S.of(context).import_your_wallet),
          centerTitle: true,
          // automaticallyImplyLeading: false,
          backgroundColor: Colors
              .transparent, // Theme.of(context).colorScheme.inversePrimary,
        ),
        backgroundColor: ProtonColors.backgroundProton,
        body: SingleChildScrollView(
            child: Center(
                child: Stack(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  56 -
                  MediaQuery.of(context).padding.top,
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(children: <Widget>[
                SizedBoxes.box18,
                Text(S.of(context).import_wallet_header,
                    style: FontManager.body2Regular(ProtonColors.textWeak)),
                SizedBoxes.box18,
                TextFieldTextV2(
                  labelText: S.of(context).wallet_name,
                  hintText: S.of(context).wallet_name_hint,
                  textController: viewModel.nameTextController,
                  myFocusNode: viewModel.nameFocusNode,
                  validation: (String _) {
                    return "";
                  },
                ),
                SizedBoxes.box12,
                AlertCustom(
                  content: S.of(context).wallet_import_mnemonic_guide,
                  learnMore: Underline(
                      onTap: () {
                        CustomPlaceholder.show(context);
                      },
                      color: ProtonColors.purple1Text,
                      child: Text(S.of(context).wallet_import_mnemonic_help,
                          style: FontManager.body2Median(
                              ProtonColors.purple1Text))),
                  leadingWidget: SvgPicture.asset(
                      "assets/images/icon/alert_info.svg",
                      fit: BoxFit.fill,
                      width: 22,
                      height: 22),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 0,
                  ),
                  backgroundColor: ProtonColors.purple1Background,
                  color: ProtonColors.purple1Text,
                ),
                SizedBoxes.box12,
                TextFieldTextV2(
                  labelText: S.of(context).your_mnemonic,
                  hintText: S.of(context).your_mnemonic_hint,
                  textController: viewModel.mnemonicTextController,
                  myFocusNode: viewModel.mnemonicFocusNode,
                  maxLines: 6,
                  validation: (String _) {
                    if (viewModel.verifyMnemonic() == false) {
                      return S.of(context).not_a_valid_mnemonic;
                    }
                    return "";
                  },
                  isPassword: false,
                ),
                SizedBoxes.box24,
                ExpansionTile(
                    shape: const Border(),
                    initiallyExpanded: false,
                    title: Text(S.of(context).my_wallet_has_passphrase,
                        style: FontManager.body2Median(ProtonColors.textWeak)),
                    iconColor: ProtonColors.textHint,
                    collapsedIconColor: ProtonColors.textHint,
                    children: [
                      TextFieldTextV2(
                        labelText: S.of(context).your_passphrase_optional,
                        textController: viewModel.passphraseTextController,
                        myFocusNode: viewModel.passphraseFocusNode,
                        validation: (String _) {
                          return "";
                        },
                        isPassword: true,
                      )
                    ])
              ])),
          Container(
              padding: const EdgeInsets.only(bottom: defaultPadding),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  56 -
                  MediaQuery.of(context).padding.top,
              // AppBar default height is 56
              margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonV5(
                        onPressed: () async {
                          EasyLoading.show(
                              status: "creating wallet..",
                              maskType: EasyLoadingMaskType.black);
                          await viewModel.importWallet();
                          viewModel.coordinator.end();
                          EasyLoading.dismiss();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            if (viewModel.errorMessage.isEmpty) {
                              CommonHelper.showSnackbar(
                                  context, S.of(context).wallet_imported);
                            } else {
                              CommonHelper.showSnackbar(
                                  context, viewModel.errorMessage,
                                  isError: true);
                            }
                          }
                        },
                        enable: viewModel.verifyMnemonic(),
                        text: S.of(context).import_button,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        backgroundColor: ProtonColors.protonBlue,
                        height: 48),
                  ]))
        ]))));
  }
}
