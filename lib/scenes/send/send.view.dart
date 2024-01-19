import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wallet/components/button.v5.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

import '../../components/tag.text.dart';
import '../../components/text.choices.dart';
import '../../components/dropdown.button.v1.dart';
import '../../components/textfield.text.dart';
import '../../constants/proton.color.dart';
import '../../theme/theme.font.dart';

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
        title: Text("Send Bitcoin",
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
    return ListView(scrollDirection: Axis.vertical, children: [
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
                    "Send from Wallet",
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
                    "Send from Account",
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
                    "Current Balance: ${viewModel.balance} SAT",
                    style: FontManager.captionMedian(ProtonColors.textHint),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Send to Recipient(s)",
                    style: FontManager.captionMedian(
                        Theme.of(context).colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 5),
                TextFieldText(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: ProtonColors.backgroundSecondary,
                  suffixIcon: const Icon(Icons.close),
                  showSuffixIcon: false,
                  showEnabledBorder: false,
                  controller: viewModel.recipientTextController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Add Address",
                    style:
                        FontManager.captionMedian(ProtonColors.interactionNorm),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Amount",
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
                            choices: const ["SAT", "BTC"],
                            selectedValue: "SAT",
                            controller: viewModel.coinController),
                      ],
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fees (Default)",
                          style: FontManager.captionSemiBold(
                              Theme.of(context).colorScheme.primary),
                        ),
                        const TagText(
                          text: "Moderate",
                          radius: 10.0,
                          background: Color.fromARGB(255, 237, 252, 221),
                          textColor: Color.fromARGB(255, 40, 116, 4),
                        ),
                      ]),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: Text("${viewModel.feeRate.toStringAsFixed(1)} sats/vb\nConfirmation in 2hours")),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Advanced options",
                    style:
                        FontManager.captionMedian(ProtonColors.interactionNorm),
                  ),
                ),
                const SizedBox(height: 50),
                ButtonV5(
                    onPressed: () {
                      if (viewModel.coinController.text != "SAT") {
                        LocalToast.showToast(
                          context,
                          "Only support SAT now!",
                          isWarning: true,
                          icon: const Icon(Icons.warning, color: Colors.white),
                        );
                      } else {
                        viewModel.sendCoin();
                        viewModel.coordinator.end();
                        Navigator.of(context).pop();
                      }
                    },
                    text: "Review Transaction",
                    width: MediaQuery.of(context).size.width,
                    textStyle: FontManager.body1Median(ProtonColors.white),
                    height: 48),
              ])))
    ]);
  }
}
