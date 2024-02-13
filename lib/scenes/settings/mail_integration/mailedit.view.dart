import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/settings/mail_integration/mailedit.viewmodel.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class MailEditView extends ViewBase<MailEditViewModel> {
  MailEditView(MailEditViewModel viewModel)
      : super(viewModel, const Key("MailEditView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, MailEditViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(S.of(context).email_integration),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Email Address",
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  TextFieldText(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: ProtonColors.backgroundSecondary,
                      suffixIcon: const Icon(Icons.close),
                      showSuffixIcon: false,
                      showEnabledBorder: false,
                      controller: viewModel.mailController,
                      showMailTag: true),
                  const SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Link to wallet",
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  DropdownButtonV1(
                    width: MediaQuery.of(context).size.width,
                    items: const [
                      "Select wallet",
                      "Test Wallet 1",
                      "Test Wallet 2",
                      "Bob's Wallet"
                    ],
                    valueNotifier: viewModel.linkWalletNotifier,
                    itemsText: const [
                      "Select wallet",
                      "Test Wallet 1",
                      "Test Wallet 2",
                      "Bob's Wallet"
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (viewModel.linkWalletNotifier.value != "Select wallet")
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Minimum amount",
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextFieldText(
                                  width:
                                      MediaQuery.of(context).size.width - 200,
                                  height: 50,
                                  color: ProtonColors.backgroundSecondary,
                                  suffixIcon: const Icon(Icons.close),
                                  showSuffixIcon: false,
                                  showEnabledBorder: false,
                                  controller: viewModel.minAmountController,
                                  digitOnly: true,
                                  hintText: "0",
                                ),
                                TextChoices(
                                    choices: const ["SAT", "BTC"],
                                    selectedValue: "SAT",
                                    controller: viewModel.minCoinController),
                              ],
                            )),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "Maximum amount",
                            style: FontManager.captionMedian(
                                Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextFieldText(
                                  width:
                                      MediaQuery.of(context).size.width - 200,
                                  height: 50,
                                  color: ProtonColors.backgroundSecondary,
                                  suffixIcon: const Icon(Icons.close),
                                  showSuffixIcon: false,
                                  showEnabledBorder: false,
                                  controller: viewModel.maxAmountController,
                                  hintText: "Unlimited",
                                  digitOnly: true,
                                ),
                                TextChoices(
                                    choices: const ["SAT", "BTC"],
                                    selectedValue: "SAT",
                                    controller: viewModel.maxCoinController),
                              ],
                            )),
                      ],
                    )
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 50),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      56 -
                      MediaQuery.of(context).padding.top,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ButtonV5(
                            onPressed: () {
                              // TODO:: Add logic to save settings, sync setting with backend
                              LocalToast.showToast(context, "TODO");
                            },
                            text: "Save",
                            width: MediaQuery.of(context).size.width,
                            textStyle:
                                FontManager.body1Median(ProtonColors.white),
                            enable: viewModel.linkWalletNotifier.value !=
                                "Select wallet",
                            height: 48),
                      ]))
            ])),
      ),
    );
  }
}
