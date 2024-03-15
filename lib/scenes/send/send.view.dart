import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/components/dropdown.button.v1.dart';
import 'package:wallet/components/tag.text.dart';
import 'package:wallet/components/text.choices.dart';
import 'package:wallet/components/textfield.autocomplete.dart';
import 'package:wallet/components/textfield.text.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';
import 'package:flutter_gen/gen_l10n/locale.dart';
import 'package:wallet/theme/theme.font.dart';

class SendView extends ViewBase<SendViewModel> {
  SendView(SendViewModel viewModel) : super(viewModel, const Key("SendView"));

  @override
  Widget buildWithViewModel(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(S.of(context).send_bitcoin,
            style: FontManager.titleHeadline(
                Theme.of(context).colorScheme.primary)),
        scrolledUnderElevation:
            0.0, // don't change background color when scroll down
      ),
      body: buildContent(context, viewModel, viewSize),
    );
  }

  Widget buildContent(
      BuildContext context, SendViewModel viewModel, ViewSize viewSize) {
    return Stack(children: [
      ListView(scrollDirection: Axis.vertical, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Center(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).send_from_wallet,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (viewModel.userWallets.isNotEmpty)
                    DropdownButtonV1(
                      width: MediaQuery.of(context).size.width,
                      items: viewModel.userWallets,
                      valueNotifier: viewModel.valueNotifier,
                      itemsText:
                          viewModel.userWallets.map((v) => v.name).toList(),
                    ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).send_from_account,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (viewModel.userAccounts.isNotEmpty)
                    DropdownButtonV1(
                      width: MediaQuery.of(context).size.width,
                      items: viewModel.userAccounts,
                      valueNotifier: viewModel.valueNotifierForAccount,
                      itemsText: viewModel.userAccounts
                          .map((v) => "${v.labelDecrypt} (${v.derivationPath})")
                          .toList(),
                    ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).current_balance_sat(viewModel.balance),
                      style: FontManager.captionMedian(ProtonColors.textHint),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).send_to_recipient_s,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldAutoComplete(
                      options: viewModel.contactsEmail,
                      color: ProtonColors.backgroundSecondary),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                        onTap: () {
                          LocalToast.showToast(context, "TODO");
                        },
                        child: Text(
                          S.of(context).add_address,
                          style: FontManager.captionMedian(
                              ProtonColors.interactionNorm),
                        )),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).amount,
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
                            width: MediaQuery.of(context).size.width - 200,
                            height: 50,
                            color: ProtonColors.backgroundSecondary,
                            suffixIcon: const Icon(Icons.close),
                            showSuffixIcon: false,
                            showEnabledBorder: false,
                            controller: viewModel.amountTextController,
                            digitOnly: true,
                          ),
                          TextChoices(
                              choices: const ["SATS", "BTC"],
                              selectedValue: viewModel.coinController.text,
                              controller: viewModel.coinController),
                        ],
                      )),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "~ €${viewModel.getFiatCurrencyValue()}",
                      style: FontManager.captionMedian(ProtonColors.textHint),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).message_to_recipient_optional,
                      style: FontManager.captionMedian(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldText(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    multiLine: true,
                    color: ProtonColors.backgroundSecondary,
                    showSuffixIcon: false,
                    showEnabledBorder: false,
                    controller: viewModel.memoTextController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).fees_default,
                            style: FontManager.captionSemiBold(
                                Theme.of(context).colorScheme.primary),
                          ),
                          TagText(
                            text: S.of(context).moderate,
                            radius: 10.0,
                            background:
                                const Color.fromARGB(255, 237, 252, 221),
                            textColor: const Color.fromARGB(255, 40, 116, 4),
                          ),
                        ]),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "${viewModel.feeRate.toStringAsFixed(1)} sats/vb\nConfirmation in 2hours")),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      S.of(context).advanced_options,
                      style: FontManager.captionMedian(
                          ProtonColors.interactionNorm),
                    ),
                  ),
                  const SizedBox(height: 50)
                ])))
      ]),
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
                      viewModel.updateExchangeRate();
                      // if (viewModel.coinController.text != "SATS") {
                      //   LocalToast.showErrorToast(
                      //       context, S.of(context).only_support_sat_now);
                      // } else {
                      //   viewModel.sendCoin();
                      //   viewModel.coordinator.end();
                      //   Navigator.of(context).pop();
                      // }
                    },
                    text: S.of(context).review_transaction,
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ]))
    ]);
  }
}
