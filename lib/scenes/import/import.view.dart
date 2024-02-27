import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/constants/sizedbox.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/textfield.password.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/theme/theme.font.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';

class ImportView extends ViewBase<ImportViewModel> {
  ImportView(ImportViewModel viewModel)
      : super(viewModel, const Key("ImportView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, ImportViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
          title: Text(S.of(context).import_your_wallet),
          // automaticallyImplyLeading: false,
          backgroundColor: Colors
              .transparent, // Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Stack(children: [
          Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  56 -
                  MediaQuery.of(context).padding.top,
              margin: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        S.of(context).wallet_name,
                        style: FontManager.captionMedian(
                            Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFieldText(
                        width: MediaQuery.of(context).size.width,
                        controller: viewModel.nameTextController,
                      ),
                    ),
                    SizedBoxes.box24,
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        S.of(context).your_mnemonic,
                        style: FontManager.captionMedian(
                            Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextFieldPassword(
                          width: MediaQuery.of(context).size.width,
                          controller: viewModel.mnemonicTextController,
                        )),
                    SizedBoxes.box24,
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        S.of(context).your_passphrase_optional,
                        style: FontManager.captionMedian(
                            Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: TextFieldPassword(
                            width: MediaQuery.of(context).size.width,
                            controller: viewModel.passphraseTextController)),
                  ])),
          Container(
              padding: const EdgeInsets.only(bottom: 50),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  56 -
                  MediaQuery.of(context).padding.top,
              // AppBar default height is 56
              margin: const EdgeInsets.only(left: 40, right: 40),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ButtonV5(
                        onPressed: () {
                          viewModel.importWallet();
                          LocalToast.showToast(
                              context, S.of(context).wallet_imported,
                              duration: 2);
                          viewModel.coordinator.end();
                          Navigator.of(context).popUntil((route) {
                            if (route.settings.name == null) {
                              return false;
                            }
                            return route.settings.name ==
                                "[<'HomeNavigationView'>]";
                          });
                        },
                        text: S.of(context).import_button,
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ]))
        ]))));
  }
}
