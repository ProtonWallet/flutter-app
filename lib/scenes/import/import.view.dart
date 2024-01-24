import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';

import '../../components/button.v5.dart';
import '../../components/textfield.password.dart';
import '../../components/textfield.text.dart';
import '../../constants/proton.color.dart';
import '../../helper/local_toast.dart';
import '../../theme/theme.font.dart';

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
          title: const Text("Import your wallet"),
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
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 80,
                      child: TextFieldText(
                        width: MediaQuery.of(context).size.width,
                        controller: viewModel.nameTextController,
                        hintText: "Wallet Name",
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 80,
                        child: TextFieldPassword(
                          width: MediaQuery.of(context).size.width,
                          controller: viewModel.mnemonicTextController,
                          hintText: "Your Mnemonic",
                        )),
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
                          LocalToast.showToast(context, "Wallet imported",
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
                        text: "Import",
                        width: MediaQuery.of(context).size.width,
                        textStyle: FontManager.body1Median(ProtonColors.white),
                        height: 48),
                  ]))
        ]))));
  }
}
